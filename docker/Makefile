all: noelle.tar

noelle.tar:
	cd .. && docker build -t noelle --progress=plain -f ./docker/CGO_NOELLE_dockerfile .
	docker image save -o noelle.tar noelle

open:
	docker load < noelle.tar
	docker run --rm -it noelle /bin/bash

clean:
	rm -f noelle.tar
	docker image rmi noelle
