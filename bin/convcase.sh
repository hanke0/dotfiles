#!/bin/bash

usage() {
    cat <<EOF
Usage: ${0##*/} <case_describtion> [content]...
Convert strings case. If no content provides, read from stdin.
Special characters are treated as is except under score(_), hyphen(-) and space.

Case Describtion:
camel:  camelCase
snake:  snake_case
pascal: PascalCase
spinal: spinal-case
space:  space case
EOF
}

declare -a args

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    --)
        shift 1
        args+="$@"
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
    echo "$1" | sed -r -e 's/([a-z0-9])([A-Z])/\1_\L\2/g' -e 'y/- /__/' | tr [[:upper:]] [[:lower:]]
}

toSpinal() {
    echo "$1" | sed -r -e 's/([a-z0-9])([A-Z])/\1-\L\2/g' -e 'y/_ /--/' | tr [[:upper:]] [[:lower:]]
}

toSpace() {
    echo "$1" | sed -r -e 's/([a-z0-9])([A-Z])/\1 \L\2/g' -e 'y/-_/  /' | tr [[:upper:]] [[:lower:]]
}

if [ ${#args[@]} -eq 0 ]; then
    echo >&2 "must provides case describtion"
    exit 1
fi

case "${args[0]}" in
camel)
    toCase=toCamel
    ;;
snake)
    toCase=toSnake
    ;;
pascal)
    toCase=toPascal
    ;;
spinal)
    toCase=toSpinal
    ;;
space)
    toCase=toSpace
    ;;
*)
    echo >&2 "bad case describtion"
    exit 1
    ;;
esac

args=("${args[@]:1}")

if [ ${#args[@]} -eq 0 ]; then
    while read -r name; do
        $toCase "$name"
    done
else
    for data in "${args[@]}"; do
        $toCase "$data"
    done
fi
