# Generic: extract content strictly between \begin{document} and \end{document}.
# Usage: awk -f strip-preamble.awk paper.tex > body.tex.raw

BEGIN { keep = 0 }

# Match \begin{document} (with optional leading whitespace, possibly trailing %comment)
/^[[:space:]]*\\begin\{document\}/ {
    keep = 1
    next
}

# Match \end{document}
/^[[:space:]]*\\end\{document\}/ {
    keep = 0
    next
}

keep == 1 { print }
