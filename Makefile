
all: output output/DeveloperManual.pdf output/DeveloperManual.docx output/DeveloperManual.html

.PHONY: all install clean

CSL=oxford-university-press-scimed-author-date.csl

output:
	mkdir output
	ln -s ../figures output/figures
        
%.pdf: README.md	
	pandoc -f markdown --number-sections --filter pandoc-eqnos --filter pandoc-citeproc --bibliography references.bib --csl=$(CSL) -o $@ $<

%.docx: README.md
	pandoc -f markdown --number-sections --filter pandoc-eqnos --filter pandoc-citeproc --bibliography references.bib --csl=$(CSL) -o $@ $<

%.html: README.md
	pandoc -f markdown --number-sections --filter pandoc-eqnos --filter pandoc-citeproc --bibliography references.bib --csl=$(CSL) -o $@ $<

install:
	pip install pandoc-eqnos

clean:
	rm -r output
