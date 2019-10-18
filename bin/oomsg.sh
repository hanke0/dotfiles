#!/usr/bin/env bash
if [[ $(uname) =~ "Darwin" ]]; then
    dmesg | grep -E -i -B100 'killed process'
else
    dmesg | grep -E -i -B100 'killed process'
fi