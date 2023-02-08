#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [FILE]...
Keep first line of repeated lines from files.

Options:
  -h --help               print this help and exit
EOF
}

declare -a args

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
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

awk '!x[$0]++' "${args[@]}"
