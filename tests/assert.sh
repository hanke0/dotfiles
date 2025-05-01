#!/usr/bin/env bash

export COLOR_RESET='\e[0m'
export COLOR_RED='\e[31m'
export COLOR_GREEN='\e[32m'
export COLOR_YELLOW='\e[33m'
export COLOR_BLUE='\e[34m'
export COLOR_PURPLE='\e[35m'
export COLOR_CYAN='\e[36m'
export COLOR_LIGHTGRAY='\e[37m'
export COLOR_BOLD='\e[01m'

log_header() {
    printf "\n${COLOR_BOLD}${COLOR_CYAN}==========  %s  ==========${COLOR_RESET}\n" "$@"
}

log_success() {
    printf "${COLOR_GREEN}✔ %s${COLOR_RESET}\n" "$*"
}

log_failure() {
    printf "${COLOR_RED}✖ %s${COLOR_RESET}\n" "$*"
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="$3"

    if [ "$expected" != "$actual" ]; then
        log_failure "'$expected' != '$actual' :: $msg"
        return 1
    fi
}

assert_true() {
    local condition="$1"

    if ! eval "$condition"; then
        log_failure "$condition return false :: $msg"
        return 1
    fi
}

assert_filepath_exist() {
    local file="$1"
    local msg="$2"
    if [ ! -e "$file" ]; then
        log_failure "$file should exist :: $msg"
        return 1
    fi
}

assert_filepath_not_exist() {
    local file="$1"
    local msg="$2"
    if [ -e "$file" ]; then
        log_failure "$file should not exist :: $msg"
        return 1
    fi
}

assert_file_exist() {
    local file="$1"
    local msg="$2"
    if [ ! -f "$file" ]; then
        log_failure "$file should exist exist as a file :: $msg"
        return 1
    fi
}

assert_file_not_exist() {
    local file="$1"
    local msg="$2"
    if [ -f "$file" ]; then
        log_failure "$file should not exist :: $msg"
        return 1
    fi
}

assert_dir_exist() {
    local file="$1"
    local msg="$2"
    if [ ! -d "$file" ]; then
        log_failure "$file should exist as a directory :: $msg"
        return 1
    fi
}

assert_dir_not_exist() {
    local file="$1"
    local msg="$2"
    if [ -d "$file" ]; then
        log_failure "$file should not exist :: $msg"
        return 1
    fi
    return 0
}

assert_string_array_len() {
    local s="$1"
    local len="$2"
    local msg="$3"
    local i array line
    i=0
    # cannot use ${variable//search/replace} to replace sed.
    # shellcheck disable=SC2001
    array="$(sed "s/[[:blank:]][[:blank:]]*/\n/g" <<<"$s")"
    while read -r line; do [ -n "$line" ] && ((i++)); done <<<"$array"
    if [ "$i" -ne "$len" ]; then
        log_failure "string array len $i != $len :: $msg"
        return 1
    fi
    return 0
}

testlog() {
    echo >&2 "$@"
}

runtest() {
    local logfile
    log_header "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
    logfile=$(mktemp)
    trap "rm -f \"$logfile\"" EXIT
    for var in $(declare -F); do
        var=$(echo "$var" | cut -d' ' -f3)
        if [[ $var != test_* ]]; then
            continue
        fi
        printf "[TEST %s]:: " "$var"
        if ! "${var}" 2>"${logfile}"; then
            echo >&2 "Log:"
            cat >&2 "${logfile}"
            exit 1
        else
            log_success ""
        fi
    done
}
