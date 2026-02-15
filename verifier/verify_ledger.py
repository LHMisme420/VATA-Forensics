#!/usr/bin/env python3
"""
verifier/verify_ledger.py

Robust JSONL ledger verifier:
- Reads JSON lines (one JSON object per line).
- Handles UTF-8 BOM safely via encoding="utf-8-sig".
- Skips blank/whitespace-only lines.
- Validates each line is valid JSON object (dict).
- Optional: ensures required keys exist (set REQUIRED_KEYS).
- Exits non-zero on first failure (CI-friendly).

Usage:
  python verifier/verify_ledger.py
  python verifier/verify_ledger.py --ledger path/to/ledger.jsonl
  python verifier/verify_ledger.py --strict

Environment:
  LEDGER_PATH can be used as default ledger path if --ledger not provided.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, Optional, Tuple


# If you want to enforce schema, add keys here (example shown, disabled by default).
REQUIRED_KEYS: Tuple[str, ...] = tuple()  # e.g. ("ts", "event", "hash")


def eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def iter_jsonl(path: Path) -> Iterable[Dict[str, Any]]:
    """
    Iterate JSON objects from a JSONL file.
    - Uses utf-8-sig to strip BOM if present.
    - Skips blank lines.
    - Raises ValueError with line number on parse errors.
    """
    if not path.exists():
        raise FileNotFoundError(f"Ledger file not found: {path}")

    # utf-8-sig strips BOM if present; also safe if not present.
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        for lineno, raw in enumerate(f, start=1):
            line = raw.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError as ex:
                # Include a small preview to help debugging but avoid huge logs
                preview = line[:200]
                raise ValueError(
                    f"JSON decode error at {path}:{lineno}: {ex.msg} (pos {ex.pos}). "
                    f"Line preview: {preview!r}"
                ) from ex

            if not isinstance(obj, dict):
                raise ValueError(
                    f"Invalid entry at {path}:{lineno}: expected JSON object, got {type(obj).__name__}"
                )
            yield obj


def validate_entry(entry: Dict[str, Any], strict: bool, idx: int) -> None:
    """
    Basic validation hook.
    - If REQUIRED_KEYS is set, enforces presence.
    - In --strict mode, enforces all values are JSON-serializable (they should be),
      and rejects empty objects.
    """
    if REQUIRED_KEYS:
        missing = [k for k in REQUIRED_KEYS if k not in entry]
        if missing:
            raise ValueError(f"Entry #{idx} missing required keys: {missing}")

    if strict:
        if not entry:
            raise ValueError(f"Entry #{idx} is empty object, strict mode disallows this")
        # Ensure the object can be re-serialized as JSON (sanity)
        try:
            json.dumps(entry, separators=(",", ":"), ensure_ascii=False)
        except (TypeError, ValueError) as ex:
            raise ValueError(f"Entry #{idx} is not JSON-serializable: {ex}") from ex


def find_default_ledger(repo_root: Path) -> Optional[Path]:
    """
    Try to find a reasonable default ledger file.
    Priority:
      1) LEDGER_PATH env var
      2) common filenames in verifier/ or repo root
    """
    env = os.environ.get("LEDGER_PATH")
    if env:
        return Path(env).expanduser()

    candidates = [
        repo_root / "verifier" / "ledger.jsonl",
        repo_root / "verifier" / "ledger.ndjson",
        repo_root / "verifier" / "ledger.log",
        repo_root / "ledger.jsonl",
        repo_root / "ledger.ndjson",
        repo_root / "ledger.log",
    ]
    for c in candidates:
        if c.exists():
            return c
    return None


def main() -> int:
    ap = argparse.ArgumentParser(description="Verify JSONL ledger integrity (parse + sanity checks).")
    ap.add_argument(
        "--ledger",
        "-l",
        default=None,
        help="Path to ledger JSONL/NDJSON file. If omitted, uses LEDGER_PATH or common defaults.",
    )
    ap.add_argument(
        "--strict",
        action="store_true",
        help="Enable stricter validation (reject empty objects, require JSON-serializable values).",
    )
    args = ap.parse_args()

    # Assume this script lives at repo_root/verifier/verify_ledger.py
    script_path = Path(__file__).resolve()
    repo_root = script_path.parent.parent

    ledger_path = Path(args.ledger).expanduser() if args.ledger else find_default_ledger(repo_root)
    if ledger_path is None:
        eprint("ERROR: No ledger file specified and no default ledger found.")
        eprint("Provide --ledger <path> or set LEDGER_PATH env var.")
        return 2

    try:
        count = 0
        for count, entry in enumerate(iter_jsonl(ledger_path), start=1):
            validate_entry(entry, strict=args.strict, idx=count)

        if count == 0:
            eprint(f"ERROR: Ledger is empty (no JSON objects found): {ledger_path}")
            return 3

        print(f"OK: Ledger parsed and validated: {ledger_path} (entries={count})")
        return 0

    except Exception as ex:
        eprint(f"FAIL: {ex}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
