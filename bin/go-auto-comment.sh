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
    # add comment for export method and functions.
    gawk -i inplace -v pattern='^func (\\(([a-zA-Z0-9_]+ )?\\*?[A-Z][a-zA-Z0-9_]*\\) )?([A-Z][a-zA-Z0-9_]+)\\(' \
        -v commentre='^//' \
        '{
            if (match($0, pattern, ary) && precomment!=NR-1) {
                print "//", ary[3], "...";
            }
            if ($0 ~ commentre) {
                precomment=NR;
            }
            print $0;
        }' "$@"
    # add comment for export type, one line const and var global.
    gawk -i inplace -v pattern='^(type|const|var) ([A-Z][a-zA-Z0-9_]*) ' \
        -v commentre='^//' \
        '{
            if (match($0, pattern, ary) && precomment!=NR-1) {
                print "//", ary[2], "...";
            }
            if ($0 ~ commentre) {
                precomment=NR;
            }
            print $0;
        }' "$@"
    # add comment for const group. (not handle if exported)
    gawk -i inplace -v pattern='^const \\(' \
        -v commentre='^//' \
        '{
            if (match($0, pattern, ary) && precomment!=NR-1) {
                print "//", "...";
            }
            if ($0 ~ commentre) {
                precomment=NR;
            }
            print $0;
        }' "$@"
}

if [ "$UNSAFE" != true ]; then
    if ! git ls-files --error-unmatch "${args[@]}" >/dev/null; then
        echo >&2 "* Has files not tracked by git"
        exit 1
    fi
    if [ -n "$(git status --porcelain 2>&1)" ]; then
        echo >&2 "* Has changes not committed"
        exit 1
    fi
fi

addcomment "${args[@]}"
