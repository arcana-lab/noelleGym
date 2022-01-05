DOCKER := $(shell command -v docker 2> /dev/null)
PODMAN := $(shell command -v podman 2> /dev/null)

ifdef PODMAN
	d := podman
else
	d := docker
endif

all: noelle.tar

noelle.tar:
	cd .. && $(d) build -t noelle --progress=plain -f ./docker/CGO_NOELLE_dockerfile .
	$(d) image save -o noelle.tar noelle

open:
	$(d) load < noelle.tar
	$(d) run --rm -it noelle /bin/bash

clean:
	rm -f noelle.tar
	$(d) image rmi noelle
