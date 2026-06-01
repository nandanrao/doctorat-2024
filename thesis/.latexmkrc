# .latexmkrc for the multi-chapter thesis.
# The document uses refsection=chapter (biblatex) so aux files change across
# more passes than default. Increase the limit so latexmk stabilizes.

$max_repeat = 8;

# Treat undefined references and multiply-defined labels as warnings,
# not errors, so latexmk can continue to the next pass.
$warnings_as_errors = 0;

$pdf_mode = 1;
$pdflatex = "pdflatex -interaction=nonstopmode -halt-on-error -file-line-error %O %S";
