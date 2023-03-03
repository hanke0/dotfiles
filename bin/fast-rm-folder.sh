#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... <FolerName>
Delete folder faster

Options:
  -h --help               print this help and exit
  -q --quiet              suppress non-error messages
EOF
}

declare -a args

MESSAGE_LEVEL=-v

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -q | --quiet)
        shift
        MESSAGE_LEVEL=-q
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

if [ "${#args[@]}" -ne 1 ]; then
    echo >&2 "Too many arguments. delete folder at one time"
    exit 1
fi

folder="${args[0]}"

if [ ! -d "${folder}" ] || [ -z "${folder}" ]; then
    echo >&2 "folder not exist"
    exit 1
fi

empty="$(mktemp -d)"
trap "rmdir ${empty}" EXIT
rsync -a --delete "${MESSAGE_LEVEL}" "${empty}/" "${folder}/"
