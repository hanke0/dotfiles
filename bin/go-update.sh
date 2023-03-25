#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/}
Update go direct dependences

Options:
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    --)
        break
        ;;
    -*)
        echo >&2 "unknown option: $1"
        exit 1
        ;;
    *)
        shift 1
        ;;
    esac
done

# Update go direct dependences
go list -f '{{if not .Indirect}}{{.}}{{end}}' -u -m all | tr ' ' '@' | grep @ | xargs -t -I {} go get {}
