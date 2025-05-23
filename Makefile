DOCKER_BUILD_OPTS=--no-cache
DOCKER_BUILDX_OPTS=--no-cache

.PHONY: all
all: grader.pdf

ladok.sh Dockerfile.ladok: grader.nw
	${NOTANGLE}

.PHONY: clean-detailed-examples
clean: clean-detailed-examples
clean-detailed-examples:
	${RM} ladok.sh Dockerfile.ladok
grader.sh: grader.nw

.PHONY: clean-grader-script
clean: clean-grader-script
clean-grader-script:
	${RM} grader.sh
.INTERMEDIATE: grader.tex
grader.pdf: grader.nw
	${NOWEAVE.pdf}
.PHONY: clean-pdf
clean: clean-pdf
clean-pdf:
	${RM} grader.tex grader.mk
	${RM} grader.aux
	${RM} grader.fdb_latexmk
	${RM} grader.fls
	${RM} grader.log
	${RM} grader.pdf
Dockerfile: grader.nw
	${NOTANGLE}

.PHONY: clean clean-docker
clean: clean-docker
clean-docker:
	${RM} Dockerfile

IMAGE_TARGET=   dbosk/grader
IMAGE_TAG=      $(shell date +%Y%m%d-%H%M)

.PHONY: all
all: ${IMAGE_TARGET}

.PHONY: ${IMAGE_TARGET}
${IMAGE_TARGET}: Dockerfile
	docker build ${DOCKER_BUILD_OPTS} -t $@ .

.PHONY: distclean distclean-docker
distclean: distclean-docker
distclean-docker:
	-docker image rm -f ${IMAGE_TARGET}
	-docker image rm -f ${IMAGE_TARGET}:${IMAGE_TAG}
	-docker image rm -f ${IMAGE_TARGET}:latest
	docker system prune

.PHONY: publish
publish: ${IMAGE_TARGET}
	docker buildx build ${DOCKER_BUILDX_OPTS} --push \
	  --platform linux/amd64,linux/arm64 \
		-t ${IMAGE_TARGET}:${IMAGE_TAG} .
	docker buildx build --push --platform linux/amd64,linux/arm64 \
		-t ${IMAGE_TARGET}:latest .
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
.PHONY: multiplatform-setup
multiplatform-setup:
	sudo mkdir -m 0755 -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
	  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	(echo -n "deb [arch=$(dpkg --print-architecture)"; \
	 echo -n " signed-by=/etc/apt/keyrings/ docker.gpg]"; \
	 echo -n " https://download.docker.com/linux/ubuntu"; \
	 echo    " $(lsb_release -cs) stable") \
	  | sudo tee /etc/apt/sources.list.d/docker.list > /dev /null
	sudo apt update
	sudo apt install docker-ce
	docker run --rm --privileged \
	  linuxkit/binfmt:ecd24b710cad869af6a4716809f62d7164286367
	docker buildx create --use --name multiplatform-builder

.PHONY: clean
clean:

.PHONY: distclean
distclean:

INCLUDE_MAKEFILES=./makefiles
include ${INCLUDE_MAKEFILES}/noweb.mk

Makefile: grader.nw
	${NOTANGLE.mk}
