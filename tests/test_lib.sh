#!/usr/bin/env bash
set -e
source ./tests/assert.sh
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

test_dict_get_item() {
    declare -A a=()
    dict_put a "a" "a"
    assert_eq $(dict_get a "a") "a"
}
test_dict_getitem_not_exists() {
    declare -A a=()
    dict_put a "a" "a"
    assert_eq $(dict_get a "c") ""
}
test_dict_remove() {
    declare -A a=()
    dict_put a "a" "a"
    dict_remove a "a"
    assert_eq $(dict_get a "a") ""
}
test_dict_clean() {
    declare -A a=()
    dict_put a "a" "a"
    dict_clear a
    assert_eq $(dict_get a "a") ""
}

runtest "${BASH_SOURCE[0]}"
