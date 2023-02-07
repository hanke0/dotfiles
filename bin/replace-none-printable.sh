#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [FILE]
show non-printable.

# supported mappings
# 1. carriage return => \r
# 2. newline (line feed) => \n
# 3. tab => \t
# 4. space => \x20


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

xxd -c 1 "${args[@]}" |
    awk '{print $2}' |
    sed 's/0a/5c6e/g' |
    sed 's/0d/5c72/g' |
    sed 's/09/5c74/g' |
    sed 's/20/5c783230/g' |
    tr -d '\n' |
    xxd -r -p
# use echo to add newline to the end
echo
