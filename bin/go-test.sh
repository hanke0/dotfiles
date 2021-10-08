#!/usr/bin/env bash

args=()
if [[ $# -gt 0 ]]; then
    args=("$@")
else
    args=(./...)
fi

run_and_print() {
    echo "$@"
    "$@"
}

run_and_print go test -gcflags=all=-l "${args[@]}"
