#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from pypdf import PdfReader


def parse_page_range(total_pages: int, raw: str | None) -> list[int]:
    if not raw:
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


def main() -> int:
    parser = argparse.ArgumentParser(description='Extract text from a PDF page by page.')
    parser.add_argument('input_pdf', type=Path)
    parser.add_argument('--output_txt', type=Path, default=None)
    parser.add_argument('--pages', type=str, default=None, help='Examples: 1-5 or 1,3,7-9')
    args = parser.parse_args()

    input_pdf = args.input_pdf.resolve()
    reader = PdfReader(str(input_pdf))
    page_indices = parse_page_range(len(reader.pages), args.pages)

    parts: list[str] = []
    for page_idx in page_indices:
        text = reader.pages[page_idx].extract_text() or ''
        parts.append(f'--- Page {page_idx + 1} ---\n{text.strip()}\n')
    output = '\n'.join(parts).strip() + '\n'

    if args.output_txt:
        args.output_txt.parent.mkdir(parents=True, exist_ok=True)
        args.output_txt.write_text(output, encoding='utf-8')
        print(args.output_txt.resolve())
    else:
        print(output)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
