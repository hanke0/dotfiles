#!/bin/bash

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]
Print all process pid and command.

OPTION:
    -h --help         print this help and exit.
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

if command -v ps 2>&1 >/dev/null; then
    ps -axo pid=,command=,
    exit 0
fi

for pid in /proc/*; do
    if [ -r "$pid/cmdline" ]; then
        printf '%12s %s\n' "${pid##*/}" "$(tr -d '\0' <"${pid}/cmdline")"
    fi
done
