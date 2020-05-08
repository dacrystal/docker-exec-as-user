TARGET ?= alpine
TAG ?= dacrystal/exec-as-user

push:
	docker push ${TAG}

build: 
	docker build --build-arg TARGET=${TARGET} . -t ${TAG}

test:
	./docker-test.sh

clean:
	docker image rm -f ${TAG}