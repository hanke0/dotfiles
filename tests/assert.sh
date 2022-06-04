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
    printf "\n${COLOR_BOLD}${COLOR_CYAN}==========  %s  ==========${COLOR_RESET}\n" "$@" >&2
}

log_success() {
    printf "${COLOR_GREEN}✔ %s${COLOR_RESET}\n" "$*" >&2
}

log_failure() {
    printf "${COLOR_RED}✖ %s${COLOR_RESET}\n" "$*" >&2
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="$3"

    if [ "$expected" != "$actual" ]; then
        log_failure "'$expected' != '$actual' :: $msg"
        return 1
    else
        log_success ""
        return 0
    fi
}

assert_true() {
    local condition="$1"

    if ! eval "$condition"; then
        log_failure "$condition return false :: $msg"
        return 1
    else
        log_success ""
        return 0
    fi
}

assert_filepath_exist() {
    local file="$1"
    local msg="$2"
    if [ -e "$file" ]; then
        log_success ""
        return 0
    else
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

    else
        log_success ""
        return 0
    fi
}

assert_file_exist() {
    local file="$1"
    local msg="$2"
    if [ -f "$file" ]; then
        log_success ""
        return 0
    else
        log_failure "$file should exist :: $msg"
        return 1
    fi
}

assert_file_not_exist() {
    local file="$1"
    local msg="$2"
    if [ -f "$file" ]; then
        log_failure "$file should not exist :: $msg"
        return 1

    else
        log_success ""
        return 0
    fi
}

assert_dir_exist() {
    local file="$1"
    local msg="$2"
    if [ -d "$file" ]; then
        log_success ""
        return 0
    else
        log_failure "$file should exist :: $msg"
        return 1
    fi
}

assert_dir_not_exist() {
    local file="$1"
    local msg="$2"
    if [ -d "$file" ]; then
        log_failure "$file should not exist :: $msg"
        return 1

    else
        log_success ""
        return 0
    fi
}

runtest() {
    local exit_code=0
    log_header "${BASH_SOURCE[0]}"
    for var in $(declare -F); do
        var=$(echo "$var" | cut -d' ' -f3)
        if [[ $var != test* ]]; then
            continue
        fi
        printf "[TEST %s]:: " "$var"
        eval "$var"
        exit_code=$?
    done
    [[ "$exit_code" -eq 0 ]] && return 0 || return 1
}
