# Paper-3 (Bebbo) cleanup, applied after strip-preamble.awk.
#
# Goals:
#   1. Strip submission-only scaffolding (\maketitle, abstract block,
#      \printbibliography, \appendix).
#   2. Rewrite asset paths from source-repo-relative to thesis-relative.
#
# Note: \title/\author/\date are in paper 3's preamble, so strip-preamble.awk
# already removes them.
#
# GNU sed BRE: literal { and } are NOT escaped. Use \( \) for groups.
# Path values may contain spaces and colons (e.g.
# "Reliability: Pooled Alpha Matrix") — we use [^}]* inside the input/graphic
# argument to match anything up to the closing brace.

# --- 1. Strip submission scaffolding --------------------------------------
/^\\maketitle/d
/^\\printbibliography/d
/^\\appendix/d

# Paper-level abstract: redundant with thesis-level frontmatter abstract.
/\\begin{abstract}/,/\\end{abstract}/d

# --- 2. Path rewrites -----------------------------------------------------
# All five top-level asset trees are prefixed with chapters/03-bebbo/.
# We use a "match the prefix only" strategy so spaces, colons, and other
# punctuation in filenames pass through untouched.

# \input{<dir>/...}
s|\\input{images/|\\input{chapters/03-bebbo/images/|g
s|\\input{plots/|\\input{chapters/03-bebbo/plots/|g
s|\\input{descriptives/|\\input{chapters/03-bebbo/descriptives/|g
s|\\input{balance/|\\input{chapters/03-bebbo/balance/|g
s|\\input{regressions/|\\input{chapters/03-bebbo/regressions/|g

# \includegraphics[opts]{<dir>/...}
s|\\includegraphics\(\[[^]]*\]\){images/|\\includegraphics\1{chapters/03-bebbo/images/|g
s|\\includegraphics\(\[[^]]*\]\){plots/|\\includegraphics\1{chapters/03-bebbo/plots/|g
s|\\includegraphics\(\[[^]]*\]\){descriptives/|\\includegraphics\1{chapters/03-bebbo/descriptives/|g
s|\\includegraphics\(\[[^]]*\]\){balance/|\\includegraphics\1{chapters/03-bebbo/balance/|g
s|\\includegraphics\(\[[^]]*\]\){regressions/|\\includegraphics\1{chapters/03-bebbo/regressions/|g

# \includegraphics{<dir>/...} (no optional argument)
s|\\includegraphics{images/|\\includegraphics{chapters/03-bebbo/images/|g
s|\\includegraphics{plots/|\\includegraphics{chapters/03-bebbo/plots/|g
s|\\includegraphics{descriptives/|\\includegraphics{chapters/03-bebbo/descriptives/|g
s|\\includegraphics{balance/|\\includegraphics{chapters/03-bebbo/balance/|g
s|\\includegraphics{regressions/|\\includegraphics{chapters/03-bebbo/regressions/|g
