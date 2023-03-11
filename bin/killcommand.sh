#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... <pattern> [pattern]...
Kill processes that command matches specific pattern.

Options:
  -h --help               print this help and exit.
  -E --extended-regexp    use extended regular expression.
  -s --signal             kill signal
EOF
}

SIGNAL=SIGTERM
GREPREG=-e

declare -a args
while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -E | --extended-regexp)
        GREPREG=-E
        ;;
    -s | --signal)
        SIGNAL="$2"
        shift 2
        ;;
    -s=* | --signal=*)
        SIGNAL="${1#*=}"
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

if [ "${#args[@]}" -lt 1 ]; then
    echo >&2 "No pattern provided"
    exit 1
fi

grepops=()
for i in "${args[@]}"; do
    grepops+=("$GREPREG" "$i")
done

processes="$(ps axo pid=,command=)"
finds="$(grep "${grepops[@]}" <<<"${processes}" | grep -v "${0##*/}")"
if [ -z "$finds" ]; then
    exit 1
fi
echo "$finds"
read -r -p "! Kill all those process with signal $SIGNAL [Y/n]:" answer

case "$answer" in
"" | Y | y | yes) ;;
*)
    exit 0
    ;;
esac

echo "$finds" | awk '{print $1}' | xargs kill "-$SIGNAL"
