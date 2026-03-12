from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from pdf2image import convert_from_path

LO_CANDIDATES = [
    Path(r"C:\Program Files\LibreOffice\program\soffice.exe"),
    Path(r"C:\Program Files\LibreOffice\program\soffice.com"),
    Path(r"C:\Program Files (x86)\LibreOffice\program\soffice.exe"),
]
POPPLER_CANDIDATES = [
    Path(r"C:\Users\yunfe\miniconda3\Library\bin"),
]


def find_existing(candidates: list[Path], label: str) -> Path:
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError(f"Could not find {label}. Checked: {candidates}")


def convert_to_pdf(input_path: Path, work_root: Path) -> Path:
    if input_path.suffix.lower() == ".pdf":
        return input_path

    soffice = find_existing(LO_CANDIDATES, "LibreOffice soffice")
    profile_dir = work_root / "soffice_profile"
    pdf_dir = work_root / "pdf"
    shutil.rmtree(profile_dir, ignore_errors=True)
    shutil.rmtree(pdf_dir, ignore_errors=True)
    profile_dir.mkdir(parents=True, exist_ok=True)
    pdf_dir.mkdir(parents=True, exist_ok=True)

    profile_uri = profile_dir.resolve().as_uri()
    cmd = [
        str(soffice),
        f"-env:UserInstallation={profile_uri}",
        "--headless",
        "--norestore",
        "--convert-to",
        "pdf",
        "--outdir",
        str(pdf_dir),
        str(input_path.resolve()),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    pdf_path = pdf_dir / f"{input_path.stem}.pdf"
    if not pdf_path.exists():
        raise RuntimeError(
            "LibreOffice failed to produce PDF.\n"
            f"stdout:\n{result.stdout}\n\n"
            f"stderr:\n{result.stderr}"
        )
    return pdf_path


def render_pdf(pdf_path: Path, output_dir: Path, dpi: int) -> None:
    poppler_bin = find_existing(POPPLER_CANDIDATES, "Poppler bin directory")
    shutil.rmtree(output_dir, ignore_errors=True)
    output_dir.mkdir(parents=True, exist_ok=True)

    images = convert_from_path(
        str(pdf_path.resolve()),
        dpi=dpi,
        fmt="png",
        poppler_path=str(poppler_bin.resolve()),
    )
    for idx, image in enumerate(images, start=1):
        target = output_dir / f"slide-{idx}.png"
        image.save(target, "PNG")
    print(f"Rendered {len(images)} slide(s) to {output_dir}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Render PPTX or PDF to slide PNGs on Windows.")
    parser.add_argument("input_path", type=Path)
    parser.add_argument("--output_dir", type=Path, required=True)
    parser.add_argument("--dpi", type=int, default=144)
    args = parser.parse_args()

    input_path = args.input_path.resolve()
    if not input_path.exists():
        raise FileNotFoundError(input_path)

    work_root = Path(tempfile.gettempdir()) / "codex_render_work" / input_path.stem
    work_root.mkdir(parents=True, exist_ok=True)
    pdf_path = convert_to_pdf(input_path, work_root)
    render_pdf(pdf_path, args.output_dir.resolve(), args.dpi)
    return 0


if __name__ == "__main__":
    sys.exit(main())
