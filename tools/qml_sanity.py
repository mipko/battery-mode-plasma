#!/usr/bin/env python3
import sys
from pathlib import Path

PAIRS = {")": "(", "]": "[", "}": "{"}
OPENERS = set(PAIRS.values())


def check(path: Path):
    text = path.read_text(encoding="utf-8")
    stack = []
    i = 0
    line = 1
    col = 0
    state = "code"
    quote = None

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if ch == "\n":
            line += 1
            col = 0
        else:
            col += 1

        if state == "line_comment":
            if ch == "\n":
                state = "code"
            i += 1
            continue

        if state == "block_comment":
            if ch == "*" and nxt == "/":
                state = "code"
                i += 2
                col += 1
                continue
            i += 1
            continue

        if state == "string":
            if ch == "\\":
                i += 2
                col += 1
                continue
            if ch == quote:
                state = "code"
                quote = None
            i += 1
            continue

        if ch == "/" and nxt == "/":
            state = "line_comment"
            i += 2
            col += 1
            continue

        if ch == "/" and nxt == "*":
            state = "block_comment"
            i += 2
            col += 1
            continue

        if ch in ("'", '"'):
            state = "string"
            quote = ch
            i += 1
            continue

        if ch in OPENERS:
            stack.append((ch, line, col))
        elif ch in PAIRS:
            if not stack or stack[-1][0] != PAIRS[ch]:
                raise SystemExit(
                    f"{path}: unmatched {ch!r} at line {line}, column {col}"
                )
            stack.pop()

        i += 1

    if state == "string":
        raise SystemExit(f"{path}: unterminated string")
    if state == "block_comment":
        raise SystemExit(f"{path}: unterminated block comment")
    if stack:
        ch, line, col = stack[-1]
        raise SystemExit(
            f"{path}: unclosed {ch!r} opened at line {line}, column {col}"
        )


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: qml_sanity.py FILE.qml [...]")
    for arg in sys.argv[1:]:
        check(Path(arg))
    print(f"QML delimiter/string sanity: PASS ({len(sys.argv)-1} files)")


if __name__ == "__main__":
    main()
