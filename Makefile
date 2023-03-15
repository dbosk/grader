.PHONY: all
all: grader.pdf

.INTERMEDIATE: grader.tex
grader.pdf: grader.nw
	${NOWEAVE.pdf}

IMAGE_TARGET=   grader

.PHONY: all
all: ${IMAGE_TARGET}

.PHONY: ${IMAGE_TARGET}
${IMAGE_TARGET}: Dockerfile
	docker build -t $@ .

Dockerfile: grader.nw
	${NOTANGLE}

.PHONY: clean clean-docker
clean: clean-docker
clean-docker:
	${RM} Dockerfile

.PHONY: distclean distclean-docker
distclean: distclean-docker
distclean-docker:
	-docker image rm -f ${IMAGE_TARGET}

config: ${HOME}/.ssh/config
	${CP} $^ $@
	${EDITOR} $@

${IMAGE_TARGET}: config
${IMAGE_TARGET}: bashrc
bashrc: grader.nw
	${NOTANGLE.sh}
.PHONY: clean-ssh
clean: clean-ssh

clean-ssh:
	${RM} config

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
