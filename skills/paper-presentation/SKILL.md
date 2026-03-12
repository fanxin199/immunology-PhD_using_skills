---
name: paper-presentation
description: Create talk-ready Chinese PowerPoint presentations from academic paper PDFs, and optionally build a study sidecar for paper reading, figure interpretation, and follow-up discussion. Use PPT generation only when the user explicitly wants a report deck; otherwise prefer the study-pack path for paper learning and figure explanation tasks.
---

# Paper Presentation

## Overview
This skill supports two distinct intents for born-digital paper PDFs:

1. PPT path: build an editable, talk-ready Chinese slide deck.
2. Study path: build a sidecar study directory for paper reading, figure interpretation, and follow-up discussion.

For research papers, keep every main figure in the deck and give each figure a one-line take-home plus 3 to 5 bullets when using the PPT path. When using the study path, generate a `<paper_stem>_study/` directory next to the PDF using `scripts/build_paper_study_pack.py`, then keep a Chinese `学习导读.md` in that directory for orientation and repeat reading.

## Intent Routing
- Only generate a PPT when the user explicitly asks for a presentation deliverable. Typical triggers include requests such as `帮我做成PPT`, `生成汇报PPT`, `做一个组会PPT`, `整理成答辩PPT`, or other clearly presentation-oriented wording.
- If the user instead asks to interpret the paper, study it together, explain a figure, explain the experiment design, summarize the logic of the paper, or keep parsed reading materials, do not default to PPT generation. Use the study path first.
- Typical study-path triggers include requests such as `一起读这篇论文`, `帮我理解这篇文章`, `解释一下这篇论文`, `帮我看 Figure 1 在讲什么`, or `给我做一个论文学习包`.
- If the user asks for both, do both: generate the PPT and also build the study pack.

## Workflow
1. Classify the paper.
- Treat original research papers as figure-driven decks.
- Treat reviews or perspectives as theme-driven decks. Read `references/review-paper.md` only when the paper is not organized around experiments and main figures.

2. Extract the paper text.
- Use `scripts/extract_pdf_text.py` to dump the PDF text before outlining.
- Read title, abstract, results, discussion, and figure captions first.

3. Extract the figures.
- For research papers, extract every main figure in order: Figure 1 through Figure N.
- Use `scripts/extract_pdf_figures.py` on the pages that contain the main figures.
- If a page has no embedded figure image, let the script fall back to rendering the full page.
- Watch for split-page layouts common in Cell/Elsevier PDFs where the main figure is on page N but the caption starts on page N+1. In those cases, preserve the figure image from the figure-only page and record both `source_page` and `caption_page`.
- Do not assume figure captions always begin near the left margin. In Nature-style two-column PDFs, a main-figure caption may begin in the right column and the last main figure is easy to miss if caption detection is left-column-only.
- Treat page-wide decorative rules and cross-column text grouping as extraction hazards. If a crop unexpectedly expands toward the page edge or pulls in left-column prose, prefer caption-aware and column-aware cropping over keeping a larger but polluted crop.

4. Decide the branch before doing work.
- If the user explicitly wants a presentation deliverable, continue with the PPT branch below.
- If the user wants to read the paper, learn it, interpret figures, understand methods, or keep parsed reading materials, use the study branch first and do not generate a PPT unless they also asked for one.

5. Optionally build a study pack.
- Use this branch for reading, comparison, figure explanation, or any paper-learning task that does not require a presentation deliverable.
- Use `scripts/build_paper_study_pack.py` to create `<paper_stem>_study/` next to the source PDF.
- Treat the study pack as a final artifact, not as an intermediate. Never delete it during cleanup.
- After building the study pack, ensure it contains a Chinese `学习导读.md` that explains the paper's main question, suggested reading order, figure-by-figure navigation, key concepts, and self-check questions.

6. Outline before authoring.
- Use `references/research-paper.md` for the default research-paper structure.
- Keep the default order: title, why it matters, study design, Figure 1..N, wrap-up.
- Give every figure slide unit these parts: a clear title, one take-home sentence, 3 to 5 bullets, and the figure or a readable crop from it.

7. Author the deck as editable slides.
- Prefer JavaScript plus PptxGenJS for generation.
- Keep text, labels, and callouts editable. Do not flatten the whole slide into an image.
- Use 16:9 unless the source material clearly requires another aspect ratio.
- Reuse existing slide helpers when they are available instead of rewriting layout utilities from scratch.

8. Apply research-paper rules.
- Cover every main figure.
- Write 3 to 5 bullets for every main figure.
- Split a crowded figure across two slides when needed, but preserve the same figure identity.
- Use methods only to explain figure logic. Do not let methods dominate the slide.

9. Validate visually.
- On Windows, prefer `scripts/render_slides_windows_safe.py` instead of generic renderers when LibreOffice temp-directory cleanup is flaky.
- Build a contact sheet with `scripts/create_montage_safe.py` after rendering.
- Use `references/visual-review.md` as the final review checklist.
- Fix readable-but-bad layouts too: cramped figure callouts, truncated chips, unreadable captions, tiny figure panels, unstable visual balance.
- For study packs, visually spot-check at least Figure 1, the last main figure, and every page where the caption page differs from the source page. These are the highest-risk pages for partial crops, missed figures, or single-panel extraction mistakes.
- Add one more spot-check for figures whose caption begins in the right column. The common failure modes are: left-column body text leaking into the crop, a page-wide horizontal rule forcing a near full-page crop, or the figure caption swallowing the next section heading.

10. Deliver the result.
- Default output policy: keep the final `.pptx` and, when relevant, the authoring `.js`.
- Delete intermediate files after successful delivery unless the user explicitly asks to keep them or sets `keep_intermediates=true`.
- Typical intermediates to delete: extracted text dumps, figure crops, rendered PNGs, montage images, temp PDFs, and temporary render work directories.
- Use `scripts/cleanup_intermediates.py` for predictable cleanup instead of leaving temp outputs scattered around the workspace.

## Temp And Output Policy
- Put intermediates under a task-local `tmp/` subtree whenever possible.
- Treat these as disposable by default.
- Only preserve intermediates when debugging layout, comparing revisions, or when the user explicitly asks for them.
- If the user only wants the final PPT, do not leave extraction and rendering artifacts behind.
- A `<paper_stem>_study/` directory generated by `build_paper_study_pack.py` is a final artifact, not an intermediate. Keep it unless the user explicitly asks to remove it.

## Bundled Resources
- `scripts/extract_pdf_text.py`: Extract the paper text page by page.
- `scripts/extract_pdf_figures.py`: Extract caption-aware figure crops from selected PDF pages, including two-column layouts and right-column captions; fall back to full-page rendering only when needed.
- `scripts/render_slides_windows_safe.py`: Render `.pptx` or `.pdf` to slide PNGs on Windows with explicit LibreOffice and Poppler discovery.
- `scripts/create_montage_safe.py`: Build a montage from rendered slide PNGs without using temp conversions.
- `scripts/cleanup_intermediates.py`: Delete temporary files and directories after final delivery.
- `scripts/build_paper_study_pack.py`: Build a sidecar study directory with `paper.md`, `meta.json`, `学习导读.md`, extracted main figures, and one context file per figure, while preserving `source_page` and `caption_page` for tricky layouts.
- `references/research-paper.md`: Default structure and rules for research-paper decks.
- `references/review-paper.md`: Alternate structure for review or perspective papers.
- `references/visual-review.md`: Final layout and readability checklist.

## Dependencies
Python packages:
```bash
python -m pip install pypdf pymupdf pdfplumber pypdfium2 pillow pdf2image
```

Windows rendering dependencies:
- LibreOffice (`soffice`)
- Poppler (`pdftoppm`, `pdfinfo`)

## Default Commands
Extract text:
```bash
python scripts/extract_pdf_text.py paper.pdf --output_txt tmp/paper.txt
```

Extract selected figure pages:
```bash
python scripts/extract_pdf_figures.py paper.pdf tmp/figures --pages 4-10
```

Build a study pack next to the source PDF:
```bash
python scripts/build_paper_study_pack.py paper.pdf
```

Render a PPTX on Windows:
```bash
python scripts/render_slides_windows_safe.py deck.pptx --output_dir tmp/rendered
```

Create a montage:
```bash
python scripts/create_montage_safe.py --input_dir tmp/rendered --output_file tmp/rendered/montage.png
```

Clean up intermediates after delivery:
```bash
python scripts/cleanup_intermediates.py tmp/paper.txt tmp/figures tmp/rendered
```
