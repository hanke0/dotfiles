#!/usr/bin/env bash
set -e

PACKAGE=example
HERE=$(dirname "$0")
PROJECT_ROOT=$(dirname ${HERE})
MODULE=${PACKAGE//-/_}
MODULE_UPPER=$(echo ${MODULE} | tr '[:lower:]' '[:upper:]')
CONFIG=${MODULE_UPPER}_CONFIG

VERSION_FILE=${PROJECT_ROOT}/${MODULE}/__init__.py
VERSION_REGEX='__version__ = "(.*)"'
VERSION_TEMP_FILE="${VERSION_FILE}abc"
export TWINE_REPOSITORY_URL=
export TWINE_USERNAME=
export TWINE_PASSWORD=

striking-print() {
    local s="$*"
    local n=$((${#s} + 6))
    echo
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo '* ' ${s} ' *'
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo
}

if [[ $(grep -E -o "${VERSION_REGEX}" "${VERSION_FILE}") =~ ${VERSION_REGEX} ]]; then
    VERSION_BASE=${BASH_REMATCH[1]}
else
    >&2 echo "can't found version"
    exit 1
fi

VERSION_SUFFIX="a0"
GIT_TAG=$(git log --pretty=%h -1)
VERSION="${VERSION_BASE}${VERSION_SUFFIX}+${GIT_TAG}"

DOCKER_NAME=${PACKAGE}
DOCKER_FILE_PATH=${PROJECT_ROOT}
DOCKER_HUB=hub.docker.com
DOCKER_TAG="${DOCKER_HUB}/${DOCKER_NAME}:${VERSION_BASE}${VERSION_SUFFIX}.${GIT_TAG}"

update-version() {
    sed -iabc -e s/__version__\ =.*/__version__\ =\ \"${VERSION}\"/ ${VERSION_FILE}
    rm -f ${VERSION_TEMP_FILE}
}

build-package() {
    python setup.py -q sdist
}

upload-package() {
    python -m twine upload dist/*
}

soft-clean() {
    find . -name *.egg-info -exec rm -rf {} +
    find . -name '*.pyc' -exec rm -f {} +
    find . -name '*.pyo' -exec rm -f {} +
    find . -name '*~' -exec rm -f {} +
}

exit-clean() {
    soft-clean
    git checkout -- ${VERSION_FILE} || true
    rm -f ${VERSION_TEMP_FILE}
    >&2 echo "Goodbye!!!"
}

dist-clean() {
    soft-clean
    rm -rf dist build
}

build-docker-image() {
    docker build --build-arg PACKAGE_VERSION=${VERSION} -t "${DOCKER_TAG}" "${DOCKER_FILE_PATH}"
}

push-docker-image() {
    docker push "${DOCKER_TAG}"
}

trap exit-clean EXIT
dist-clean
update-version
build-package
striking-print "Package:" $(ls ${PROJECT_ROOT}/etc)
upload-package
build-docker-image
striking-print ""
push-docker-image
