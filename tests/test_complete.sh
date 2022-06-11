#!/usr/bin/env bash

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]...

Options:
  -a=[a|b|1|2]            usage
  -b --b1=[a|b|1|2]       choices
     --b2=[a|b|1|2]       choices
  -c                      help
  -d --d1                 help
     --d2                 help
  -e=FILE                 file
  -f --f1=FILE            file
     --f2=FILE            file
  -g=DIRECTORY            path
  -h --h1=DIRECTORY       path
     --h2=DIRECTORY       path
  -i[=NUMBER]             number
  -j --j1[=NUMBER]        number
     --j2[=NUMBER]        number
  -k[=DIR]                file
  -l, --l1[=DIR]          file
      --l2[=DIR]          file
  -m[=[a|b|1|2]]          choices
  -n, --n1[=[a|b|1|2]]    choices
      --n2[=[a|b|1|2]]    choices
EOF
}

if [ "$1" = '--help' ]; then
    usage
    exit 0
fi

# source relative path is not realy a problem
# shellcheck disable=SC1091
source ./tests/assert.sh
# shellcheck disable=SC1091
source ./bin/_bash-complete.sh

test_opts_match_length() {
    _common_option_complete ./tests/test_complete.sh "-" ""
    assert_eq \
        "28" \
        "${#COMPREPLY[@]}" "${COMPREPLY[*]}"
}

test_opts_file_match_length() {
    opts="$(_common_option_file_opts ./tests/test_complete.sh)"
    assert_string_array_len \
        "$opts" "4" "$opts"
}

test_opts_dir_match_length() {
    opts="$(_common_option_dir_opts ./tests/test_complete.sh)"
    assert_string_array_len \
        "$opts" "8" "$opts"
}

test_opts_empty() {
    _test_opts_file_match "-c"
}

_test_opts_file_match() {
    _common_option_complete ./tests/test_complete.sh "" "$1"
    assert_filepath_exist "${COMPREPLY[1]}" "${COMPREPLY[*]}"
}

test_opts_file_match_only_short() {
    _test_opts_file_match "-e"
}

test_opts_file_match_short_long_short() {
    _test_opts_file_match "-f"
}

test_opts_file_match_short_long_long() {
    _test_opts_file_match "--f1"
}

test_opts_file_match_only_long() {
    _test_opts_file_match "--f2"
}

_test_opts_dir_match() {
    _common_option_complete ./tests/test_complete.sh "" "$1"
    assert_dir_exist "${COMPREPLY[1]}" "${COMPREPLY[*]}"
}

test_opts_dir_match_only_short() {
    _test_opts_dir_match "-g"
}

test_opts_dir_match_short_long_short() {
    _test_opts_dir_match "-h"
}

test_opts_dir_match_short_long_long() {
    _test_opts_dir_match "--h1"
}

test_opts_dir_match_only_long() {
    _test_opts_dir_match "--h2"
}

test_opts_dir_match_optional_only_short() {
    _test_opts_file_match "-k"
}

test_opts_dir_match_optional_short_long_short() {
    _test_opts_file_match "-l"
}

test_opts_dir_match_optional_short_long_long() {
    _test_opts_dir_match "--l1"
}

test_opts_dir_match_optional_only_long() {
    _test_opts_dir_match "--l2"
}

_test_opts_choice_match() {
    _common_option_complete ./tests/test_complete.sh "" "$1"
    # quoting is unnecessary here.
    # shellcheck disable=SC2068,SC2116
    assert_eq "a b 1 2" "$(echo ${COMPREPLY[@]})"
}

test_opts_choice_match_only_short() {
    _test_opts_choice_match "-a"
}

test_opts_choice_match_short_long_short() {
    _test_opts_choice_match "-b"
}

test_opts_choice_match_short_long_long() {
    _test_opts_choice_match "--b1"
}

test_opts_choice_match_only_long() {
    _test_opts_choice_match "--b2"
}

test_opts_choice_match_optional_only_short() {
    _test_opts_choice_match "-m"
}

test_opts_choice_match_optional_short_long_short() {
    _test_opts_choice_match "-n"
}

test_opts_choice_match_optional_short_long_long() {
    _test_opts_choice_match "--n1"
}

test_opts_choice_match_optional_only_long() {
    _test_opts_choice_match "--n2"
}

runtest
