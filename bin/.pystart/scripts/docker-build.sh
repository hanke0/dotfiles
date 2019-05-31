#!/usr/bin/env bash

set -e

PACKAGE=example
[[ -n $1 ]] && DOCKER_HUB_URL=$1
[[ -n $2  ]] && DOCKER_IMAGE_TAG=$2

error-exit() {
   >&2 echo $1 && echo "
Usage: $0 [<docker-hub-url>] [<docker-image-tag>]

environment:
    DOCKER_HUB_URL     transfer as <docker-hub-url>
    DOCKER_IMAGE_TAG   transfer as <docker-image-tag>

note:
    if 'DOCKER_IMAGE_TAG' is not set, default package version will be set as docker image tag.
"
   exit 1
}

echo-around() {
    local n=$((${#1} + 6))
    echo
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo '* ' $1 ' *'
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo
}

[[ -z ${DOCKER_HUB_URL} ]] && error-exit 'empty docker-hub-url, use environment 'DOCKER_HUB_URL' or positional argument.'


PACKAGE_VERSION=$(grep -o -E "__version__ ?= ?[\'\"].+[\'\"]" ${PACKAGE//-/_}/__init__.py  | awk -F= '{print $2}' | sed s/\"//g | sed s/\'//g | sed s/\ //g)

[[ -z ${DOCKER_IMAGE_TAG} ]] && DOCKER_IMAGE_TAG=${PACKAGE_VERSION}

DOCKER_IMAGE="${DOCKER_HUB_URL}/${PACKAGE}:${DOCKER_IMAGE_TAG}"

echo-around "START BUILD: ${DOCKER_IMAGE}"

docker build --build-arg PACKAGE_VERSION=${PACKAGE_VERSION} -t ${DOCKER_IMAGE} .

docker push ${DOCKER_IMAGE}

echo-around "FINISH: ${DOCKER_IMAGE}"
