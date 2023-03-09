#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... filename...
Auto add comment(...) for go sources.

Note!!!
    This script inplace write source code.
    It must run in git directory and all files must be git tracked.

Options:
    -h, --help              print this text and exit.
        --unsafe            disable check git. files could be any one.
EOF
}

declare -a args

UNSAFE=false

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    --unsafe)
        shift
        UNSAFE=true
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

addcomment() {
    # add comment for export method.
    sed -i -E 's#^func \(([a-zA-Z0-9_]+ )?\*?[A-Z][a-zA-Z0-9_]*\) ([A-Z][a-zA-Z0-9_]+)\(#\/\/ \2 ...\n&#' "$@"

    # add comment for export type, one line const and var global.
    sed -i -E 's#^(type|const|var) ([A-Z][a-zA-Z0-9_]*) #\/\/ \1 ...\n&#' "$@"

    # add comment for export function.
    sed -i -E 's#^func ([A-Z][a-zA-Z0-9_]*)\(#\/\/ \1 ...\n&#' "$@"

    # add comment for const group. (not handle if exported)
    sed -i -E 's#const \(#\/\/ ...\n&#' "$@"

    # remove duplicated comment.
    sed -i -E '/^\/\//{n;/^\/\/ ([A-Za-z0-9_]+ )?.../d}' "$@"
}

if [ "$UNSAFE" != true ]; then
    if ! git ls-files --error-unmatch "${args[@]}" >/dev/null; then
        echo >&2 "* Has files not trcked by git"
        exit 1
    fi
    if [ -n "$(git status --porcelain 2>&1)" ]; then
        echo >&2 "* Has changes not commited"
        exit 1
    fi
fi

addcomment "${args[@]}"
