#!/usr/bin/env bash
#
# mendeley-sync.sh — triage helper for the Mendeley -> curated bib pipeline.
#
# Mendeley exports to bibs/mendeley-intro-conclusion.bib (RAW staging input,
# intentionally NOT \addbibresource'd in preamble.tex). Cleaned entries are
# copied from there into bibs/intro-conclusion.bib (the curated, LaTeX-loaded
# bib), keeping the same citation keys.
#
# This script does NOT write anything — cleaning is a judgement step (fixing
# scraped titles, adding DOIs, correcting years). It just tells you:
#   1. duplicate keys across the bibs LaTeX actually loads,
#   2. which raw staging entries are NEW (need cleaning in) vs already curated,
#   3. obvious scrape artifacts in the raw entries to fix while cleaning.
#
# Usage:  bash scripts/mendeley-sync.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

STAGING="bibs/mendeley-intro-conclusion.bib"
CURATED="bibs/intro-conclusion.bib"

# Loaded bibs = those \addbibresource'd in preamble.tex. The staging file is
# excluded by design (it is not registered there), so this list derives the
# "what LaTeX sees" set automatically.
mapfile -t LOADED < <(grep -oE '\\addbibresource\{[^}]+\}' preamble.tex \
                      | sed -E 's/.*\{(.*)\}/\1/')

echo "== Loaded bibs (from preamble.tex) =="
printf '  %s\n' "${LOADED[@]}"

echo
echo "== Duplicate keys across loaded bibs =="
dups="$(cat "${LOADED[@]}" | grep -oE '^@[a-zA-Z]+\{[^,]+' | sed 's/.*{//' \
        | sort | uniq -d)"
if [ -z "$dups" ]; then
  echo "  (none)"
else
  # For each dup, show which loaded files contain it.
  while IFS= read -r k; do
    files="$(grep -lE "^@[a-zA-Z]+\{${k}," "${LOADED[@]}" | sed 's#^bibs/##' | paste -sd', ' -)"
    printf '  DUP %-18s in: %s\n' "$k" "$files"
  done <<< "$dups"
  echo "  (benign if the copies are identical; risk is log noise + silent drift if one is edited)"
fi

echo
echo "== Mendeley staging triage ($STAGING) =="
if [ ! -f "$STAGING" ]; then
  echo "  (no staging file present)"
  exit 0
fi

curated_keys="$(grep -oE '^@[a-zA-Z]+\{[^,]+' "$CURATED" | sed 's/.*{//')"

# Other loaded bibs (everything LaTeX loads except the curated target). A staging
# key already present here is owned elsewhere — do NOT clean it into the curated
# bib or you re-create a duplicate-key collision.
OTHER=()
for b in "${LOADED[@]}"; do [ "$b" = "$CURATED" ] || OTHER+=("$b"); done

# Emit "key<TAB>doi|NODOI<TAB>title-line" for each staging entry.
awk '
  function emit() { printf "%s\t%s\t%s\n", key, (doi?"doi":"NODOI"), title }
  /^@/ { if (key!="") emit(); key=$0; sub(/^@[a-zA-Z]+\{/,"",key); sub(/,.*/,"",key); doi=0; title="" }
  /^[ \t]*doi[ \t]*=/  { doi=1 }
  /^[ \t]*title[ \t]*=/ { title=$0 }
  END { if (key!="") emit() }
' "$STAGING" \
| while IFS=$'\t' read -r key hasdoi title; do
    if grep -qxF "$key" <<< "$curated_keys"; then
      status="in-curated"
    elif owner="$(grep -lE "^@[a-zA-Z]+\{${key}," "${OTHER[@]}" 2>/dev/null | head -1)"; [ -n "$owner" ]; then
      status="owned:$(basename "$owner")"   # already in another loaded bib — leave it there
    else
      status="NEW"                          # genuinely needs cleaning into curated
    fi
    flags=""
    [ "$hasdoi" = "NODOI" ] && flags="$flags missing-doi"
    grep -qiE 'corresponding author|open access articles|mit open' <<< "$title" && flags="$flags junk-title"
    grep -qE ' , ' <<< "$title" && flags="$flags spaced-punct"
    printf '  %-18s %-22s%s\n' "$key" "$status" "${flags:+ flags:$flags}"
  done

echo
echo "Legend: in-curated = done | owned:FILE = already in another loaded bib, do NOT"
echo "re-add (collision) | NEW = clean into $CURATED keeping the same key."
