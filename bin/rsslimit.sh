#!/usr/bin/env bash

set -e

RssOf() {
    grep ^Rss /proc/"$1"/smaps | awk '{sum += $2} END {print sum}'
}

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION] <rss-bytes> <max-kilobytes> 
Warning process if it reach max limit.

Option:
    -s    interval in seconds, positive number.
    -q    quiet output.
    -k    kill it when reach max limit
    -n    signal number passed to kill
EOF
}

wrong-usage() {
    echo 'Wrong Usage' "$1"
    usage
    exit 2
}

quiet=0
interval=1

IsNum='^[0-9]+$'
PID=
MAX=
KILL=0
KILLARGS=

while [ $# -gt 0 ]; do
    case "$1" in
    -s)
        interval="$2"
        shift 2
        ;;
    -q)
        quiet=1
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    -k)
        KILL=1
        ;;
    -n)
        KILLARGS="-n $2"
        shift 2
        ;;
    *)
        if [ -n "$PID" ]; then
            if [ -n "$MAX" ]; then
                wrong-usage "too many pids"
            else
                MAX="$1"
            fi
        else
            PID="$1"
        fi
        shift
        ;;
    esac
done

[ -z "$PID" ] && wrong-usage "must provides one pid"
[ -z "$MAX" ] && wrong-usage "must provides memory limit"

[[ -z ${MAX} || ! ${MAX} =~ ${IsNum} ]] && wrong-usage 'wrong Rss'
[[ -z ${PID} || ! ${PID} =~ ${IsNum} ]] && wrong-usage 'wrong PID'
[[ ! ${interval} =~ ${IsNum} ]] && wrong-usage 'wrong interval'

[[ ! -e /proc/${PID}/smaps ]] && echo >&2 PID not exists && exit 1

echo Listen PID "${PID}" RssLimit "${MAX}" KB

while true; do
    _rss=$(RssOf "${PID}")
    [[ ${quiet} -eq 0 ]] && echo >&2 "USE ${_rss} KB"
    if [[ ${_rss} -gt ${MAX} ]]; then
        echo >&2 "Overflow of pid ${PID} RSS: ${_rss}KB"
        if [ $KILL -ne 0 ]; then
            echo >&2 "kill $KILLARGS ${PID}"
            kill $KILLARGS $PID
        fi
        exit 1
    fi
    sleep "${interval}"
done
