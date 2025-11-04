#!/usr/bin/env python3
"""Fail if the repository contains binary files.

This helper enumerates all tracked files via `git ls-files` and ensures each
can be decoded as UTF-8 text. Files containing NUL bytes or invalid UTF-8
sequences are considered binary and will cause the script to exit with status 1.

Usage: python tool/check_no_binary.py
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def iter_tracked_files() -> list[Path]:
    result = subprocess.run(
        ["git", "ls-files"],
        check=True,
        capture_output=True,
        text=True,
    )
    root = Path.cwd()
    return [root / line.strip() for line in result.stdout.splitlines() if line.strip()]


def find_binary_files(paths: list[Path]) -> list[Path]:
    binary_files: list[Path] = []
    for path in paths:
        data = path.read_bytes()
        if b"\x00" in data:
            binary_files.append(path)
            continue
        try:
            data.decode("utf-8")
        except UnicodeDecodeError:
            binary_files.append(path)
    return binary_files


def main() -> int:
    paths = iter_tracked_files()
    binary_files = find_binary_files(paths)
    if binary_files:
        print("Binary files detected (unsupported):", file=sys.stderr)
        for path in binary_files:
            print(f" - {path.relative_to(Path.cwd())}", file=sys.stderr)
        return 1
    print("No binary files detected.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
