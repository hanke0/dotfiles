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
    -t, --timeout=Duration  if a test runs longer than this duration, panic.(default to 10 minutes).
        --cpuprofile        write a CPU profile to cpu.out
        --memprofile        wirte a alloctaion profile to mem.out.
    -v, --verbose           verbose output.
EOF
}

declare -a args

COVERAGE=false
EXTRA=(-failfast)

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
    -t | --timeout)
        EXTRA+=(-timeout "$2")
        shift 2
        ;;
    -t=* | --timeout=*)
        EXTRA+=(-timeout "${1#*=}")
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
    -v | --verbose)
        EXTRA+=(-v)
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

doone() {
    echo "GO TEST: $1"
    if [ -d "$1" ]; then
        go test "${EXTRA[@]}" "${1}/..."
        return
    fi
    go test "${EXTRA[@]}" "$1"
}

if [ "${#args[@]}" -eq 0 ]; then
    args=(".")
fi

echo "GO TEST OPTIONS:" "${EXTRA[@]}"

for path in "${args[@]}"; do
    doone "$path"
done

if [ "$COVERAGE" = true ]; then
    go tool cover -html=cover.out -o cover.html
fi
