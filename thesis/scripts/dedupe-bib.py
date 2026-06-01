#!/usr/bin/env python3
"""De-duplicate BibTeX entries by citation key within each file, and
optionally strip troublesome fields (e.g. ``abstract``) whose contents
contain unescaped ``#`` characters that BibTeX/biblatex misreads as
parameter references.

Concatenated bib files often contain repeated keys (especially when paper 3
sources four bib files with overlapping references). This script keeps the
first occurrence of each key and drops subsequent definitions, preserving
order otherwise.

Usage: dedupe-bib.py [--strip-fields field1,field2,...] file.bib [file.bib ...]
       (rewrites each file in-place)

Default stripped fields: abstract, file, note (per the unification plan;
abstracts contain HTML entities like &#039; that BibTeX interprets as
parameter substitutions).
"""
import argparse
import re
import sys
from pathlib import Path

ENTRY_RE = re.compile(r"@([A-Za-z]+)\s*\{\s*([^,\s}]+)\s*,")

DEFAULT_STRIP = ("abstract", "file", "note")


def parse_entries(text: str):
    """Yield (header_offset, end_offset, key) for each top-level @entry."""
    for m in ENTRY_RE.finditer(text):
        start = m.start()
        key = m.group(2)
        # The opening '{' of the entry sits between '@type' and the key.
        opening = text.find("{", start, m.end())
        if opening == -1:
            continue
        depth = 1  # consumed the opening brace
        end = opening + 1
        n = len(text)
        while end < n:
            c = text[end]
            if c == "\\" and end + 1 < n:
                end += 2
                continue
            if c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    end += 1
                    break
            end += 1
        yield start, end, key


def find_field_value_end(text: str, value_start: int) -> int:
    """Given an index just after the '=' of a field, find the index just
    past the end of the value. Handles both brace-delimited ``{...}`` and
    quote-delimited ``"..."`` values, plus bare numeric/identifier values.
    Returns the index of the character immediately after the value (which
    will typically be a comma or whitespace before the next field).
    """
    # Skip whitespace
    i = value_start
    n = len(text)
    while i < n and text[i] in " \t\r\n":
        i += 1
    if i >= n:
        return i
    c = text[i]
    if c == "{":
        depth = 0
        while i < n:
            ch = text[i]
            if ch == "\\" and i + 1 < n:
                i += 2
                continue
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    return i + 1
            i += 1
        return i
    if c == '"':
        i += 1  # consume opening quote
        depth = 0
        while i < n:
            ch = text[i]
            if ch == "\\" and i + 1 < n:
                i += 2
                continue
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth = max(0, depth - 1)
            elif ch == '"' and depth == 0:
                return i + 1
            i += 1
        return i
    # Bare value: read until comma or closing brace (top level).
    while i < n and text[i] not in ",}\n":
        i += 1
    return i


def strip_fields_in_entry(entry: str, fields: set[str]) -> str:
    """Remove given fields from a single ``@type{key, ...}`` entry."""
    if not fields:
        return entry
    # Find each "  fieldname = " at top-level inside the entry.
    # Top-level means brace-depth == 1 after the entry's opening brace.
    out = []
    i = 0
    n = len(entry)
    # Skip up to (and including) the opening '{' of the entry header.
    head_brace = entry.find("{")
    if head_brace == -1:
        return entry
    out.append(entry[: head_brace + 1])
    i = head_brace + 1
    depth = 1
    # Walk the entry body, looking for field starts at depth==1.
    while i < n:
        # Match "<ws><name><ws>=" at top level (no leading comma — that
        # belongs to the previous field's separator and must be preserved
        # whether we keep or drop the current field).
        if depth == 1:
            m = re.match(r"([ \t\r\n]*)([A-Za-z][A-Za-z0-9_-]*)[ \t\r\n]*=", entry[i:])
            if m:
                name = m.group(2)
                eq_end = i + m.end()
                value_end = find_field_value_end(entry, eq_end)
                if name.lower() in fields:
                    # Drop this field. Consume the trailing comma + whitespace
                    # if present so the previous field's trailing comma still
                    # separates the surviving siblings.
                    j = value_end
                    while j < n and entry[j] in " \t\r\n":
                        j += 1
                    if j < n and entry[j] == ",":
                        j += 1
                        # Eat the whitespace after the comma too so we don't
                        # leave a blank line behind.
                        while j < n and entry[j] in " \t\r\n":
                            # Stop at the first newline so we keep one line
                            # break for readability.
                            if entry[j] == "\n":
                                j += 1
                                break
                            j += 1
                    else:
                        # No trailing comma (we are the last field). Walk
                        # backwards through `out` and trim a trailing comma
                        # from the prior field so we don't leave ",}" behind.
                        # `out` is a list; find last non-whitespace char.
                        k = len(out) - 1
                        while k >= 0 and out[k] in (" ", "\t", "\r", "\n"):
                            k -= 1
                        if k >= 0 and out[k] == ",":
                            del out[k]
                    i = j
                    continue
                else:
                    # Keep this field verbatim.
                    out.append(entry[i:value_end])
                    i = value_end
                    continue
        ch = entry[i]
        if ch == "\\" and i + 1 < n:
            out.append(entry[i : i + 2])
            i += 2
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                # End of entry; emit the rest (closing brace + tail).
                out.append(entry[i:])
                return "".join(out)
        out.append(ch)
        i += 1
    return "".join(out)


def process(path: Path, strip_fields: set[str]) -> tuple[int, int, int]:
    text = path.read_text(encoding="utf-8")
    entries = list(parse_entries(text))
    seen: set[str] = set()
    pieces: list[str] = []
    cursor = 0
    dropped = 0
    stripped = 0
    for start, end, key in entries:
        # Emit any text between previous cursor and this entry's start.
        pieces.append(text[cursor:start])
        if key in seen:
            dropped += 1
            cursor = end
            continue
        seen.add(key)
        entry_text = text[start:end]
        if strip_fields:
            new_entry = strip_fields_in_entry(entry_text, strip_fields)
            if new_entry != entry_text:
                stripped += 1
            entry_text = new_entry
        pieces.append(entry_text)
        cursor = end
    pieces.append(text[cursor:])
    new_text = "".join(pieces)
    path.write_text(new_text, encoding="utf-8")
    return len(entries), dropped, stripped


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--strip-fields",
        default=",".join(DEFAULT_STRIP),
        help="Comma-separated field names to remove from every entry "
        "(default: %(default)s). Pass an empty string to disable.",
    )
    ap.add_argument("paths", nargs="+", help="Bib files to rewrite in place.")
    args = ap.parse_args()

    raw = (args.strip_fields or "").strip()
    fields = {s.strip().lower() for s in raw.split(",") if s.strip()}

    for arg in args.paths:
        p = Path(arg)
        total, dropped, stripped = process(p, fields)
        print(
            f"{p}: {total} entries, dropped {dropped} duplicates, "
            f"stripped fields in {stripped}"
        )


if __name__ == "__main__":
    main()
