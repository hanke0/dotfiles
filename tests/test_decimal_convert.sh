#!/bin/bash

#!/usr/bin/env bash
set -e

# source relative path is not realy a problem
# shellcheck disable=SC1091
source ./tests/assert.sh
# shellcheck disable=SC1091
source ./.bashrc

_dopipeconvert() {
    local a
    a="$1"
    shift
    while [ $# -gt 0 ]; do
        testlog "$1 $a -> $($1 "$a")"
        a=$("$1" "$a")
        shift
    done
    echo "$a"
}

test_hex() {
    assert_eq a \
        "$(
            _dopipeconvert a \
                char2hex hex2int int2hex hex2char char2hex hex2bin bin2hex hex2char \
                char2int int2hex hex2int int2char char2int int2bin bin2int int2char \
                char2hex hex2char char2int int2char char2bin bin2char \
                char2bin bin2hex hex2bin bin2int int2bin bin2char char2bin \
                bin2char
        )"
}

runtest
