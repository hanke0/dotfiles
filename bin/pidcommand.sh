#!/bin/bash

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION] [pid]...
Print process name of pid.

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
    for pid in "${args[@]}"; do
        printf '%s %s\n' "$pid" "$(ps -o command=, -p "${pid}")"
    done
    exit 0
fi

for pid in "${args[@]}"; do
    printf '%s %s\n' "$pid" "$(tr -d '\0' <"/proc/${pid}/cmdline")"
done
