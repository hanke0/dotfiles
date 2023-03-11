#!/usr/bin/env bash

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [RAND_SOURCE]
Output random numbers.

Options:
  -h --help               print this help and exit
  -t --type=TYPE          type of output number (default to u)
  -s --size=SIZE          size of output number (default to 4)
     --no-linebreak       do not print a linebreak at end.

TYPE is made up of one or more of these specifications:
  d    signed decimal, SIZE bytes per integer
  f    floating point, SIZE bytes per float
  o    octal, SIZE bytes per integer
  u    unsigned decimal, SIZE bytes per integer
  x    hexadecimal, SIZE bytes per integer
  
SIZE is a number. should be one of [1, 2, 4, 8]
EOF
}

RAND_SOURCE="/dev/urandom"
SIZE=4
TYPE=u
END='\n'

declare -a args

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -s | --size)
        SIZE="$2"
        shift 2
        ;;
    -s=* | --size=*)
        SIZE="${1#*=}"
        shift
        ;;
    -t | --type)
        TYPE="$2"
        shift 2
        ;;
    -t=* | --type=*)
        TYPE="${1#*=}"
        shift
        ;;
    --no-linebreak)
        END=''
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

if [ -n "${args[0]}" ]; then
    RAND_SOURCE="${args[0]}"
fi

case "${TYPE}" in
d | f | o | u | x) ;;
*)
    echo >&2 "Bad usage: --type is invalid ${TYPE}"
    exit 1
    ;;
esac

case "${SIZE}" in
1 | 2 | 4 | 8) ;;
*)
    echo >&2 "Bad usage: --size is invalid ${SIZE}"
    exit 1
    ;;
esac

g="$(od -v -An -N "${SIZE}" -t "${TYPE}${SIZE}" <"$RAND_SOURCE" | tr -dc '0-9-')"

if [ -z "$g" ]; then
    exit 1
fi

printf '%s' -- "${g}${END}"
