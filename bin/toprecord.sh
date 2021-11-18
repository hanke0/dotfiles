#!/usr/bin/env bash

case "$1" in
-h | \? | --help | "")
    echo "Usage: $0 pattern"
    echo "This script will output the process memory and cpu usage repeatly."
    echo "the output has following format: date time pid RES %CPU"
    exit 127
    ;;
*) ;;
esac

top -b -d1 | grep --line-buffered -E "$1" |
    grep --line-buffered -v "grep --line-buffered -E $1" |
    grep -v --line-buffered "$0" |
    awk '{print strftime("%Y-%m-%e %H:%M:%S"),$1,$6,$9;fflush(stdout)}'
