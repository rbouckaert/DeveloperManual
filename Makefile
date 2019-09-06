
all: DeveloperManual.pdf DeveloperManual.docx DeveloperManual.html

.PHONY: all install clean

CSL=oxford-university-press-scimed-author-date.csl


%.pdf: README.md
	pandoc -f markdown --number-sections --filter pandoc-eqnos --filter pandoc-citeproc --bibliography references.bib --csl=$(CSL) -o output/$@ $<

%.docx: README.md
	pandoc -f markdown --number-sections --filter pandoc-eqnos --filter pandoc-citeproc --bibliography references.bib --csl=$(CSL) -o output/$@ $<

%.html: README.md
	pandoc -f markdown --number-sections --filter pandoc-eqnos --filter pandoc-citeproc --bibliography references.bib --csl=$(CSL) -o output/$@ $<

install:
	pip install pandoc-eqnos

clean:
	rm output/*.pdf output/*.docx output/*.html
