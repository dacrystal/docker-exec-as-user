#/bin/bash
set -e

TARGETS=(alpine ubuntu debian centos)
IMAGE_NAME=test-docker
AS_USER=9999:8888
for target in "${TARGETS[@]}"
do
	docker build --build-arg TARGET=${target} . -t ${IMAGE_NAME} >/dev/null 2>&1
    printf "Testing ${target} -> "
    if [ "${AS_USER}" = "$( docker run --rm -e AS_USER=${AS_USER} ${IMAGE_NAME} /bin/sh -c 'echo $(id -u):$(id -g)' )" ]; then
        printf "PASSED... "
    else
        printf "FAILED... "
    fi

    printf "(mount home) -> "
    if [ "user:${AS_USER}" = "$( docker run --rm -v $PWD:/home/user/test:ro -e AS_USER=${AS_USER} ${IMAGE_NAME} /bin/sh -c 'echo $(id -un):$(id -u):$(id -g)' )" ]; then
        printf "PASSED\n"
    else
        printf "FAILED\n"
    fi
done

docker image rm -f ${IMAGE_NAME} >/dev/null 2>&1 || true