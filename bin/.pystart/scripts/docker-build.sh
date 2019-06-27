#!/usr/bin/env bash

set -e

PACKAGE=example
MODULE=${PACKAGE//-/_}

error-help() {
    [[ -n $1 ]] && 2>&1 echo $1
    2>&1 echo "Usage: $0 [OPTIONS]
Options:
    -u harbor-url
    -t docker-tag
    -v package-version
    "
}

echo-around() {
    local n=$((${#1} + 6))
    echo
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo '* ' $1 ' *'
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo
}

PACKAGE_VERSION=
DOCKER_TAG=
HARBOR_URL=

ARGS=$@
POSITION_ARGS=()
NUM_ARGS=$#

while getopts "?t:v:u:h" opt ;do
    case ${opt} in
        v)
            PACKAGE_VERSION=$OPTARG
            shift_num=$((${shift_num} + 2))
            ;;
        h)
            error-help
            exit 0
            ;;
        t)
            DOCKER_TAG=$OPTARG
            shift_num=$((${shift_num} + 2))
            ;;
        u)
            HARBOR_URL=$OPTARG
            shift_num=$((${shift_num} + 2))
            ;;
        :)
            echo "The option -$OPTARG requires an argument."
            exit 1
            ;;
        ?)
            echo "Invalid option: -${OPT}"
            error-help
            exit 2
            ;;
    esac
done

[[ ${shift_num} -ne 0 ]] && shift ${shift_num}

[[ $OPTIND -lt ${NUM_ARGS} ]] && error-help "Unknown argument $@" && exit 3

if [[ -z ${PACKAGE_VERSION} ]]; then
    PACKAGE_VERSION=$(grep -o -E "__version__ ?= ?[\'\"].+[\'\"]" ${MODULE}/__init__.py  | awk -F= '{print $2}' | sed s/\"//g | sed s/\'//g | sed s/\ //g)
fi

if [[ -z ${DOCKER_TAG} ]]; then
    DOCKER_TAG=${PACKAGE_VERSION}
fi

echo-around "RQAMS_VERSION=${PACKAGE_VERSION}"
if [[ -z ${HARBOR_URL} ]]; then
    DOCKER_IMAGE="${PACKAGE}:${DOCKER_TAG}"
else
    DOCKER_IMAGE="${HARBOR_URL}/${PACKAGE}:${DOCKER_TAG}"
fi

docker build --build-arg PACKAGE_VERSION=${PACKAGE_VERSION} -t ${DOCKER_IMAGE} .

if [[ -n ${HARBOR_URL} ]]; then
    docker push ${DOCKER_IMAGE}
fi

echo-around "IMAGE NAME IS ${DOCKER_IMAGE}"
