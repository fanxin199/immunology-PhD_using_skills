#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from pathlib import Path


def remove_path(path: Path, dry_run: bool) -> str:
    if not path.exists():
        return f"SKIP {path}"
    if dry_run:
        return f"DRY  {path}"
    if path.is_dir():
        shutil.rmtree(path, ignore_errors=True)
    else:
        path.unlink(missing_ok=True)
    return f"DEL  {path}"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Delete intermediate files or directories produced during paper-presentation work."
    )
    parser.add_argument("paths", nargs="+", type=Path, help="Files or directories to remove")
    parser.add_argument("--dry-run", action="store_true", help="Print what would be removed")
    args = parser.parse_args()

    for raw_path in args.paths:
        print(remove_path(raw_path.resolve(), args.dry_run))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())