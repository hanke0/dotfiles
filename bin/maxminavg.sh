#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [FILE]...
Print maxmum, minimum and average values from file.
Ignore empty lines.
With no FILE, or when FILE is -, read standard input.

Options:
  -c --column=1        column of file value.
  -F                   regular expression used to separate fields
  -S --skip-first-line skip the first line.
EOF
}

COLUMN="\$1"
OPTS=()
SKIP_FIRST_LINE=-1
declare -a args

setcolumn() {
    if [[ ! "$1" =~ [0-9]|[1-9][0-9]* ]]; then
        echo >&2 "bad column value"
        exit 1
    fi
    COLUMN="\$$1"
}

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -c | --column)
        setcolumn "$2"
        shift 2
        ;;
    -c=* | --column=*)
        setcolumn "${1#*=}"
        shift
        ;;
    -F)
        OPTS+=(-F "$2")
        shift 2
        ;;
    -F=*)
        OPTS+=(-F "${1#*=}")
        shift
        ;;
    -s | --skip-first-line)
        SKIP_FIRST_LINE=1
        shift
        ;;
    --)
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

script="$(
    cat <<EOF
BEGIN { sum=0;max=0;min=0;maxset=0;minset=0;total=0 }
{
    if (NR != $SKIP_FIRST_LINE && NF) {
        if (maxset==0||$COLUMN>max) {max=$COLUMN;maxset=1}
        if (minset==0||$COLUMN<min) {min=$COLUMN;minset=1}
        sum+=$COLUMN;
        total+=1;
    }
}
END {print "max "max" min "min" avg "sum/total}
EOF
)"

awk "$script" "${args[@]}"
