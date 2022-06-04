#!/usr/bin/env bash

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]...

Options:
  -c --choice=[a|b|1|2]      choices
  -y=[a|b|1|2]                usage
     --choice1=[a|b|1|2]      choices
  -h --help               print this help and exit
  -f=FILE                 file
  -i --file=FILE          file
     --file1=FILE         file
  -p --path=PATH          path
  -a=PATH                 path
     --path1=PATH         path
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

test_opts_match() {
    _common_option_complete ./tests/test_complete.sh "-" ""
    assert_eq \
        "14" \
        "${#COMPREPLY[@]}" "${COMPREPLY[*]}"
}

_test_opts_filematch() {
    _common_option_complete ./tests/test_complete.sh "" "$1"
    assert_filepath_exist "${COMPREPLY[1]}" "${COMPREPLY[*]}"
}

test_opts_filematch_only_short() {
    _test_opts_filematch "-f"
}

test_opts_filematch_short_long_short() {
    _test_opts_filematch "-i"
}

test_opts_filematch_short_long_long() {
    _test_opts_filematch "--file"
}

test_opts_filematch_only_long() {
    _test_opts_filematch "--file1"
}

_test_opts_dirmatch() {
    _common_option_complete ./tests/test_complete.sh "" "$1"
    assert_dir_exist "${COMPREPLY[1]}" "${COMPREPLY[*]}"
}

test_opts_dirmatch_only_short() {
    _test_opts_dirmatch "-a"
}

test_opts_dirmatch_short_long_short() {
    _test_opts_dirmatch "-p"
}

test_opts_dirmatch_short_long_long() {
    _test_opts_dirmatch "--path"
}

test_opts_dirmatch_only_long() {
    _test_opts_dirmatch "--path1"
}

_test_opts_choicematch() {
    _common_option_complete ./tests/test_complete.sh "" "$1"
    # quoting is unnecessary here.
    # shellcheck disable=SC2068,SC2116
    assert_eq "a b 1 2" "$(echo ${COMPREPLY[@]})"
}

test_opts_choicematch_only_short() {
    _test_opts_choicematch "-y"
}

test_opts_choicematch_short_long_short() {
    _test_opts_choicematch "-c"
}

test_opts_choicematch_short_long_long() {
    _test_opts_choicematch "--choice"
}

test_opts_choicematch_only_long() {
    _test_opts_choicematch "--choice1"
}

test_opts_empty() {
    _test_opts_filematch "-h"
}

runtest
