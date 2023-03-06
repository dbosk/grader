.PHONY: all
all: grader.pdf

include grader.mk

.PHONY: clean
clean:
	${RM} grader.tex grader.mk
	${RM} grader.aux
	${RM} grader.fdb_latexmk
	${RM} grader.fls
	${RM} grader.log
	${RM} grader.pdf

INCLUDE_MAKEFILES=./makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk
