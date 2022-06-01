#!/bin/bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... <DESC>  [FILE]...
Print the specific lines of each FILE to standard output.
With more than one FILE, precede each with a header giving the file name.
With no FILE, or when FILE is -, read standard input.
DESC is in a format of 'start-end' or 'start+count'.
If start missed, start equals to 0.
If end misseed, end equals to infinity, which means print until read EOF.
If count missed, count equals to infinity, which also means print until read EOF.
Both start and end are included if described in 'start-end' formatting.

Options:
  -b --bytes              uses bytes instead of lines
  -h --help               print this help and exit
  -q --quiet              never print headers giving file names
  -v --verbose            always print headers giving file names
  -z --zero-terminated    line delimiter is NUL, not newline
EOF
}

declare -a args

QUIET=""
TERM_OPT=""
SIZE_OPT=-n
QUIET_OPT=""

while [ $# -gt 0 ]; do
    case "$1" in
    -b | --bytes)
        SIZE_OPT=-c
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    -q | --quiet)
        QUIET=1
        QUIET_OPT="-q"
        shift
        ;;
    -v | --verbose)
        QUIET=0
        QUIET_OPT="-v"
        shift
        ;;
    -z | --zero-terminated)
        TERM_OPT="$TERM_OPT -z"
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
        args+=("$1")
        shift 1
        ;;
    esac
done

if [ ${#args[@]} -lt 1 ]; then
    cat
    exit 0
fi

START=.
COUNT=.

_set_start_and_count() {
    if [[ "$1" =~ ^([0-9]|([1-9][0-9]+))$ ]]; then
        COUNT="$1"
        return
    fi
    if [[ "$1" =~ ^([0-9]|[1-9][0-9]+)\-$ ]]; then
        START="${1/-*/}"
        return
    fi
    if [[ "$1" =~ ^([0-9]|[1-9][0-9]+)\+$ ]]; then
        START="${1/+*/}"
        return
    fi
    if [[ "$1" =~ ^-([0-9]|[1-9][0-9]+)$ ]]; then
        COUNT="${1/*-/}"
        return
    fi
    if [[ "$1" =~ ^\+([0-9]|[1-9][0-9]+)$ ]]; then
        COUNT="${1/*+/}"
        return
    fi
    if [[ "$1" =~ ^([0-9|[1-9][0-9]*)-([0-9]|[1-9][0-9]*)$ ]]; then
        START="${1/-*/}"
        COUNT="${1/*-/}"
        if [ "$COUNT" -lt "$START" ]; then
            START=.
            COUNT=0
        else
            COUNT=$(($COUNT - $START + 1))
        fi
        return
    fi
    if [[ "$1" =~ ^([0-9|[1-9][0-9]*)\+([0-9]|[1-9][0-9]*)$ ]]; then
        START="${1/+*/}"
        COUNT="${1/*+/}"
        return
    fi
    echo >&2 "bad count format"
    exit 1
}
_set_start_and_count "${args[0]}"

args=("${args[@]:1}")

if [ ${#args[@]} -eq 0 ]; then
    args=('-')
fi

if [ $START = . ] && [ $COUNT = . ]; then
    cat -- "${args[@]}"
    exit 0
fi

if [ $START = . ]; then
    head $SIZE_OPT "$COUNT" $TERM_OPT $QUIET_OPT -- "${args[@]}"
    exit 0
fi

if [ $COUNT = . ]; then
    tail $SIZE_OPT "+$START" $TERM_OPT $QUIET_OPT -- "${args[@]}"
    exit 0
fi

if [ "${#args[@]}" -eq 1 ]; then
    if [ "${QUIET:=0}" -ne 0 ]; then
        if [ "${args[0]}" = '-' ]; then
            echo "==> standard input <=="
        else
            echo "==> ${args[0]} <=="
        fi
    fi
    tail "$SIZE_OPT" "+$START" $TERM_OPT -q -- "${args[0]}" | head -q "$SIZE_OPT" "$COUNT" $TERM_OPT
    exit 1
fi

for file in "${args[@]}"; do
    if [ "${QUIET:=1}" -ne 0 ]; then
        if [ "$file" = '-' ]; then
            echo "==> standard input <=="
        else
            echo "==> $file <=="
        fi
    fi
    tail "$SIZE_OPT" "+$START" $TERM_OPT -q -- "$file" | head -q "$SIZE_OPT" "$COUNT" $TERM_OPT
done
