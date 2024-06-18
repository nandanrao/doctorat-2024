(TeX-add-style-hook
 "discussion"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("beamer" "aspectratio=169")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("biblatex" "backend=biber" "citestyle=authoryear" "bibencoding=utf8")))
   (add-to-list 'LaTeX-verbatim-environments-local "semiverbatim")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "beamer"
    "beamer10"
    "appendixnumberbeamer"
    "caption"
    "subcaption"
    "biblatex"
    "graphicx"
    "booktabs"
    "accents"
    "stmaryrd"
    "pgfplots"
    "tabularx"
    "amssymb"
    "amsmath"
    "algorithm"
    "algpseudocode"
    "siunitx")
   (TeX-add-symbols
    '("fnote" 1)
    '("ubar" 1)
    "starnote"
    "argmin")
   (LaTeX-add-bibliographies
    "../bibs/vlab-report"
    "../bibs/unicef-ie"
    "../bibs/unicef-additions"
    "../bibs/early-childhood-parenting")
   (LaTeX-add-array-newcolumntypes
    "Y"
    "K"
    "P"))
 :latex)

