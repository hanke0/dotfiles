#!/usr/bin/env bash

_common_option_test_with_suffix() {
    [[ "$1" =~ ^([[:blank:]]+(-[A-Za-z0-9])?[[:blank:],]+--[-A-Za-z0-9]+$2[[:blank:]])|([[:blank:]]+-[A-Za-z0-9]$2[[:blank:]]) ]]
}

_common_option_opts_suffix() {
    LC_ALL=C "$1" --help 2>&1 | while IFS=$'\n' read -r line; do
        if _common_option_test_with_suffix "$line" "$2"; then
            printf '%s ' "${BASH_REMATCH[0]%%=*}" | tr ',' ' '
        fi
    done
}

_common_option_opts() {
    _common_option_opts_suffix "$1" "(=.+)?"
}

_common_option_fileopts() {
    _common_option_opts_suffix "$1" "=FILE"
}

_common_option_pathopts() {
    _common_option_opts_suffix "$1" "=PATH"
}

_common_option_choiceopts() {
    local opts opt choices
    LC_ALL=C "$1" --help 2>&1 | while IFS=$'\n' read -r line; do
        if _common_option_test_with_suffix "$line" "=\[([[:space:]|a-zA-Z0-9|]+)\]"; then
            if [ -n "${BASH_REMATCH[1]}" ]; then # -s --long=[opt1|opt2]
                opts="${BASH_REMATCH[1]%%=*}"
                choices="${BASH_REMATCH[3]}"
            else
                # -s=[opt1|opt2]
                opts="${BASH_REMATCH[4]%%=*}"
                choices="${BASH_REMATCH[5]}"
            fi
            opts="$(echo "$opts" | tr ',' ' ')"
            for opt in $opts; do
                printf '%s ' "$opt=$choices"
            done
        fi
    done
}

_common_option_complete() {
    local cmd cur prev opts fileopts pathopts choiceopts line
    cmd="$1"
    cur="$2"
    prev="$3"
    # words=("$COMP_WORDS")
    # current index of cwords
    # cword="${COMP_CWORD}"

    COMPREPLY=()
    if [[ "$prev" == -* ]]; then
        pathopts="$(_common_option_pathopts "$cmd")"
        if [[ " $pathopts " =~ [[:blank:]]${prev}[[:blank:]] ]]; then
            compopt -o nospace 2>/dev/null
            compopt -o filenames 2>/dev/null
            while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -d -- "$cur")
            return
        fi
        fileopts="$(_common_option_fileopts "$cmd")"
        if [[ " $fileopts " =~ [[:blank:]]${prev}[[:blank:]] ]]; then
            compopt -o nospace 2>/dev/null
            compopt -o filenames 2>/dev/null
            while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -f -- "$cur")
            return
        fi
        choiceopts="$(_common_option_choiceopts "$cmd")"
        if [[ " $choiceopts " =~ [[:blank:]]${prev}=([a-zA-Z0-9|]+) ]]; then
            opts="$(echo "${BASH_REMATCH[1]}" | tr '|' ' ')"
            while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$opts" -- "$cur")
            COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
            return
        fi
    fi
    case "$cur" in
    -*)
        opts="$(_common_option_opts "$cmd")"
        while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$opts" -- "$cur")
        ;;
    *)
        compopt -o nospace 2>/dev/null
        compopt -o filenames 2>/dev/null
        while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -f -- "$cur")
        ;;
    esac
}

complete -W "--help camel snake pascal spinal space" convcase.sh
complete -F _common_option_complete kill-by-name.sh
complete -F _common_option_complete sort-large-file.sh
complete -F _common_option_complete catlines.sh
complete -F _common_option_complete mem-usage.sh
