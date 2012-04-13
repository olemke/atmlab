TARGET=collocations

.PHONY: ${TARGET}.pdf
#${TARGET}.ps: ${TARGET}.dvi ${TARGET}.tex 
#	dvips ${TARGET}.dvi -o ${TARGET}.ps

${TARGET}.pdf: ${TARGET}.tex
	pdflatex -shell-escape -halt-on-error ${TARGET}
	bibtex ${TARGET}
	pdflatex -shell-escape -halt-on-error ${TARGET}
	pdflatex -shell-escape -halt-on-error ${TARGET}
clean:
	rm -f ${TARGET}.pdf ${TARGET}.aux ${TARGET}.log ${TARGET}.blg ${TARGET}.bbl ${TARGET}.nav ${TARGET}.snm ${TARGET}.toc ${TARGET}.out ${TARGET}.log


