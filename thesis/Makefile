.PHONY: all clean distclean watch view sync FORCE \
        watch-intro watch-conclusion watch-sampling watch-malaria watch-bebbo

LATEXMK := latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error

# Deliverable name. Source root stays `main.tex`, but latexmk's $jobname (set
# in .latexmkrc) makes every output/intermediate `rao-thesis-2026.*` — no
# `main.pdf` is produced. This NAME must match $jobname in .latexmkrc.
NAME    := rao-thesis-2026

all: $(NAME).pdf

# Always invoke latexmk (via the FORCE prereq) and let it decide what to
# rebuild — it tracks every dependency through its .fls cache. This avoids
# listing source files in Make, some of which (the regression tables) contain
# spaces and colons that Make cannot use as prerequisites.
$(NAME).pdf: FORCE
	$(LATEXMK) main.tex

FORCE:

# Rebuild on save. Quiet output: one-line status per build (pages, warnings,
# undefined refs). Errors are printed in full. No auto-viewer — open main.pdf
# in emacs (pdf-tools auto-reverts) or run `make view`.
#
# Full build:           make watch
# Partial (faster):     make watch ONLY=00-introduction
#                       make watch ONLY=00-introduction,04-conclusion
#                       (chapter names: 00-introduction, 01-survey-sampling,
#                        02-malaria, 03-bebbo, 04-conclusion)
# Convenience targets:  make watch-intro / watch-conclusion / watch-sampling
#                                          / watch-malaria / watch-bebbo
#
# `ONLY=` uses LaTeX's \includeonly: the listed chapters are typeset; the
# others are skipped but their cross-references still resolve from .aux files
# left over from a previous full build. Run a plain `make` once first.
ONLY ?=
watch:
	./scripts/watch.sh $(if $(ONLY),--only $(ONLY))

watch-intro:      ; ./scripts/watch.sh --only 00-introduction
watch-conclusion: ; ./scripts/watch.sh --only 04-conclusion
watch-sampling:   ; ./scripts/watch.sh --only 01-survey-sampling
watch-malaria:    ; ./scripts/watch.sh --only 02-malaria
watch-bebbo:      ; ./scripts/watch.sh --only 03-bebbo

# Open the PDF in a viewer that auto-reloads. Run once alongside `make watch`.
view:
	@if command -v zathura >/dev/null; then zathura $(NAME).pdf & \
	elif command -v evince  >/dev/null; then evince  $(NAME).pdf & \
	else xdg-open $(NAME).pdf & fi

sync:
	./scripts/sync-from-source.sh

clean:
	latexmk -c
	find . -name '*.aux' -delete
	find . -name '*.bbl' -delete
	find . -name '*.bcf' -delete
	find . -name '*.blg' -delete
	find . -name '*.run.xml' -delete

distclean: clean
	latexmk -C
	rm -f main.pdf $(NAME).pdf
