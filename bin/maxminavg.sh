#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    LINE="\$1"
else
    LINE="\$$1"
fi

awk '
BEGIN { sum=0;max=0;min=0;maxset=0;minset=0; }
{
    if (maxset==0||$LINE>max) {max=$LINE;maxset=1}
    if (minset==0||$LINE<min) {min=$LINE;minset=1}
    sum+=$LINE;
}
END {print max"/"min"/"sum/NR}
'
