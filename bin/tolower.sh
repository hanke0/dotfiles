#!/usr/bin/env bash

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [FILE]

Option:
  -u --upper           replace all lower character to upper
  -h --help            print this help and exit
EOF
}

declare -a args
toreplace='[[:upper:]]'
replace='[[:lower:]]'

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -u | --upper)
        toreplace='[[:lower:]]'
        replace='[[:upper:]]'
        shift 1
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

if [ ${#args[@]} -gt 1 ]; then
    echo >&2 "too many files"
    exit 1
fi

if [ ${#args[@]} -eq 0 ]; then
    tr "$toreplace" "$replace"
else
    for file in "${args[@]}"; do
        tr "$toreplace" "$replace" <"$file"
    done
fi
