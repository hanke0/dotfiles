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

here="$(pwd)"

find "$here" -name 'go.mod' -type f -exec dirname {} \; | while IFS= read -r folder; do
    cd "$folder" || exit 1
    pwd
    vexec go clean -testcache
    vexec go test -gcflags=all=-l "${args[@]}"
    cd "$here" || exit 1
done
