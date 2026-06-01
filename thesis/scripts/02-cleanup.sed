# Paper-2 (Malaria) cleanup, applied after strip-preamble.awk.
# Target source: mnm-paper-MS-review-May-2026.tex (Overleaf clone).
#
# Goals:
#   1. Strip submission-only scaffolding that lives INSIDE \begin{document}
#      (title block, abstract, geometry/spacing, bibliography call, appendix
#      re-title) so it does not fight the thesis book class or reprint titles.
#   2. Rewrite round-2 asset paths from source-repo-relative to thesis-relative.
#
# Note: unlike the 2022 source, \title/\date/\maketitle sit AFTER
# \begin{document}, so strip-preamble.awk does NOT remove them — we do it here.
#
# GNU sed BRE: literal { and } are NOT escaped. Use \( \) for groups.

# --- 1. Strip submission scaffolding --------------------------------------
# Title block: \title{...\thanks{...}} spans many lines; delete through \maketitle.
/^\\title{/,/^\\maketitle/d

# Paper-level abstract: redundant with thesis-level frontmatter abstract.
/\\begin{abstract}/,/\\end{abstract}/d

# Geometry/spacing overrides that conflict with the book class.
/^\\newgeometry{/d
/^\\restoregeometry/d
/^\\singlespacing/d
/^\\onehalfspacing/d

# Bibliography: the thesis emits a per-chapter biblatex bibliography in chapter.tex.
/^\\bibliography{/d
/^\\printbibliography/d

# Appendix scaffolding: drop \appendix, the page-counter reset, and the centered
# block that reprints the paper title under an "Appendix" heading.
/^\\appendix/d
/^\\setcounter{page}{1}/d
/^{\\centering/,/^}/d
/^\\section\*{Appendix}/d

# --- 1b. Namespace appendix labels ----------------------------------------
# Paper 1 and paper 2 both label an appendix section appendix:C; \label is
# global, so prefix paper 2's appendix labels/refs to avoid a clash.
s|{appendix:|{mal-appendix:|g

# --- 2. Path rewrites -----------------------------------------------------
# Source references only *_round2/ assets; they are vendored into the thesis
# chapter's figures/ and tables/.
s|\\input{\(\./\)\?tables_round2/|\\input{chapters/02-malaria/tables/|g
s|\\includegraphics\[\([^]]*\)\]{\(\./\)\?figures_round2/|\\includegraphics[\1]{chapters/02-malaria/figures/|g
s|\\includegraphics{\(\./\)\?figures_round2/|\\includegraphics{chapters/02-malaria/figures/|g

# Defensive fallbacks for any non-round2 paths (none in the May-2026 source).
s|\\input{\./tables/|\\input{chapters/02-malaria/tables/|g
s|\\input{tables/|\\input{chapters/02-malaria/tables/|g
s|\\includegraphics\[\([^]]*\)\]{\./figures/|\\includegraphics[\1]{chapters/02-malaria/figures/|g
s|\\includegraphics\[\([^]]*\)\]{figures/|\\includegraphics[\1]{chapters/02-malaria/figures/|g
s|\\includegraphics{\./figures/|\\includegraphics{chapters/02-malaria/figures/|g
s|\\includegraphics{figures/|\\includegraphics{chapters/02-malaria/figures/|g
