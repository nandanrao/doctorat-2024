# .latexmkrc for the multi-chapter thesis.
# The document uses refsection=chapter (biblatex) so aux files change across
# more passes than default. Increase the limit so latexmk stabilizes.

$max_repeat = 8;

# Treat undefined references and multiply-defined labels as warnings,
# not errors, so latexmk can continue to the next pass.
$warnings_as_errors = 0;

$pdf_mode = 1;
$pdflatex = "pdflatex -interaction=nonstopmode -halt-on-error -file-line-error %O %S";

# Build everything under this jobname so the source root stays `main.tex` but
# all outputs/intermediates are `rao-thesis-2026.*` (the deliverable name).
# No `main.pdf` is ever produced. Single source of truth for the name —
# the Makefile's NAME and watch.sh must match this.
$jobname = "rao-thesis-2026";
