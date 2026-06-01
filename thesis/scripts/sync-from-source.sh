#!/usr/bin/env bash
# Idempotent vendoring of paper sources into the thesis tree.
#
# Sources live in three sibling repositories under ~/Documents/. Run this
# script after upstream edits to refresh body.tex, vendored figures/tables,
# and consolidated bibs.
#
# Usage:  scripts/sync-from-source.sh [paper_number]
#         (no argument = sync all three)

set -euo pipefail

THESIS=$(cd "$(dirname "$0")/.." && pwd)
SCRIPTS="$THESIS/scripts"

DOC_HOME="${DOC_HOME:-$HOME/Documents}"

sync_paper_1() {
    local SRC="$DOC_HOME/survey-sampling-with-ads/paper"
    local DST="$THESIS/chapters/01-survey-sampling"
    echo "[sync] Paper 1: Survey Sampling"

    # Figures: consolidate two source folders into one thesis folder.
    rm -rf "$DST/figures"
    mkdir -p "$DST/figures"
    cp -a "$SRC/Figures/." "$DST/figures/"
    cp -a "$SRC/presentation/Figures/." "$DST/figures/"

    # Body: extract from \begin{document}..\end{document}, then apply paper-specific cleanup.
    awk -f "$SCRIPTS/strip-preamble.awk" "$SRC/JMR_submission_09152025.tex" \
        > "$DST/body.tex.raw"
    sed -f "$SCRIPTS/01-cleanup.sed" "$DST/body.tex.raw" > "$DST/body.tex"
    rm -f "$DST/body.tex.raw"

    # Optional local patch (small thesis-only tweaks not worth round-tripping
    # through the source repo). Apply only if it exists.
    if [ -f "$DST/body.local.patch" ]; then
        ( cd "$DST" && patch -p0 --no-backup-if-mismatch < body.local.patch )
    fi

    # Bibs: concatenate sources, then dedupe by key.
    cat "$SRC/bibs/"*.bib > "$THESIS/bibs/01-survey-sampling.bib"
    python3 "$SCRIPTS/dedupe-bib.py" "$THESIS/bibs/01-survey-sampling.bib"
}

sync_paper_2() {
    # Source is the Overleaf clone (project id 61b4f83...). The canonical current
    # manuscript is the dated MS-review file; bump this filename when a newer
    # review revision lands. The legacy ~/malaria-no-more/analysis checkout holds
    # a Nov-2022 mnm-paper.tex and must NOT be used.
    local SRC="$DOC_HOME/malaria-no-more/61b4f83ac6acdf48035f785b"
    local SRCTEX="mnm-paper-MS-review-May-2026.tex"
    local DST="$THESIS/chapters/02-malaria"
    echo "[sync] Paper 2: Malaria"

    # Round-2 (post-review) assets land in the thesis-side figures/ and tables/.
    rm -rf "$DST/figures" "$DST/tables"
    mkdir -p "$DST/figures" "$DST/tables"
    cp -a "$SRC/figures_round2/." "$DST/figures/"
    cp -a "$SRC/tables_round2/." "$DST/tables/"

    awk -f "$SCRIPTS/strip-preamble.awk" "$SRC/$SRCTEX" \
        > "$DST/body.tex.raw"
    sed -f "$SCRIPTS/02-cleanup.sed" "$DST/body.tex.raw" > "$DST/body.tex"
    rm -f "$DST/body.tex.raw"

    if [ -f "$DST/body.local.patch" ]; then
        ( cd "$DST" && patch -p0 --no-backup-if-mismatch < body.local.patch )
    fi

    # Wrap all tabular environments so tables don't overflow into margins.
    python3 "$SCRIPTS/wrap-tables.py" "$DST/tables"

    cat "$SRC/bibs/"*.bib > "$THESIS/bibs/02-malaria.bib"
    python3 "$SCRIPTS/dedupe-bib.py" "$THESIS/bibs/02-malaria.bib"
}

sync_paper_3() {
    local SRC="$DOC_HOME/vlab-research/projects/bebbo/report"
    local DST="$THESIS/chapters/03-bebbo"
    echo "[sync] Paper 3: Bebbo"

    rm -rf "$DST/images" "$DST/plots" "$DST/descriptives" "$DST/balance" "$DST/regressions"
    mkdir -p "$DST/images" "$DST/plots" "$DST/descriptives" "$DST/balance" "$DST/regressions"
    cp -a "$SRC/images/."       "$DST/images/"
    cp -a "$SRC/plots/."        "$DST/plots/"
    cp -a "$SRC/descriptives/." "$DST/descriptives/"
    cp -a "$SRC/balance/."      "$DST/balance/"
    cp -a "$SRC/regressions/."  "$DST/regressions/"

    awk -f "$SCRIPTS/strip-preamble.awk" "$SRC/bebbo.tex" > "$DST/body.tex.raw"
    sed -f "$SCRIPTS/03-cleanup.sed" "$DST/body.tex.raw" > "$DST/body.tex"
    rm -f "$DST/body.tex.raw"

    if [ -f "$DST/body.local.patch" ]; then
        ( cd "$DST" && patch -p0 --no-backup-if-mismatch < body.local.patch )
    fi

    # Wrap all tabular environments so tables don't overflow into margins.
    python3 "$SCRIPTS/wrap-tables.py" "$DST/descriptives/tables" "$DST/balance" "$DST/regressions"

    cat "$SRC/bibs/"*.bib > "$THESIS/bibs/03-bebbo.bib"
    python3 "$SCRIPTS/dedupe-bib.py" "$THESIS/bibs/03-bebbo.bib"
}

case "${1:-all}" in
    1) sync_paper_1 ;;
    2) sync_paper_2 ;;
    3) sync_paper_3 ;;
    all)
        sync_paper_1
        sync_paper_2
        sync_paper_3
        ;;
    *)
        echo "Usage: $0 [1|2|3|all]" >&2
        exit 2
        ;;
esac

echo "[sync] Done."
