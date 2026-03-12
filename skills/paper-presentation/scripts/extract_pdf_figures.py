from __future__ import annotations

import argparse
import re
from collections import defaultdict
from pathlib import Path

import pdfplumber
import pypdfium2 as pdfium


CAPTION_STRONG_RE = re.compile(r"^(Fig(?:ure)?\.?)\s*(\d+)\s*(\||:|\.)")
CAPTION_WEAK_RE = re.compile(r"^(Fig(?:ure)?\.?)\s*(\d+)\b")


def parse_page_range(total_pages: int, raw: str | None) -> list[int]:
    if not raw or raw.lower() == 'all':
        return list(range(total_pages))
    selected: set[int] = set()
    for chunk in raw.split(','):
        chunk = chunk.strip()
        if not chunk:
            continue
        if '-' in chunk:
            start_s, end_s = chunk.split('-', 1)
            start = int(start_s)
            end = int(end_s)
            for page in range(start, end + 1):
                if 1 <= page <= total_pages:
                    selected.add(page - 1)
        else:
            page = int(chunk)
            if 1 <= page <= total_pages:
                selected.add(page - 1)
    return sorted(selected)


def group_words_into_lines(words: list[dict], tolerance: float = 2.0) -> list[list[dict]]:
    lines: list[list[dict]] = []
    current: list[dict] = []
    current_top: float | None = None
    for word in sorted(words, key=lambda item: (item['top'], item['x0'])):
        if current_top is None or abs(word['top'] - current_top) <= tolerance:
            current.append(word)
            current_top = word['top'] if current_top is None else min(current_top, word['top'])
        else:
            lines.append(sorted(current, key=lambda item: item['x0']))
            current = [word]
            current_top = word['top']
    if current:
        lines.append(sorted(current, key=lambda item: item['x0']))
    return lines


def split_line_into_segments(line: list[dict], gap_threshold: float = 24.0) -> list[list[dict]]:
    if not line:
        return []
    segments: list[list[dict]] = [[line[0]]]
    prev = line[0]
    for word in line[1:]:
        gap = float(word['x0']) - float(prev['x1'])
        if gap > gap_threshold:
            segments.append([word])
        else:
            segments[-1].append(word)
        prev = word
    return segments


def count_alpha_words(page: pdfplumber.page.Page) -> int:
    words = page.extract_words(x_tolerance=1, y_tolerance=2, keep_blank_chars=False)
    return sum(1 for word in words if any(ch.isalpha() for ch in word['text']))


def graphic_item_count(page: pdfplumber.page.Page) -> int:
    return len(page.images) + len(page.lines) + len(page.rects) + len(page.curves)


def should_use_page_fallback(page: pdfplumber.page.Page) -> bool:
    # Composite journal figures are often vector-heavy. On pages without captions,
    # cropping the single largest embedded image can reduce the output to one panel.
    return count_alpha_words(page) <= 80 and graphic_item_count(page) >= 500


def find_caption_anchor(page: pdfplumber.page.Page, header_cutoff: float) -> tuple[float, float] | None:
    words = page.extract_words(x_tolerance=1, y_tolerance=2, keep_blank_chars=False)
    lines = group_words_into_lines(words)
    strong: list[tuple[float, float]] = []
    weak: list[tuple[float, float]] = []
    for line in lines:
        if not line:
            continue
        # Captions can begin in either column in journal PDFs.
        if line[0]['top'] <= header_cutoff:
            continue
        line_text = ' '.join(word['text'] for word in line[:10])
        if CAPTION_STRONG_RE.match(line_text):
            strong.append((line[0]['top'], line[0]['x0']))
        elif CAPTION_WEAK_RE.match(line_text):
            weak.append((line[0]['top'], line[0]['x0']))
    if strong:
        return min(strong, key=lambda item: item[0])
    if weak:
        return min(weak, key=lambda item: item[0])
    return None


def object_bbox(item: dict) -> tuple[float, float, float, float]:
    return float(item['x0']), float(item['top']), float(item['x1']), float(item['bottom'])


def is_decorative_rule(
    box: tuple[float, float, float, float],
    page_width: float,
) -> bool:
    x0, top, x1, bottom = box
    width = x1 - x0
    height = bottom - top
    return width >= page_width * 0.7 and height <= 3.0


def merge_bboxes(boxes: list[tuple[float, float, float, float]]) -> tuple[float, float, float, float] | None:
    if not boxes:
        return None
    return (
        min(box[0] for box in boxes),
        min(box[1] for box in boxes),
        max(box[2] for box in boxes),
        max(box[3] for box in boxes),
    )


def expand_bbox(box: tuple[float, float, float, float], dx: float, dy: float, page_width: float, page_height: float) -> tuple[float, float, float, float]:
    x0, top, x1, bottom = box
    return (
        max(0.0, x0 - dx),
        max(0.0, top - dy),
        min(page_width, x1 + dx),
        min(page_height, bottom + dy),
    )


def intersects(box_a: tuple[float, float, float, float], box_b: tuple[float, float, float, float]) -> bool:
    ax0, at, ax1, ab = box_a
    bx0, bt, bx1, bb = box_b
    return not (ax1 < bx0 or bx1 < ax0 or ab < bt or bb < at)


def find_caption_aware_bbox(
    page: pdfplumber.page.Page,
    caption_top: float,
    header_cutoff: float,
    caption_x0: float | None = None,
) -> tuple[float, float, float, float] | None:
    column_min_x = 0.0
    if caption_x0 is not None and caption_x0 > page.width * 0.45:
        # Right-column captions in journal layouts should not absorb left-column prose.
        column_min_x = max(0.0, caption_x0 - 36.0)

    graphic_items = []
    for collection_name in ('images', 'lines', 'rects', 'curves'):
        for item in getattr(page, collection_name):
            if item.get('top', 0) <= header_cutoff:
                continue
            if item.get('bottom', 0) >= caption_top - 2:
                continue
            box = object_bbox(item)
            # Ignore publisher separator rules that can force the crop to span the full page.
            if is_decorative_rule(box, page_width=page.width):
                continue
            if column_min_x and box[2] < column_min_x:
                continue
            graphic_items.append(box)

    base_box = merge_bboxes(graphic_items)

    words = page.extract_words(x_tolerance=1, y_tolerance=2, keep_blank_chars=False)
    candidate_words = [
        word for word in words
        if word['top'] > header_cutoff and word['bottom'] < caption_top - 2
    ]
    candidate_lines = group_words_into_lines(candidate_words)

    if base_box is None:
        word_boxes = [object_bbox(word) for word in candidate_words]
        return merge_bboxes(word_boxes)

    expanded = expand_bbox(base_box, dx=28.0, dy=20.0, page_width=page.width, page_height=page.height)
    attached_word_boxes = []
    right_column_mode = caption_x0 is not None and caption_x0 > page.width * 0.45
    for line in candidate_lines:
        for segment in split_line_into_segments(line):
            segment_boxes = [object_bbox(word) for word in segment]
            if not any(intersects(box, expanded) for box in segment_boxes):
                continue
            segment_bbox = merge_bboxes(segment_boxes)
            if segment_bbox is None:
                continue
            if right_column_mode:
                seg_x0, _seg_top, seg_x1, _seg_bottom = segment_bbox
                seg_width = seg_x1 - seg_x0
                if seg_x0 < base_box[0] - 120.0 and seg_width > 170.0:
                    continue
            attached_word_boxes.extend(segment_boxes)
    merged = merge_bboxes(graphic_items + attached_word_boxes)
    if merged is None:
        return None
    return expand_bbox(merged, dx=6.0, dy=6.0, page_width=page.width, page_height=page.height)


def crop_page(page: pdfplumber.page.Page, rendered_page: pdfium.PdfPage, output_dir: Path, page_no: int, scale: float, pad: int, strategy: str, header_cutoff: float) -> tuple[Path, str]:
    bitmap = rendered_page.render(scale=scale)
    image = bitmap.to_pil()

    crop = None
    used = 'full-page'

    if strategy in {'auto', 'caption-aware'}:
        caption_anchor = find_caption_anchor(page, header_cutoff=header_cutoff)
        if caption_anchor is not None:
            caption_top, caption_x0 = caption_anchor
            bbox = find_caption_aware_bbox(
                page,
                caption_top=caption_top,
                header_cutoff=header_cutoff,
                caption_x0=caption_x0,
            )
            if bbox is not None:
                x0, top, x1, bottom = bbox
                x0 = max(0.0, x0 - pad)
                top = max(header_cutoff, top - 2)
                x1 = min(page.width, x1 + pad)
                bottom = min(caption_top - 4, bottom + 1)
                crop = image.crop((int(x0 * scale), int(top * scale), int(x1 * scale), int(bottom * scale)))
                used = 'caption-aware'

    if crop is None and strategy == 'auto' and should_use_page_fallback(page):
        crop = image
        used = 'page-fallback'

    if crop is None and strategy in {'auto', 'largest-image'} and page.images:
        img = max(page.images, key=lambda item: item['width'] * item['height'])
        x0 = max(0, img['x0'] - pad)
        x1 = min(page.width, img['x1'] + pad)
        top = max(0, img['top'] - pad)
        bottom = min(page.height, img['bottom'] + pad)
        crop = image.crop((int(x0 * scale), int(top * scale), int(x1 * scale), int(bottom * scale)))
        used = 'largest-image'

    if crop is None:
        crop = image

    output_path = output_dir / f'page-{page_no + 1}.png'
    crop.save(output_path)
    rendered_page.close()
    return output_path, used


def main() -> int:
    parser = argparse.ArgumentParser(description='Extract main figure crops from selected PDF pages.')
    parser.add_argument('input_pdf', type=Path)
    parser.add_argument('output_dir', type=Path)
    parser.add_argument('--pages', type=str, default='all', help='Examples: 4-10 or 4,5,8')
    parser.add_argument('--scale', type=float, default=4.0)
    parser.add_argument('--pad', type=int, default=8)
    parser.add_argument('--strategy', choices=['auto', 'caption-aware', 'largest-image', 'page'], default='auto')
    parser.add_argument('--header-cutoff', type=float, default=40.0, help='Ignore publisher header objects above this top coordinate.')
    args = parser.parse_args()

    pdf_path = args.input_pdf.resolve()
    output_dir = args.output_dir.resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    with pdfplumber.open(str(pdf_path)) as plumber_pdf:
        page_indices = parse_page_range(len(plumber_pdf.pages), args.pages)
        rendered = pdfium.PdfDocument(str(pdf_path))
        try:
            for page_no in page_indices:
                page = plumber_pdf.pages[page_no]
                if args.strategy == 'page':
                    bitmap = rendered[page_no].render(scale=args.scale)
                    image = bitmap.to_pil()
                    output_path = output_dir / f'page-{page_no + 1}.png'
                    image.save(output_path)
                    rendered[page_no].close()
                    print(f'{output_path} [page]')
                    continue
                out, used = crop_page(
                    page=page,
                    rendered_page=rendered[page_no],
                    output_dir=output_dir,
                    page_no=page_no,
                    scale=args.scale,
                    pad=args.pad,
                    strategy=args.strategy,
                    header_cutoff=args.header_cutoff,
                )
                print(f'{out} [{used}]')
        finally:
            rendered.close()
    return 0


if __name__ == '__main__':
    raise SystemExit(main())


