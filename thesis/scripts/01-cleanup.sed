# Paper-1 (Survey Sampling) cleanup, applied after strip-preamble.awk.
#
# Goals:
#   1. Strip submission-only scaffolding (\maketitle, abstract, spacing commands,
#      \printbibliography, appendix re-numbering hacks, JMR Funding/Competing).
#   2. Convert \section*{...} → \section{...} so headings appear in the TOC under
#      the chapter (book class numbers them 2.1, 2.2, ...).
#   3. Rewrite asset paths from source-repo-relative to thesis-relative.
#
# GNU sed BRE: literal { and } are NOT escaped. Use \{ \} only inside an
# interval expression like \{2,5\}. Parens for groups: \( \).

# --- 1. Strip submission scaffolding --------------------------------------

# Single-line directives
/^\\maketitle/d
/^\\date{/d
/^\\doublespacing/d
/^\\singlespacing/d
/^\\printbibliography/d
/^\\appendix/d

# Appendix counter / numbering hacks (book class handles per-chapter numbering)
/^\\setcounter{figure}/d
/^\\renewcommand{\\thefigure}/d
/^\\renewcommand{\\theHfigure}/d
/^\\renewcommand{\\thetable}/d
/^\\renewcommand{\\theHtable}/d
/^\\label{appendix:A}/d

# Paper-level abstract: redundant with thesis-level frontmatter abstract.
/\\begin{abstract}/,/\\end{abstract}/d

# JMR-specific Funding & Competing Interests block (heading + paragraph).
/^\\section\*{\\normalsize Funding/,/paid services\./d

# Standalone empty appendix opener (immediately followed by a real subsection
# in the source: \section*{Survey Platform and Recruitment Material}).
/^\\section\*{Appendix}/d

# --- 2. Convert starred sections to numbered ------------------------------
# Order matters: most specific first.
s/\\subsubsection\*{/\\subsubsection{/g
s/\\subsection\*{/\\subsection{/g
s/\\section\*{/\\section{/g

# --- 3. Path rewrites -----------------------------------------------------
# Two source folders consolidate into one thesis folder.
s|\\includegraphics\[\([^]]*\)\]{presentation/Figures/|\\includegraphics[\1]{chapters/01-survey-sampling/figures/|g
s|\\includegraphics\[\([^]]*\)\]{Figures/|\\includegraphics[\1]{chapters/01-survey-sampling/figures/|g
