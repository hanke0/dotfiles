#!/usr/bin/env bash

#--------------------------
# STRING
#--------------------------
str_join() {
    local array_name=$1
    local _IFS=$IFS
    if [[ $# == 1 ]]; then
        IFS=,
    else
        IFS=${2}
    fi
    eval "printf '%s\\n' \"\${${array_name}[*]:-}\""
    IFS=$_IFS
}

str_lower() {
    local str=${1:-}
    printf '%s\n' "${str,,}"
}

str_upper() {
    local str=${1:-}
    printf '%s\n' "${str^^}"
}

str_startswith() {
    [[ $2${1##"$2"} == "$1" ]]
}

str_endswith() {
    [[ ${1%%"$2"}$2 == "$1" ]]
}

str_index() {
    # ignore string is unused.
    # shellcheck disable=SC2034
    local string=$1
    local index=$2
    eval echo "\${string:$index:1}"
}

# regex match and return the matched string.
# Arguments: string regex [index=1]
str_match() {
    [[ ${3:-} == 0 ]] && echo "index cannot be 0" >&2 && return 3

    if [[ $1 =~ $2 ]]; then
        if ((${#BASH_REMATCH[@]} > 1)); then
            printf '%s\n' "${BASH_REMATCH[${3:-1}]}"
        else
            echo ''
        fi
    else
        echo ''
    fi
}

str_ltrim() {
    local str=${1:-}
    if (($# < 2)); then
        printf '%s\n' "${str#"${str%%[![:space:]]*}"}"
    else
        # $2 must not quoted.
        # shellcheck disable=SC2295
        printf '%s\n' "${str##$2}"
    fi
}

str_rtrim() {
    local str=${1:-}
    if (($# < 2)); then
        printf '%s\n' "${str%"${str##*[![:space:]]}"}"
    else
        # $2 must not quoted.
        # shellcheck disable=SC2295
        printf '%s\n' "${str%%$2}"
    fi
}

str_trim() {
    local str=${1:-}
    shift
    str=$(str_rtrim "$str" "$@")
    str_ltrim "$str" "$@"
}

#--------------------------
#        ARRAY
#--------------------------
array_hasitem() {
    local array_name=$1
    # ignore match is unused.
    # shellcheck disable=SC2034
    local match="$2"
    local item1

    eval "[[ \${#${array_name}[@]} == 0 ]] && return 1"
    eval "for item1 in \"\${${array_name}[@]}\"; do [[ \"\$item1\" == \"\$match\" ]] && return 0; done; return 1"
}

array_append() {
    # append <array name> <item1>
    local array_name=$1
    local item1
    shift
    for item1 in "$@"; do
        eval "${array_name}+=(\"$item1\" )"
    done
}

array_intersection() {
    local array1_name=$1
    local array2_name=$2

    local item1
    # ignore item2 is unused
    # shellcheck disable=SC2034
    local item2
    eval "
  for item1 in \"\${${array1_name}[@]}\"; do
    for item2 in \"\${${array2_name}[@]}\"; do
      [[ \"\$item1\" == \"\$item2\" ]] && {
        echo \"\$item1\"
        break
      }
    done
  done
  "
}

array_echo() {
    local array_name=$1
    eval "printf '%s\\n' \"\${${array_name}[@]:-}\""
}

unique_array_add() {
    local array_name=$1
    local item=$2
    local elem
    for elem in "${!array_name}"; do
        [[ "$elem" == "$item" ]] && return 0
    done
    eval "${array_name}+=(\"$item\" )"
}

array_unique() {
    declare -A tmp_array

    for i in "$@"; do
        [[ $i ]] && IFS=" " tmp_array["${i:- }"]=1
    done

    printf '%s\n' "${!tmp_array[@]}"
}

#--------------------------
#  ACTION
#--------------------------

askyes() {
    local msg=$1
    local default=${2:-Y}
    local prompt
    if [[ $default == Y ]]; then
        default=0
        prompt='[Y/n]: '
    elif [[ $default == N ]]; then
        default=1
        prompt='[y/N]: '
    else
        echo "Invalid argument 'default'. Valid value is 'Y' and 'N'. Current=${default}" >&2
        return 3
    fi

    local answer
    while true; do
        read -rp "$msg $prompt " answer

        answer=$(str_lower "$answer")
        if [[ $answer =~ ^ye?s?$ ]]; then
            return 0
        elif [[ $answer =~ ^no?$ ]]; then
            return 1
        elif [[ $answer == '' ]]; then
            [[ "$default" -eq 0 ]] && return 0 || return 1
        else
            continue
        fi
    done
}

get_term_size() {
    # Usage: get_term_size

    # (:;:) is a micro sleep to ensure the variables are
    # exported immediately.
    shopt -s checkwinsize
    (
        :
        :
    )
    echo "$LINES"
    echo "$COLUMNS"
}

bar() {
    # Usage: bar 1 10
    #            ^----- Elapsed Percentage (0-100).
    #               ^-- Total length in chars.
    ((elapsed = $1 * $2 / 100))

    # Create the bar with spaces.
    printf -v prog "%${elapsed}s"
    printf -v total "%$(($2 - elapsed))s"

    printf '%s\r' "[${prog// /-}${total}]"
}

striking-print() {
    local s="$*"
    local n=$((${#s} + 6))
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo '* ' "${s}" ' *'
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
}
