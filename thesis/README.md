# PhD Thesis -- Nandan Rao

Compendium of three papers:

1. **Adaptive Survey Sampling via Ad Platforms** (Donati & Rao, JMR submission Sept 2025)
2. **Facebook Ads vs. Malaria** (Rao, Donati, Orozco-Olvera, Muñoz-Boudet)
3. **Impact Evaluation of UNICEF's Bebbo Parenting App** (Rao & Kisbu)

Plus an integrative introduction and conclusion.

## Build

```
latexmk -pdf main.tex
# or
make
```

For incremental work on a single chapter, uncomment `\includeonly{...}` in `main.tex`.

## Sync paper sources

The three paper bodies are vendored from neighbouring repos under `~/Documents/`. After upstream edits:

```
make sync   # or: ./scripts/sync-from-source.sh
```

## Layout

- `main.tex` -- master, includes preamble + chapters
- `preamble.tex` -- shared union preamble (packages, biblatex, hyperref)
- `frontmatter/` -- title page, abstracts, acknowledgments, coauthor statements, TOC
- `chapters/` -- intro, three paper chapters (each with its own `body.tex` and assets), conclusion
- `bibs/` -- per-chapter consolidated bibliographies
- `scripts/` -- sync-from-source.sh and helpers

See `~/.claude/plans/i-think-b-is-optimized-catmull.md` for the design rationale.
