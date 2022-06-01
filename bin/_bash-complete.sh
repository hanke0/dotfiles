#!/bin/bash

_common_option_complete() {
    local cur prev words cword opts fileopts pathopts
    cur="$2"
    prev="$3"
    words=("$COMP_WORDS")
    # current index of cwords
    cword="${COMP_CWORD}"

    COMPREPLY=()
    local PREIFS=$IFS
    local IFS='
'

    opts="$(
        LC_ALL=C $1 --help 2>&1 | while read -r line; do
            [[ "$line" =~ ^([[:space:]]+(-[A-Za-z0-9])?[[:space:]]*--[-A-Za-z0-9]+=?)|(^[[:space:]]+-[A-Za-z0-9](=[a-z0-9A-Z]+)?) ]] && printf '%s ' "${BASH_REMATCH[0]%%=}"
        done
    )"
    fileopts="$(
        LC_ALL=C $1 --help 2>&1 | while read -r line; do
            [[ "$line" =~ ^([[:space:]]+(-[A-Za-z0-9])?[[:space:]]*--[-A-Za-z0-9]+=FILE)|(^[[:space:]]+-[A-Za-z0-9]=FILE) ]] && printf '%s ' "${BASH_REMATCH[0]%%=FILE}"
        done
    )"
    pathopts="$(
        LC_ALL=C $1 --help 2>&1 | while read -r line; do
            [[ "$line" =~ ^([[:space:]]+(-[A-Za-z0-9])?[[:space:]]*--[-A-Za-z0-9]+=PATH)|(^[[:space:]]+-[A-Za-z0-9]=PATH) ]] && printf '%s ' "${BASH_REMATCH[0]%%=FILE}"
        done
    )"
    IFS=$PREIFS

    if [ -n "$prev" ]; then
        if [[ " $pathopts " =~ [[:space:]]${prev}[[:space:]] ]]; then
            compopt -o nospace
            compopt -o filenames 2>/dev/null
            COMPREPLY=($(compgen -d -- "$cur"))
            return
        fi
        if [[ " $fileopts " =~ [[:space:]]${prev}[[:space:]] ]]; then
            compopt -o nospace
            compopt -o filenames 2>/dev/null
            COMPREPLY=($(compgen -f -- "$cur"))
            return
        fi
    fi
    case "$cur" in
    -*)
        COMPREPLY=($(compgen -W "$opts" -- $cur))
        ;;
    *)
        compopt -o nospace
        compopt -o filenames 2>/dev/null
        COMPREPLY=($(compgen -f -- "$cur"))
        ;;
    esac
}

complete -W "--help camel snake pascal spinal space" convcase.sh
complete -F _common_option_complete kill-by-name.sh
complete -F _common_option_complete sort-large-file.sh
complete -F _common_option_complete catlines.sh
