#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [PROCESS NAMES]...
Show process listen ports.

Output format example:
Proto    ListenAddress    PID/ProcessName
tcp      0.0.0.0:80       1234/nginx
tcp      0.0.0.0:443      1234/nginx

Options:
  -h --help               print this help and exit.
  -p --port               treat arguments as port and show all process that listen to port.
EOF
}

declare -a args
while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -p | --port)
        PORTMODE=true
        shift
        ;;
    --)
        shift 1
        args+=("$@")
        break
        ;;
    -*)
        echo >&2 "unknown option: $1"
        exit 1
        ;;
    *)
        args+=("$1")
        shift 1
        ;;
    esac
done

grep_by_port() {
    local port
    port="$1"
    netstat -tulpn 2>/dev/null | awk -v pattern=":$port" '(NR > 2 && $4 ~ pattern){printf "%-8s %-30s %-30s\n", $1, $4, $7}'
}

grep_by_pid() {
    local pid
    pid="$1"
    netstat -tulpn 2>/dev/null | awk -v pattern="^$pid" '(NR > 2 && $7 ~ pattern){printf "%-8s %-30s %-30s\n", $1, $4, $7}'
}

grep_by_name() {
    local name="$1"
    netstat -tulpn 2>/dev/null | awk -v pattern="/$name" '(NR > 2 && $7 ~ pattern){printf "%-8s %-30s %-30s\n", $1, $4, $7}'
}

all_port() {
    netstat -tulpn 2>/dev/null | awk 'NR>2 {printf "%-8s %-30s %-30s\n", $1, $4, $7}'
}

main() {
    local grepfunc arg result
    if [ "${#args}" -eq 0 ]; then
        result="$(all_port)"
    else
        for arg in "${args[@]}"; do
            if [ "${PORTMODE}" = "true" ]; then
                result="${result}$(grep_by_port "$arg")"
            else
                if [[ -n ${arg//[0-9]/} ]]; then
                    result="${result}$(grep_by_name "$arg")"
                else
                    result="${result}$(grep_by_pid "$arg")"
                fi
            fi
        done
    fi
    result="$(echo "$result" | grep -v '^$')"
    if [ -n "$result" ]; then
        printf "%-8s %-30s %-30s\n" "Proto" "ListenAddress" "PID/ProcessName"
        echo "$result"
    fi
}

main
