#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... path
Run go test easily.

Options:
    -h, --help              print this text and exit.
    -c, --coverage          write coverage profile to cover.out and cover.html.
    -b, --benchmark         run test with benchmark.
    -r, --recursive         test directory and thire content contains a go.mod recursive.
    -t, --timeout=Duration  if a test runs longer than this duration, panic.(default to 10 minutes).
        --cpuprofile        write a CPU profile to cpu.out
        --memprofile        wirte a alloctaion profile to mem.out.
EOF
}

declare -a args

COVERAGE=false
RECURSIVE=false
EXTRA=()

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -c | --coverage)
        shift
        EXTRA+=(-covermode=atomic -race -coverprofile=cover.out)
        COVERAGE=true
        ;;
    -b | --benchmark)
        shift
        EXTRA+=('-run=^$' '-bench=.')
        ;;
    -r | --recursive)
        shift
        RECURSIVE=true
        ;;
    -t | --timeout)
        EXTRA+=(-timeout "$2")
        shift
        ;;
    --cpuprofile)
        EXTRA+=("-cpuprofile=cpu.out")
        shift
        ;;
    --memprofile)
        EXTRA+=("-memprofile=mem.out")
        shift
        ;;
    -*)
        echo >&2 "unknown option: $1"
        exit 1
        ;;
    --)
        shift 1
        args+=("$@")
        break
        ;;
    *)
        args+=("$1")
        shift 1
        ;;
    esac
done

doone() {
    go test -failfast "${EXTRA[@]}" "$path"/...
}

if [ "${#args[@]}" -eq 0 ]; then
    args=(".")
fi

for path in "${args[@]}"; do
    if [ "$RECURSIVE" = true ]; then
        find "$here" -print0 -name 'go.mod' -type f -exec dirname {} \; | while read -d '' -r folder; do
            doone "$folder"
        done
        elseclear
        git s
        git s

        doone "$path"
    fi
done

if [ "$COVERAGE" = true ]; then
    go tool cover -html=cover.out -o cover.html
fi
