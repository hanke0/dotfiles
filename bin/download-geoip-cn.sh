#!/usr/bin/env bash

HTTP_URL="https://cdn.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/Country.mmdb"

FILENAME="Country.mmdb"
OVERWRITE=0
FORCE_CURL=0

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [DEST]
Get the china GeoIP data.

Options:
  -h --help               print this help and exit
  -o --overwrite          overwrite output file when it exist
     --curl               force use curl
     --url                use the custom url instead of default($HTTP_URL)
EOF
}
declare -a args

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -o | --overwrite)
        OVERWRITE=1
        shift
        ;;
    --curl)
        FORCE_CURL=1
        shift
        ;;
    --url)
        HTTP_URL="$2"
        shift 2
        ;;
    --url=*)
        HTTP_URL="${1#*=}"
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

if [ "${#args[@]}" -gt 1 ]; then
    echo >&2 "too many path provides"
    exit 1
fi

out="${args[0]}"

if [ -z "$out" ]; then
    out="$FILENAME"
fi

if [ -d "$out" ]; then
    out="$out/$FILENAME"
fi

if [ -f "$out" ] && [ "$OVERWRITE" -eq 0 ]; then
    echo >&2 "output file exists: $out"
    exit 1
fi

if command -v wget >/dev/null 2>&1 && [ "$FORCE_CURL" -eq 0 ]; then
    http_get() {
        wget --output-document "$1" "$2"
    }
else
    if command -v curl >/dev/null 2>&1; then
        http_get() {
            curl -L -o "$1" "$2"
        }
    else
        echo >&2 "curl or wget not installed"
        exit 1
    fi
fi

http_get "$out" "$HTTP_URL"
echo "success file into: $out"
