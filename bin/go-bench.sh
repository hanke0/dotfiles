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

vexec go clean -testcache
vexec go test -gcflags=all=-l --bench=. --run=^$ \
    -cpuprofile=prof.out -memprofile mem.out \
    -benchmem \
    "${args[@]}"
