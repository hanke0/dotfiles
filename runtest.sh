#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]...
Run unit test.

Options:
    --docker       run in the docker
    --images       run with docker image list, split by ,(default to $DOCKERIMAGE)
    --help         print this help and exit
    --shell        use shell instead of bash (default to $USESHELL). 
EOF
}

USEDOCKER=0
DOCKERIMAGE="debian:10-slim,centos:7"
USESHELL="/bin/bash"

while [ $# -gt 0 ]; do
    case "$1" in
    --docker)
        USEDOCKER=1
        shift
        ;;
    --images)
        DOCKERIMAGE="$2"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    --shell)
        USESHELL="$2"
        shift 2
        ;;
    --)
        shift 1
        args+=("$@")
        break
        ;;
    -*)
        echo >&2 "unknown option: $1"
        exit 1
        ;;
    *)
        args+=("$1")
        shift 1
        ;;
    esac
done

exec="find ./tests -type f -name 'test_*.sh' -exec $USESHELL './{}' \;"

if [ "$USEDOCKER" -ne 0 ]; then
    IFS=', ' read -r -a images <<<"$DOCKERIMAGE"
    for image in "${images[@]}"; do
        docker run -it --entrypoint /bin/bash -v "$(pwd):/codes" --rm "$image" -c "uname -a && cd /codes && $exec"
    done
    exit 0
fi

uname -a
eval "$exec"
