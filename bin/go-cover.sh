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

run_and_print rm -f cover.out cover.html
run_and_print go test -gcflags=all=-l -covermode=count -coverprofile=cover.out "${args[@]}"
run_and_print go tool cover -html=cover.out -o cover.html
