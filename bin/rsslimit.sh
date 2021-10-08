#!/usr/bin/env bash

set -e

RssOf() {
    grep ^Rss /proc/"$1"/smaps | awk '{sum += $2} END {print sum}'
}

usage() {
    echo 'Kill process if it reach max limit.'
    echo
    echo 'Usage:'
    echo " $0 [options] RssLimit[KB] PID"
    echo
    echo 'Options:'
    echo '    -s    Interval in seconds, positive number'
    echo '    -q    Quiet'
}

wrong-usage() {
    echo 'Wrong Usage' "$1"
    usage
    exit 2
}

quiet=0
interval=1

IsNum='^[0-9]+$'

while getopts s:qm:h opt; do
    case ${opt} in
    s)
        interval=$OPTARG
        ;;
    q)
        quiet=1
        ;;
    m)
        MAX=$OPTARG
        ;;
    h)
        usage
        exit 0
        ;;
    : | ?)
        usage
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

[[ $# -ne 2 ]] && wrong-usage

[[ -n $1 ]] && PID=$1

[[ -z ${MAX} || ! ${MAX} =~ ${IsNum} ]] && wrong-usage 'wrong Rss'
[[ -z ${PID} || ! ${PID} =~ ${IsNum} ]] && wrong-usage 'wrong PID'

[[ ! ${interval} =~ ${IsNum} ]] && wrong-usage 'wrong interval'

[[ ! -e /proc/${PID}/smaps ]] && echo >&2 PID not exists && exit 1

echo Listen PID "${PID}" RssLimit "${MAX}" KB

while :; do
    _rss=$(RssOf "${PID}")
    [[ ${quiet} -eq 0 ]] && echo >&2 USE ${_rss} kb
    if [[ ${_rss} -gt ${MAX} ]]; then
        echo >&2 Overflow, kill PID "${PID}"
        kill "${PID}"
        exit 1
    fi
    sleep "${interval}"
done
