#!/usr/bin/env bash

args=()
if [[ $# -gt 0 ]]; then
    args=("$@")
else
    args=(-coverpkg=./... ./...)
fi

vexec() {
    echo "$@"
    "$@"
}

vexec rm -f cover.out cover.html
vexec go test -gcflags=all=-l -covermode=count -coverprofile=cover.out "${args[@]}"
vexec go tool cover -html=cover.out -o cover.html
