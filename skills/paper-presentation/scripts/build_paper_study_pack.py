#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import fitz
import pdfplumber

SCRIPT_DIR = Path(__file__).resolve().parent
FALLBACK_SCRIPT_DIR = Path(r'C:\Users\yunfe\.codex\skills\paper-presentation\scripts')
IMPORT_SCRIPT_DIR = SCRIPT_DIR if (SCRIPT_DIR / 'extract_pdf_figures.py').exists() else FALLBACK_SCRIPT_DIR
EXTRACT_FIGURES_SCRIPT = IMPORT_SCRIPT_DIR / 'extract_pdf_figures.py'
sys.path.insert(0, str(IMPORT_SCRIPT_DIR))

from extract_pdf_figures import CAPTION_STRONG_RE, group_words_into_lines  # type: ignore  # noqa: E402

SECTION_HEADINGS = {
    'abstract': 'abstract',
    'results': 'results',
    'discussion': 'discussion',
    'methods': 'methods',
    'online content': 'other',
    'references': 'references',
    'acknowledgements': 'other',
}
STOP_FIGURE_CONTEXT_SECTIONS = {'discussion', 'methods', 'references', 'other'}
DOI_RE = re.compile(r'10\.\d{4,9}/[-._;()/:A-Z0-9]+', re.IGNORECASE)
FIG_REF_TEMPLATE = r'Fig(?:ure)?\.?\s*{n}(?:[a-z])?\b'
ANY_FIG_RE = re.compile(r'Fig(?:ure)?\.?\s*\d+(?:[a-z])?\b', re.IGNORECASE)
CAPTION_GAP_MAX = 24.0
HEADER_CUTOFF = 40.0
FOOTER_CUTOFF = 22.0


@dataclass
class FigureAnchor:
    figure_number: int
    page_number: int
    caption_top: float
    image_page_number: int


@dataclass
class TextBlock:
    page_number: int
    x0: float
    top: float
    bottom: float
    text: str
    is_heading: bool
    section: str | None


@dataclass
class FigureContext:
    figure_number: int
    page_number: int
    image_page_number: int
    image_path: Path
    context_path: Path
    caption: str
    results_context: str | None
    notes: list[str]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Build a study pack sidecar directory for a born-digital paper PDF.')
    parser.add_argument('input_pdf', type=Path)
    parser.add_argument('--output_dir', type=Path, default=None)
    return parser.parse_args()


def clean_text(text: str) -> str:
    text = text.replace('\u00a0', ' ').replace('\u2009', ' ')
    text = re.sub(r'-\n(?=[a-z])', '', text)
    text = re.sub(r'\n+', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()


def figure_short_title(caption: str, figure_number: int) -> str:
    raw = clean_text(caption)
    if not raw:
        return f'Figure {figure_number}'
    raw = re.sub(rf'^Figure\s+{figure_number}\.\s*', '', raw, flags=re.IGNORECASE)
    raw = re.split(r'\s+\([A-Z](?:[^)]*)\)\s+', raw, maxsplit=1)[0]
    raw = re.split(r'\s+See also\b', raw, maxsplit=1, flags=re.IGNORECASE)[0]
    raw = re.split(r'\s+Cell\s+\d+\b', raw, maxsplit=1)[0]
    return raw.rstrip('.')


def render_markdown_text(text: str) -> str:
    text = clean_text(text)
    return text.replace('\\', '\\\\')


def get_sorted_text_blocks(page: fitz.Page) -> list[tuple]:
    blocks = [block for block in page.get_text('blocks') if len(block) >= 7 and block[6] == 0 and clean_text(block[4])]
    return sorted(blocks, key=lambda block: (round(block[1], 1), block[0]))


def is_main_figure_reference(text: str, figure_number: int, allow_caption: bool = False) -> bool:
    pattern = re.compile(FIG_REF_TEMPLATE.format(n=figure_number), re.IGNORECASE)
    lower = text.lower()
    for match in pattern.finditer(text):
        prefix = lower[max(0, match.start() - 25):match.start()].rstrip()
        if prefix.endswith('supplementary') or prefix.endswith('extended data'):
            continue
        suffix = lower[match.end():match.end() + 6].lstrip()
        if not allow_caption and suffix.startswith('|'):
            continue
        return True
    return False


def extract_main_figure_numbers(text: str, allow_caption: bool = False) -> list[int]:
    lower = text.lower()
    found: list[int] = []
    for match in ANY_FIG_RE.finditer(text):
        number_match = re.search(r'(\d+)', match.group(0))
        if not number_match:
            continue
        prefix = lower[max(0, match.start() - 25):match.start()].rstrip()
        if prefix.endswith('supplementary') or prefix.endswith('extended data'):
            continue
        suffix = lower[match.end():match.end() + 6].lstrip()
        if not allow_caption and suffix.startswith('|'):
            continue
        found.append(int(number_match.group(1)))
    return found


def is_probable_heading(text: str) -> bool:
    raw = clean_text(text)
    if not raw:
        return False
    lower = raw.lower().rstrip(':')
    if lower in SECTION_HEADINGS:
        return True
    if len(raw) > 120:
        return False
    if raw.endswith('.'):
        return False
    words = raw.split()
    if len(words) > 14:
        return False
    if not any(ch.isalpha() for ch in raw):
        return False
    if sum(ch in '.!?;' for ch in raw) > 1:
        return False
    return raw[:1].isupper()


def looks_like_paragraph(text: str) -> bool:
    raw = clean_text(text)
    if len(raw) >= 120:
        return True
    if raw.count(' ') >= 18:
        return True
    if len(raw) >= 75 and any(p in raw for p in '.;:'):
        return True
    return False


def is_probable_figure_artifact(text: str) -> bool:
    raw = clean_text(text)
    if not raw:
        return True
    if any(p in raw for p in '.;:?!'):
        return False
    tokens = raw.split()
    if len(tokens) >= 4:
        return True
    upper_ratio = sum(1 for ch in raw if ch.isupper()) / max(1, sum(1 for ch in raw if ch.isalpha()))
    return upper_ratio > 0.45


def split_leading_section_heading(text: str) -> tuple[str | None, str]:
    raw = clean_text(text)
    for heading in SECTION_HEADINGS:
        pattern = re.compile(rf'^{re.escape(heading)}(?:[:\s-]+)(.+)$', re.IGNORECASE)
        match = pattern.match(raw)
        if match:
            remainder = clean_text(match.group(1))
            if remainder:
                return heading, remainder
    return None, raw


def is_header_footer_block(text: str, top: float, bottom: float, page_height: float) -> bool:
    raw = clean_text(text)
    if not raw:
        return True
    if top <= HEADER_CUTOFF and (
        'Nature Genetics | Volume' in raw
        or raw.startswith('Article')
        or 'https://doi.org/' in raw
    ):
        return True
    if page_height - bottom <= FOOTER_CUTOFF:
        if raw.isdigit() or raw.startswith('Nature Genetics | Volume'):
            return True
    return False


def guess_title(doc: fitz.Document) -> str:
    meta_title = (doc.metadata.get('title') or '').strip()
    if meta_title:
        return meta_title

    page = doc[0]
    data = page.get_text('dict')
    best = ''
    best_size = 0.0
    for block in data.get('blocks', []):
        if block.get('type') != 0:
            continue
        for line in block.get('lines', []):
            text = ''.join(span.get('text', '') for span in line.get('spans', []))
            text = clean_text(text)
            if not text:
                continue
            size = max((span.get('size', 0.0) for span in line.get('spans', [])), default=0.0)
            if size > best_size and len(text) > 20:
                best_size = size
                best = text
    return best or doc.name or 'Untitled paper'


def find_doi(doc: fitz.Document) -> str | None:
    meta = doc.metadata
    for field in ('subject', 'keywords', 'title'):
        value = meta.get(field) or ''
        match = DOI_RE.search(value)
        if match:
            return match.group(0)
    for page_no in range(min(2, doc.page_count)):
        text = doc[page_no].get_text('text', sort=True)
        match = DOI_RE.search(text)
        if match:
            return match.group(0)
    return None


def find_figure_anchors(pdf_path: Path) -> list[FigureAnchor]:
    anchors: dict[int, FigureAnchor] = {}
    with pdfplumber.open(str(pdf_path)) as pdf:
        for page_idx, page in enumerate(pdf.pages):
            words = page.extract_words(x_tolerance=1, y_tolerance=2, keep_blank_chars=False)
            lines = group_words_into_lines(words)
            for line in lines:
                if not line:
                    continue
                first = line[0]
                # Main-figure captions in two-column layouts can start in the right column.
                if first['top'] <= HEADER_CUTOFF:
                    continue
                line_text = ' '.join(word['text'] for word in line[:10])
                match = CAPTION_STRONG_RE.match(line_text)
                if not match:
                    continue
                figure_number = int(match.group(2))
                anchors.setdefault(
                    figure_number,
                    FigureAnchor(
                        figure_number=figure_number,
                        page_number=page_idx + 1,
                        caption_top=float(first['top']),
                        image_page_number=page_idx + 1,
                    ),
                )
    return [anchors[key] for key in sorted(anchors)]


def count_alpha_words(page: pdfplumber.page.Page) -> int:
    words = page.extract_words(x_tolerance=1, y_tolerance=2, keep_blank_chars=False)
    return sum(1 for word in words if any(ch.isalpha() for ch in word['text']))


def graphic_item_count(page: pdfplumber.page.Page) -> int:
    return len(page.images) + len(page.lines) + len(page.rects) + len(page.curves)


def is_figure_only_page(page: pdfplumber.page.Page) -> bool:
    return count_alpha_words(page) <= 80 and graphic_item_count(page) >= 500


def is_text_heavy_caption_page(page: pdfplumber.page.Page) -> bool:
    return count_alpha_words(page) >= 400 and graphic_item_count(page) <= 50


def resolve_image_page_numbers(pdf_path: Path, anchors: list[FigureAnchor]) -> list[FigureAnchor]:
    if not anchors:
        return anchors

    resolved: list[FigureAnchor] = []
    with pdfplumber.open(str(pdf_path)) as pdf:
        for anchor in anchors:
            image_page_number = anchor.page_number
            if anchor.page_number > 1:
                current_page = pdf.pages[anchor.page_number - 1]
                previous_page = pdf.pages[anchor.page_number - 2]
                if is_figure_only_page(previous_page) and is_text_heavy_caption_page(current_page):
                    image_page_number = anchor.page_number - 1
            resolved.append(
                FigureAnchor(
                    figure_number=anchor.figure_number,
                    page_number=anchor.page_number,
                    caption_top=anchor.caption_top,
                    image_page_number=image_page_number,
                )
            )
    return resolved


def extract_figures(pdf_path: Path, figures_dir: Path, anchors: list[FigureAnchor]) -> dict[int, Path]:
    if not anchors:
        return {}
    extract_script = EXTRACT_FIGURES_SCRIPT
    temp_dir = figures_dir.parent / '.figure_pages_tmp'
    shutil.rmtree(temp_dir, ignore_errors=True)
    temp_dir.mkdir(parents=True, exist_ok=True)
    figures_dir.mkdir(parents=True, exist_ok=True)
    page_arg = ','.join(str(anchor.image_page_number) for anchor in anchors)
    cmd = [
        'python',
        str(extract_script),
        str(pdf_path),
        str(temp_dir),
        '--pages',
        page_arg,
        '--strategy',
        'auto',
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(
            'extract_pdf_figures.py failed.\n'
            f'stdout:\n{result.stdout}\n\n'
            f'stderr:\n{result.stderr}'
        )

    mapping: dict[int, Path] = {}
    for anchor in anchors:
        src = temp_dir / f'page-{anchor.image_page_number}.png'
        if not src.exists():
            raise FileNotFoundError(src)
        dst = figures_dir / f'fig{anchor.figure_number}.png'
        shutil.copy2(src, dst)
        mapping[anchor.figure_number] = dst
    shutil.rmtree(temp_dir, ignore_errors=True)
    return mapping


def extract_caption_text(plumber_page: pdfplumber.page.Page, fitz_page: fitz.Page, anchor: FigureAnchor) -> str:
    _ = plumber_page
    blocks = get_sorted_text_blocks(fitz_page)
    start_idx = None
    for idx, block in enumerate(blocks):
        if block[1] >= anchor.caption_top - 8:
            start_idx = idx
            break
    if start_idx is None:
        return ''

    included = [blocks[start_idx]]
    current_bottom = blocks[start_idx][3]
    for block in blocks[start_idx + 1:]:
        y0 = block[1]
        if y0 - current_bottom > CAPTION_GAP_MAX:
            break
        cleaned = clean_text(block[4])
        heading_key = cleaned.lower().rstrip(':')
        if cleaned and is_probable_heading(cleaned) and heading_key in SECTION_HEADINGS:
            break
        included.append(block)
        current_bottom = max(current_bottom, block[3])

    parts = []
    for block in included:
        text = clean_text(block[4])
        if text:
            parts.append(text)
    caption = '\n'.join(parts).strip()
    section_pattern = re.compile(
        r'\n(?:'
        + '|'.join(re.escape(heading) for heading in SECTION_HEADINGS)
        + r')\b',
        re.IGNORECASE,
    )
    match = section_pattern.search(caption)
    if match:
        caption = caption[:match.start()].rstrip()
    return caption


def build_text_blocks(doc: fitz.Document, anchors_by_page: dict[int, FigureAnchor]) -> list[TextBlock]:
    blocks_out: list[TextBlock] = []
    current_section: str | None = None
    for page_idx in range(doc.page_count):
        page = doc[page_idx]
        page_height = page.rect.height
        page_anchor = anchors_by_page.get(page_idx + 1)
        raw_blocks = get_sorted_text_blocks(page)
        for block in raw_blocks:
            x0, top, _x1, bottom, text, *_rest = block
            cleaned = clean_text(text)
            if not cleaned:
                continue
            if is_header_footer_block(cleaned, top, bottom, page_height):
                continue
            if page_anchor and bottom < page_anchor.caption_top:
                if is_probable_figure_artifact(cleaned) or not looks_like_paragraph(cleaned):
                    continue

            leading_heading, cleaned = split_leading_section_heading(cleaned)
            if leading_heading:
                current_section = SECTION_HEADINGS[leading_heading]
                blocks_out.append(
                    TextBlock(
                        page_number=page_idx + 1,
                        x0=float(x0),
                        top=float(top),
                        bottom=float(bottom),
                        text=leading_heading.title(),
                        is_heading=True,
                        section=current_section,
                    )
                )

            heading = is_probable_heading(cleaned)
            heading_key = cleaned.lower().rstrip(':')
            if heading and heading_key in SECTION_HEADINGS:
                current_section = SECTION_HEADINGS[heading_key]
            blocks_out.append(
                TextBlock(
                    page_number=page_idx + 1,
                    x0=float(x0),
                    top=float(top),
                    bottom=float(bottom),
                    text=cleaned,
                    is_heading=heading,
                    section=current_section,
                )
            )
    return blocks_out


def render_paper_markdown(title: str, doi: str | None, pdf_path: Path, page_count: int, blocks: list[TextBlock]) -> str:
    lines = [
        f'# {title}',
        '',
        f'- Source PDF: {pdf_path.resolve()}',
        f'- DOI: {doi or "Not found"}',
        f'- Page count: {page_count}',
        '- Parser: pymupdf-first',
        '',
    ]
    current_page = None
    for block in blocks:
        if block.page_number != current_page:
            current_page = block.page_number
            lines.extend([f'## Page {current_page}', ''])
        text = render_markdown_text(block.text)
        if block.is_heading:
            lines.extend([f'### {text.rstrip(":")}', ''])
        else:
            lines.extend([text, ''])
    return '\n'.join(lines).rstrip() + '\n'


def find_results_context(blocks: list[TextBlock], figure_number: int) -> tuple[str | None, list[str]]:
    notes: list[str] = []
    results_blocks = [block for block in blocks if not block.is_heading and block.section == 'results']
    if not results_blocks:
        notes.append('Results section not confidently detected; only caption available.')
        return None, notes

    start_idx = None
    for idx, block in enumerate(results_blocks):
        if is_main_figure_reference(block.text, figure_number, allow_caption=False):
            start_idx = idx
            break
    if start_idx is None:
        notes.append('Results context not confidently matched; only caption available.')
        return None, notes

    selected = [results_blocks[start_idx]]
    idx = start_idx + 1
    while idx < len(results_blocks):
        candidate = results_blocks[idx]
        previous = selected[-1]
        if candidate.page_number == previous.page_number and candidate.top < previous.bottom - 5:
            break
        refs = extract_main_figure_numbers(candidate.text, allow_caption=False)
        if figure_number in refs:
            selected.append(candidate)
            idx += 1
            continue
        other_refs = [ref for ref in refs if ref != figure_number]
        if other_refs:
            break
        if len(selected) < 2:
            selected.append(candidate)
        break

    rendered = []
    for block in selected:
        rendered.append(f'- Page {block.page_number}: {block.text}')
    return '\n'.join(rendered), notes


def render_figure_context(anchor: FigureAnchor, image_path: Path, pdf_path: Path, caption: str, results_context: str | None, notes: list[str]) -> str:
    lines = [
        f'# Figure {anchor.figure_number}',
        '',
        f'- Source PDF: {pdf_path.resolve()}',
        f'- Source page: {anchor.image_page_number}',
    ]
    if anchor.image_page_number != anchor.page_number:
        lines.append(f'- Caption page: {anchor.page_number}')
    lines.extend([
        f'- Image: ../figures/{image_path.name}',
        '',
        '## Caption',
        caption or 'Caption not confidently extracted.',
        '',
        '## Results Context',
        results_context or 'No matching Results context found.',
        '',
        '## Notes',
    ])
    if notes:
        lines.extend(f'- {note}' for note in notes)
    else:
        lines.append('- Results context matched from the first explicit figure reference in the Results section.')
    return '\n'.join(lines).rstrip() + '\n'


def write_readme(output_dir: Path) -> None:
    content = f'''# Study Pack

This directory is a study sidecar generated from a born-digital paper PDF.
It is designed for direct reading and figure interpretation in Codex.

## Files
- `paper.md`: readable full-text Markdown with page anchors.
- `meta.json`: machine-readable metadata and figure index.
- `学习导读.md`: Chinese reading guide for fast orientation and repeat study.
- `figures/`: extracted main figures as `figN.png`.
- `figure_context/`: one Markdown context file per figure.

## Recommended prompts
- Read `paper.md` and summarize the research question, methods, key findings, and limitations.
- Use `figure_context/fig2.md` together with `figures/fig2.png` to explain what Figure 2 shows.
'''
    (output_dir / 'README.md').write_text(content, encoding='utf-8')


def write_study_guide(output_dir: Path, title: str, doi: str | None, figures: list[FigureContext]) -> None:
    lines = [
        '# 学习导读',
        '',
        '## 这份材料怎么用',
        f'- 论文标题：{title}',
        f'- DOI：{doi or "Not found"}',
        '- 建议先读摘要、Figure 1 和最后的讨论，再按 Figure 1 到 Figure N 逐图推进。',
        '- 如果 `source_page` 和 `caption_page` 不同，说明主图在前一页，图注在后一页；读图时两页要配合看。',
        '',
        '## 建议阅读顺序',
        '1. 先读 `paper.md` 的标题、摘要和 introduction，抓住研究问题与为什么值得做。',
        '2. 再看 Figure 1，建立样本、方法和细胞状态地图。',
        '3. 按 Figure 2 到 Figure N 的顺序，把“现象、机制、临床关联”串起来。',
        '4. 最后回看 discussion 和 limitations，区分作者真正证明了什么、哪些仍是推断。',
        '',
        '## 主图导航',
    ]
    for fig in figures:
        title_line = figure_short_title(fig.caption, fig.figure_number)
        if fig.image_page_number != fig.page_number:
            lines.append(
                f'- Figure {fig.figure_number}: {title_line}。主图在第 {fig.image_page_number} 页，caption 在第 {fig.page_number} 页。'
            )
        else:
            lines.append(f'- Figure {fig.figure_number}: {title_line}。')
    lines.extend([
        '',
        '## 推荐自测问题',
        '1. 作者真正想回答的核心科学问题是什么？',
        '2. 每张主图分别在证明什么，证据链是如何衔接的？',
        '3. 哪些结论来自直接证据，哪些更多是推断或模型支持？',
        '4. 这篇文章最强的图是哪一张，最薄弱的环节又在哪里？',
        '5. 如果你要复述这篇文章，能否用 3 句话讲清研究问题、关键发现和局限？',
        '',
        '## 使用建议',
        '- `paper.md` 适合顺读全文。',
        '- `figure_context/figN.md` 适合逐图精读。',
        '- `figures/figN.png` 适合单独放大查看 panel 与图例。',
    ])
    (output_dir / '学习导读.md').write_text('\n'.join(lines).rstrip() + '\n', encoding='utf-8')


def write_meta(output_dir: Path, pdf_path: Path, title: str, doi: str | None, page_count: int, figures: list[FigureContext]) -> None:
    payload = {
        'source_pdf': str(pdf_path.resolve()),
        'title': title,
        'doi': doi,
        'page_count': page_count,
        'parser': 'pymupdf-first',
        'figures': [
            {
                'figure_number': fig.figure_number,
                'source_page': fig.image_page_number,
                'caption_page': fig.page_number,
                'image_path': f'figures/{fig.image_path.name}',
                'context_path': f'figure_context/{fig.context_path.name}',
            }
            for fig in figures
        ],
    }
    (output_dir / 'meta.json').write_text(json.dumps(payload, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def build_study_pack(input_pdf: Path, output_dir: Path) -> Path:
    if not input_pdf.exists():
        raise FileNotFoundError(input_pdf)

    output_dir.mkdir(parents=True, exist_ok=True)
    figures_dir = output_dir / 'figures'
    context_dir = output_dir / 'figure_context'
    figures_dir.mkdir(parents=True, exist_ok=True)
    context_dir.mkdir(parents=True, exist_ok=True)

    doc = fitz.open(str(input_pdf))
    title = guess_title(doc)
    doi = find_doi(doc)
    anchors = resolve_image_page_numbers(input_pdf, find_figure_anchors(input_pdf))
    anchors_by_page = {anchor.page_number: anchor for anchor in anchors}

    figure_images = extract_figures(input_pdf, figures_dir, anchors)
    text_blocks = build_text_blocks(doc, anchors_by_page)
    paper_md = render_paper_markdown(title, doi, input_pdf, doc.page_count, text_blocks)
    (output_dir / 'paper.md').write_text(paper_md, encoding='utf-8')

    figure_contexts: list[FigureContext] = []
    with pdfplumber.open(str(input_pdf)) as plumber_pdf:
        for anchor in anchors:
            caption = extract_caption_text(plumber_pdf.pages[anchor.page_number - 1], doc[anchor.page_number - 1], anchor)
            results_context, notes = find_results_context(text_blocks, anchor.figure_number)
            image_path = figure_images[anchor.figure_number]
            context_path = context_dir / f'fig{anchor.figure_number}.md'
            context_md = render_figure_context(anchor, image_path, input_pdf, caption, results_context, notes)
            context_path.write_text(context_md, encoding='utf-8')
            figure_contexts.append(
                FigureContext(
                    figure_number=anchor.figure_number,
                    page_number=anchor.page_number,
                    image_page_number=anchor.image_page_number,
                    image_path=image_path,
                    context_path=context_path,
                    caption=caption,
                    results_context=results_context,
                    notes=notes,
                )
            )

    write_meta(output_dir, input_pdf, title, doi, doc.page_count, figure_contexts)
    write_study_guide(output_dir, title, doi, figure_contexts)
    write_readme(output_dir)
    doc.close()
    return output_dir


def main() -> int:
    args = parse_args()
    input_pdf = args.input_pdf.resolve()
    output_dir = args.output_dir.resolve() if args.output_dir else input_pdf.with_name(f'{input_pdf.stem}_study')
    result = build_study_pack(input_pdf, output_dir)
    print(result)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
