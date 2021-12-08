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

# avoid using ~/.toprc
tp="$(mktemp)"
rm "$tp"
ln -s "$(type -p top)" "$tp"
trapfinish() {
    rm "$tp"
}
trap 'trapfinish' EXIT

pids="$(pgrep -d, -f "$1")"
# output format
# yyyy-mm-dd hh-mm-ss pid res %cpu command
"$tp" -w 512 -c -b -d1 -p "$pids" 
    grep --line-buffered "^ *[0-9]" |
    grep --line-buffered -v "$0" |
    awk '{print strftime("%Y-%m-%d %H:%M:%S"),$1,$6,$9,$12; fflush(stdout)}'
