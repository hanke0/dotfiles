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

command -v realpath >/dev/null 2>&1 ||  realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

ABS_PATH="$(realpath "$0")"
ROOT_DIR="$(dirname "$ABS_PATH")"

# compitable with nginx proxy for github
export GIT_SSL_NO_VERIFY=1
cd "$ROOT_DIR"

/usr/bin/git pull -q origin master
