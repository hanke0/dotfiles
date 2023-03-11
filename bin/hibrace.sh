#!/bin/bash

usage() {
    cat <<EOF
Usage: ${0##*/} [-i] [-h] [input files]...
Replace all scripts use \$var to \${var}

OPTION:
    -y                no ask.
    -h --help         print this help and exit.
    -i --in-place     edit files in place
EOF
}

sedopts=()

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -i | --in-place)
        sedopts+=("${1}")
        shift
        ;;
    --)
        shift
        break
        ;;
    *)
        break
        ;;
    esac
done

sed="sed"
if command -v "gsed"; then
    sed="gsed"
fi

# shellcheck disable=SC2016
"${sed}" "${sedopts[@]}" -E 's/([^\\\$])?\$([a-zA-Z_0-9]+)/\1${\2}/g' "$@"
