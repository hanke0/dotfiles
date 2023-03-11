#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]...
Show CRON lastest log from syslog.

Options:
  -h --help               print this help and exit
  -f --file               where syslog from (default to /var/log/syslog).
EOF
}

SYSLOG=/var/log/syslog

declare -a args
while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -f | --file)
        SYSLOG="${2}"
        shift 2
        ;;
    -f=* | --file=*)
        SYSLOG="${1#*=}"
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

grepargs=()
case "${SYSLOG}" in
"" | -)
    grepargs=()
    ;;
*)
    grepargs=("${SYSLOG}")
    ;;
esac

grep CRON "${grepargs[@]}" | awk -F ": " '!seen[$2]++' | sort -r -M
