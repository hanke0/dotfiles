#!/usr/bin/env bash

set -e

path_append() {
    case ":${PATH}:" in
    *:"$1":*) ;;
    *)
        export PATH="$PATH:$1"
        ;;
    esac
}

path_append "/usr/local/bin"
path_append "/bin"
path_append "/usr/bin"
path_append "/sbin"
path_append "/usr/sbin"

command -v realpath >/dev/null 2>&1 || realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

x() {
    if ! "$@"; then
        exit 1
    fi
}

ABS_PATH="$(x realpath "$0")"
ROOT_DIR="$(x dirname "$(x dirname "$ABS_PATH")")"

cd "$ROOT_DIR"
git pull -q origin master
./install.sh "$@"
