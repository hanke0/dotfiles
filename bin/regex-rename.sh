#!/usr/bin/env bash

set -e
set -o pipefail

usage="
Usage: ${0##*/} [OPTION]... FROM TO [FILE]...
Rename by regex.

Example:
${0##*/} '(.*)\.(.*)\.mkv' '\$1.mkv' file1.suffix.mkv file1.suffix.mkv

OPTION:
    -y, --yes          not asking.
    -n --noexec        show commands instead of executing them.
"

NOEXEC=
YES=

declare -a PARAMS

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        echo "$usage"
        exit 0
        ;;
    -n | --noexec)
        NOEXEC=true
        shift 1
        ;;
    -y | --yes)
        YES=true
        shift 1
        ;;
    --)
        shift 1
        PARAMS+=("$@")
        break
        ;;
    -*)
        echo >&2 "unknown option: $1"
        exit 1
        ;;
    *)
        PARAMS+=("$1")
        shift 1
        ;;
    esac
done

FROM="${PARAMS[0]}"
TO="${PARAMS[1]}"
FILES=("${PARAMS[@]:2}")

if [ -z "$FROM" ]; then
    echo >&2 "FROM not set, try --help for more information"
    exit 1
fi
if [ -z "$TO" ]; then
    echo >&2 "TO not set, try --help for more information"
    exit 1
fi

if [ -z "$NOEXEC" ]; then
    move() {
        mv "$@"
    }
else
    move() {
        echo mv "$@"
    }
fi

if [ -z "$YES" ]; then
    do_move() {
        local ans
        printf '%s ' "mv" "$@" "[Y/n]:"
        read -r ans

        case "$ans" in
        "" | Y | y | yes | YES)
            move "$@"
            ;;
        *)
            echo "user abort"
            ;;
        esac
    }
else
    do_move() {
        move "$@"
    }
fi

getto() {
    # shellcheck disable=SC2016
    sed -E 's/\$([0-9]+)/${BASH_REMATCH[\1]}/g' <<<"$1"
}

CTO="$(getto "$TO")"
for file in "${FILES[@]}"; do
    folder="$(dirname "$file")"
    base="$(basename "$file")"
    if [[ ! "$base" =~ $FROM ]]; then
        echo >&2 "file not match regex: $file"
        continue
    fi
    tobase="$(eval "echo $CTO")"
    from="$folder/$base"
    to="$folder/$tobase"
    if [ "$from" != "$to" ]; then
        do_move "$from" "$to"
    fi
done
