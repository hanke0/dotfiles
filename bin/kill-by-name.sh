#!/usr/bin/env bash

usage() {
    cat <<EOF
Usage: ${0##*/} [-n -s] [-y] <pattern>

OPTION:
    -y                no ask.
    -h --help         print this help and exit.
    -n sig            SIG is a signal number.
    -s sig            SIG is a signal name.
EOF
}

declare -a args
sig=()
noyes=0
while [ $# -gt 0 ]; do
    case "$1" in
    -n)
        sig=(-n "$2")
        shift 2
        ;;
    -s)
        sig=(-s "$2")
        shift 2
        ;;
    -[0-9]*)
        sig=("$1")
        shift
        ;;
    -y)
        noyes=1
        shift
        ;;
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

if [ ${#args[@]} -eq 0 ]; then
    usage
    exit 1
fi

command -v realpath >/dev/null 2>&1 || ps() {
    find /proc/ -maxdepth 1 -type d -name '[0-9]*' -exec bash -c 'echo -n "${1##*/} "; cat "$1/cmdline"; echo' shell {} \;
}

# pgrep does not support
# shellcheck disable=SC2009
declare -a processes=("$(ps -o pid,command | grep -E "${args[0]}" | grep -v "grep" | grep -v "${0##*/}")")

echo "${processes[@]}"

if [ $noyes -eq 0 ]; then
    echo
    echo "${processes[@]}" | awk '{print $1}' | xargs echo kill "${sig[@]}"
    read -r -p "Kill all those process, OK[y/N]: " answer
    case "$answer" in
    y | yes | Y | Yes | YES) ;;
    *)
        echo "user exit"
        exit 0
        ;;
    esac
fi

echo "${processes[@]}" | awk '{print $2}' | xargs kill "${sig[@]}"
