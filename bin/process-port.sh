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
  -n --netstat            using netstat instead of lsof. (only true if lsof is not install or set this value.)
EOF
}

NETSTAT=false

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
    -n | --netstat)
        NETSTAT=true
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

if ! command -v lsof >/dev/null 2>&1; then
    NETSTAT=true
fi

std_lsof() {
    [ $(lsof -nP -iTCP -sTCP:LISTEN 2>&1 | head -1 | awk '(NF==9&&$1=="COMMAND"){print "true"}') = true ]
}

std_netstat() {
    [ $(netstat -tnlp | head -2 | awk '(NR==2&&NF==10&&$1=="Proto"){print "true"}') = true ]
}

if [ "${NETSTAT}" != true ]; then
    if ! std_lsof; then
        NETSTAT=true
    fi
fi

if [ "${NETSTAT}" == true ]; then
    if ! std_netstat; then
        echo >&2 "netstat nor lsof output is a standard"
        exit 1
    fi
fi

grep_by_port() {
    local port
    port="$1"
    if [ "$NETSTAT" = true ]; then
        netstat -tlpn 2>/dev/null | awk -v pattern=":$port\$" '(NR > 2 && $4 ~ pattern){printf "%-8s %-20s %-30s\n", $1, $4, $7}'
    else
        lsof -nP "-iTCP:${port}" -sTCP:LISTEN | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
        lsof -nP "-iUDP:${port}" | grep -v -- "->" | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
    fi
}

grep_by_pid() {
    local pid
    pid="$1"
    if [ "$NETSTAT" = true ]; then
        netstat -tulpn 2>/dev/null | awk -v pattern="^$pid/" \
            '(NR > 2 && $7 ~ pattern){printf "%-8s %-20s %-30s\n", $1,$4,$7} (NR > 2 && $6 ~ pattern){ printf "%-8s %-20s %-30s\n",$1,$4,$6}'
    else
        lsof -nP -a -p "${pid}" -iTCP -sTCP:LISTEN | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
        lsof -nP -a -p "${pid}" -iUDP | grep -v -- "->" | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
    fi
}

grep_by_name() {
    local name="$1"
    if [ "$NETSTAT" = true ]; then
        netstat -tulpn 2>/dev/null | awk -v pattern="/$name" \
            '(NR > 2 && $7 ~ pattern){printf "%-8s %-20s %-30s\n", $1,$4,$7} (NR > 2 && $6 ~ pattern){ printf "%-8s %-20s %-30s\n",$1,$4,$6}'
    else
        processes="$(ps axo pid=,command=)"
        pids="$(echo "$processes" | grep "${name}" | awk '{print $1}' | xargs printf '%s,')"
        lsof -nP -a -p "${pids}" -iTCP -sTCP:LISTEN | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
        lsof -nP -a -p "${pids}" -iUDP | grep -v -- "->" | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
    fi
}

all_port() {
    if [ "$NETSTAT" = true ]; then
        netstat -tulpn 2>/dev/null | awk 'NR>2 {printf "%-8s %-20s %-30s\n", $1, $4, $7}'
    else
        lsof -nP -iTCP -sTCP:LISTEN | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
        lsof -nP -iUDP | grep -v -- "->" | awk '(NR>1){printf "%-5s %-5s %-10s %-20s\n",$5,$8,$2,$9}' || true
    fi
}

main() {
    local arg result
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
        if [ "$NETSTAT" = true ]; then
            printf "%-8s %-20s %-30s\n" "Proto" "ListenAddress" "PID/ProcessName"
        else
            printf "%-5s %-5s %-10s %-20s\n" "Type" "Proto" "PID" "Address"
        fi

        echo "$result"
    fi
}

if [ "$EUID" -ne 0 ]; then
    echo >&2 "You would have to be root to see all process."
fi

main
