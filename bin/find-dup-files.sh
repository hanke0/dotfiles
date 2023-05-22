#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [Folder]...
Find all duplicated files.

Options:
  -h, --help               print this help and exit
      --mindepth           mindepth
      --maxdepth
EOF
}

declare -a args paths

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    --mindepth)
        args+=(-mindepth "$2")
        shift 2
        ;;
    --mindepth=*)
        args+=(-mindepth "${1#*=}")
        shift
        ;;
    --maxdepth)
        args+=(-maxdepth "$2")
        shift 2
        ;;
    --maxdepth=*)
        args+=(-maxdepth "${1#*=}")
        shift
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
        paths+=("$1")
        shift 1
        ;;
    esac
done

find "${paths[@]}" "${args[@]}" ! -empty -type f -printf '%f\n' | sort | uniq -d
