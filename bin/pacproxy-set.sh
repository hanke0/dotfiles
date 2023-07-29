#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [url]
Set auto proxy with a pac url on MacOS.

Options:
  -h, --help               print this help and exit
  -d, --disable            Disable proxy
  -s, --networkservice     Network service name(default to WI-FI).

ENVIRONMENT:
    PAC_PROYX_URL        get url from environment
EOF
}

NETWORKSERVICE="WI-FI"
DISABLE=false
URL="${PAC_PROYX_URL}"
HASSET=false
set_url() {
    if [ "$HASSET" = true ] || [ $# -gt 1 ]; then
        echo >&2 "too many arguments"
    fi
    URL="$1"
    HASSET=true
}

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -s | --networkservice)
        NETWORKSERVICE="$2"
        shift 2
        ;;
    -s=* | --networkservice=*)
        NETWORKSERVICE="${1#*=}"
        shift
        ;;
    -d | --disable)
        DISABLE=true
        shift 1
        ;;
    --)
        shift 1
        set_url "$@"
        break
        ;;
    -*)
        echo >&2 "unknown option: $1"
        exit 1
        ;;
    *)
        set_url "$1"
        shift
        ;;
    esac
done

set_proxy() {
    networksetup -setautoproxyurl "$NETWORKSERVICE" "$URL"
    networksetup -setautoproxystate "$NETWORKSERVICE" on
}

disable() {
    networksetup -setautoproxystate "$NETWORKSERVICE" off
}

if [ "$DISABLE" = true ]; then
    disable
else
    set_proxy
fi

networksetup -getautoproxyurl "$NETWORKSERVICE"
