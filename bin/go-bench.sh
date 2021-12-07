#!/usr/bin/env bash

args=()
if [[ $# -gt 0 ]]; then
    args=("$@")
else
    args=(./...)
fi

vexec() {
    echo "$@"
    "$@"
}

f="$(mktemp)"

vexec go clean -testcache
vexec go test -gcflags=all=-l --bench=".*" --run=^$ \
    -benchmem \
    "${args[@]}"

cat "$f"
rm "$f"
