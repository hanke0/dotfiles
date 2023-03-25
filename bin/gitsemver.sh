#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [git path]
Check git repo latest git tag is a valid sematic version string.

Options:
  -s, --strict        strict mode, git path must clean.
EOF
}

DEST=
strict=

setpath() {
    if [ -n "$DEST" ]; then
        echo >&2 "only accpet one path argument"
        exit 1
    fi
    DEST="$1"
}

while [ $# -gt 0 ]; do
    case "$1" in
    -s | --strict)
        strict=true
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    --)
        shift 1
        for f in "$@"; do
            setpath "$f"
        done
        break
        ;;
    -*)
        echo >&2 "unknown option: $1"
        exit 1
        ;;
    *)
        setpath "$1"
        shift 1
        ;;
    esac
done

if [ -n "$DEST" ]; then
    pushd "$DEST"
fi

NAT='0|[1-9][0-9]*'
ALPHANUM='[0-9]*[A-Za-z-][0-9A-Za-z-]*'
IDENT="$NAT|$ALPHANUM"
FIELD='[0-9A-Za-z-]+'

SEMVER_REGEX="\
^[vV]?\
($NAT)\\.($NAT)\\.($NAT)\
(\\-(${IDENT})(\\.(${IDENT}))*)?\
(\\+${FIELD}(\\.${FIELD})*)?$"

validate-version() {
    if [[ "$1" =~ $SEMVER_REGEX ]]; then
        echo "$1"
    else
        echo "version '$1' does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'." >&2
        exit 1
    fi
}

base-version() {
    local major=${BASH_REMATCH[1]}
    local minor=${BASH_REMATCH[2]}
    local patch=${BASH_REMATCH[3]}
    echo "$major.$minor.$patch"
}

latestversiontag="$(git tag --sort=-committerdate --list 'v*' | head -1 | cut -b 2-)"
if [ -z "$latestversiontag" ]; then
    echo "Can't find version tags, version tag must starts with v" >&2
    exit 1
fi

if [[ -n "$strict" ]]; then
    git_describe="$(git describe --dirty --tags | cut -b 2-)"
    if [[ "$latestversiontag" != "$git_describe" ]]; then
        echo "git HEAD doesn't have a version tag or there are changes not commited" >&2
        exit 1
    fi
fi

validate-version "$latestversiontag"
