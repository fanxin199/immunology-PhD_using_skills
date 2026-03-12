#!/usr/bin/env python3
from __future__ import annotations

import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps


def natural_key(text: str) -> list[object]:
    parts: list[object] = []
    current = ''
    is_digit = None
    for char in text:
        char_is_digit = char.isdigit()
        if is_digit is None:
            current = char
            is_digit = char_is_digit
            continue
        if char_is_digit == is_digit:
            current += char
        else:
            parts.append(int(current) if is_digit else current)
            current = char
            is_digit = char_is_digit
    if current:
        parts.append(int(current) if is_digit else current)
    return parts


def load_font(size: int):
    for name in ('arial.ttf', 'DejaVuSans.ttf'):
        try:
            return ImageFont.truetype(name, size)
        except Exception:
            pass
    return ImageFont.load_default()


def main() -> int:
    parser = argparse.ArgumentParser(description='Create a montage from rendered slide PNGs.')
    parser.add_argument('--input_dir', type=Path, required=True)
    parser.add_argument('--output_file', type=Path, required=True)
    parser.add_argument('--num_col', type=int, default=3)
    parser.add_argument('--cell_width', type=int, default=480)
    parser.add_argument('--cell_height', type=int, default=270)
    parser.add_argument('--gap', type=int, default=20)
    parser.add_argument('--label_mode', choices=('number', 'filename', 'none'), default='number')
    args = parser.parse_args()

    input_dir = args.input_dir.resolve()
    files = sorted([p for p in input_dir.iterdir() if p.suffix.lower() in {'.png', '.jpg', '.jpeg'}], key=lambda p: natural_key(p.name))
    if not files:
        raise FileNotFoundError(f'No images found in {input_dir}')

    font = load_font(max(12, min(30, int(args.cell_height * 0.12))))
    label_height = 0 if args.label_mode == 'none' else font.size + 8
    row_height = args.cell_height + label_height
    rows = math.ceil(len(files) / args.num_col)
    width = args.num_col * args.cell_width + (args.num_col + 1) * args.gap
    height = rows * row_height + (rows + 1) * args.gap
    canvas = Image.new('RGB', (width, height), (242, 242, 242))
    draw = ImageDraw.Draw(canvas)

    for idx, file in enumerate(files):
        row = idx // args.num_col
        col = idx % args.num_col
        x0 = args.gap + col * (args.cell_width + args.gap)
        y0 = args.gap + row * (row_height + args.gap)

        image = Image.open(file).convert('RGB')
        thumb = ImageOps.contain(image, (args.cell_width, args.cell_height), method=Image.Resampling.LANCZOS)
        paste_x = x0 + (args.cell_width - thumb.width) // 2
        paste_y = y0 + (args.cell_height - thumb.height) // 2
        canvas.paste(thumb, (paste_x, paste_y))
        draw.rectangle([paste_x - 1, paste_y - 1, paste_x + thumb.width, paste_y + thumb.height], outline=(160, 160, 160), width=1)

        if args.label_mode != 'none':
            label = str(idx + 1) if args.label_mode == 'number' else file.name
            bbox = draw.textbbox((0, 0), label, font=font)
            tx = x0 + (args.cell_width - (bbox[2] - bbox[0])) // 2
            ty = y0 + args.cell_height + 4
            draw.text((tx, ty), label, font=font, fill=(0, 0, 0))

    args.output_file.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(args.output_file)
    print(args.output_file.resolve())
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
