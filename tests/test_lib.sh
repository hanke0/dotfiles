#!/usr/bin/env bash
set -e

# source relative path is not realy a problem
# shellcheck disable=SC1091
source ./tests/assert.sh
# shellcheck disable=SC1091
source ./bin/lib.sh

test_str_match() {
    local s
    s=$(str_match 'version = "0.1.2"' "version ? = ?\"(.+)\"")
    assert_eq "$s" "0.1.2" "${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME[0]}"
    return $?
}

test_str_trim_space() {
    local s
    s=$(str_trim ' aaa c aaa  ')
    assert_eq "$s" 'aaa c aaa'
}

test_str_trim_word() {
    local s
    s=$(str_trim 'aaa c aaa' "a")
    assert_eq "$s" 'aa c aa'
}

runtest "${BASH_SOURCE[0]}"
