#!/bin/bash

usage() {
    cat <<EOF
Usage: ${0##*/} [-n -s] [-y] <pattern>

OPTION:
    -y                no ask.
    -h --help         print this help and exit.
    -n sig            SIG is a signal number.
    -s sig            SIG is a signal name.
EOF
}

declare -a args
sig=""
noyes=0
while [ $# -gt 0 ]; do
    case "$1" in
    -n)
        sig="-n $2"
        shift 2
        ;;
    -s)
        sig="-n $2"
        shift 2
        ;;
    -[0-9]*)
        sig=$1
        shift
        ;;
    -y)
        noyes=1
        shift
        ;;
    -h | --help)
        usage
        exit 0
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

# to lower first ${str,}
# to lower all ${str,,}
# to upper first ${str^}
# to upper all ${str^^}

toPascal() {
    IFS="$(echo -ne '\t-_ ')" read -ra str <<<"$1"
    printf '%s' "${str[@]^}"
    echo
}

toCamel() {
    out="$(toPascal "$1")"
    printf "%s" "${out,}"
    echo
}

toSnake() {
    echo "$1" | sed -r -e 's/([a-z0-9])([A-Z])/\1_\L\2/g' -e 'y/- /__/' | tr '[:upper:]' '[:lower:]'
}

toSpinal() {
    echo "$1" | sed -r -e 's/([a-z0-9])([A-Z])/\1-\L\2/g' -e 'y/_ /--/' | tr '[:upper:]' '[:lower:]'
}

toSpace() {
    echo "$1" | sed -r -e 's/([a-z0-9])([A-Z])/\1 \L\2/g' -e 'y/-_/  /' | tr '[:upper:]' '[:lower:]'
}

if [ ${#args[@]} -eq 0 ]; then
    usage
    exit 1
fi

declare -a processes=("$(ps -ef | grep -E "${args[0]}" | grep -v "grep" | grep -v "${0##*/}")")

echo "${processes[@]}"

if [ $noyes -eq 0 ]; then
    echo
    echo "${processes[@]}" | awk '{print $2}' | xargs echo kill $sig
    read -r -p "Kill all those process, OK[y/N]: " answer
    case "$answer" in
    y | yes | Y | Yes | YES) ;;
    *)
        echo "user exit"
        exit 0
        ;;
    esac
fi

echo "${processes[@]}" | awk '{print $2}' | xargs kill $sig
