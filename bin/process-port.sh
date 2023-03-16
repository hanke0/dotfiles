#!/usr/bin/env bash

set -e
set -o pipefail

usage() {
    cat <<EOF
Usage: ${0##*/} [OPTION]... [PROCESS NAMES OR PORT]...
Show process listen ports.

Output format example:
Proto    ListenAddress        PID          ProcessName
TCP      127.0.0.1:80         912          nginx

Options:
  -h, --help               print this help and exit.
  -p, --pid                treat arguments as pid.
      --netstat            force use netstat.
      --lsof               force use lsof.
      --nohead             do not print head
EOF
}

NETSTAT=
NOHEAD=
declare -a args
while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -p | --pid)
        PIDMODE=true
        shift
        ;;
    --netstat)
        NETSTAT=true
        shift
        ;;
    --lsof)
        NETSTAT=false
        shift
        ;;
    --nohead)
        NOHEAD=true
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

good_lsof() {
    command -v lsof >/dev/null 2>&1 &&
        [ $(lsof -nP -iTCP -sTCP:LISTEN 2>&1 | head -1 | awk '(NF==9&&$1=="COMMAND"){print "true"}') = true ]
}

good_netstat() {
    command -v lsof >/dev/null 2>&1 &&
        [ $(netstat -tnlp | head -2 | awk '(NR==2&&NF==10&&$1=="Proto"){print "true"}') = true ]
}

setusage() {
    if [ "${NETSTAT}" = true ]; then
        if good_netstat; then
            return
        fi
        echo >&2 "netstat output is a standard"
        exit 1
    fi
    if [ "${NETSTAT}" = false ]; then
        if good_netstat; then
            return
        fi
        echo >&2 "netstat output is a standard"
        exit 1
    fi

    if good_lsof; then
        NETSTAT=false
        return
    fi
    if good_netstat; then
        NETSTAT=true
        return
    fi
    echo >&2 "netstat nor lsof output is a standard"
    exit 1
}
setusage

pidname() {
    ps -o comm=, -p "$1"
}

tcpawknetstat='{out = $7; for (i = 8; i <= NF; i++) {out = out " " $i};pid=substr(out,0,index(out,"/")-1);comm=substr(out,index(out,"/")+1);printf "%-8s %-20s %-12s %-30s\n",$1,$4,pid,comm}'
udpawknetstat='{out = $6; for (i = 7; i <= NF; i++) {out = out " " $i};pid=substr(out,0,index(out,"/")-1);comm=substr(out,index(out,"/")+1);printf "%-8s %-20s %-12s %-30s\n",$1,$4,pid,comm}'
tcpawklsof='{printf "%-8s %-20s %-12s\n",$8,$9,$2}'
udpawklsof='{printf "%-8s %-20s %-12s\n",$8,$9,$2}'

grep_by_port() {
    local port
    port="$1"
    if [ "$NETSTAT" = true ]; then
        netstat -tlpn 2>/dev/null | awk -v pattern=":$port\$" \
            "(NR > 2 && \$4 ~ pattern)${tcpawknetstat}"
    else
        lsof -nP "-iTCP:${port}" -sTCP:LISTEN | awk "(NR>1)${tcpawklsof}" || true
        lsof -nP "-iUDP:${port}" | grep -v -- "->" | awk "(NR>1)${udpawklsof}" || true
    fi
}

grep_by_pid() {
    local pid
    pid="$1"
    if [ "$NETSTAT" = true ]; then
        netstat -tulpn 2>/dev/null | awk -v pattern="^$pid/" \
            "(NR > 2 && \$7 ~ pattern)${tcpawknetstat}
             (NR > 2 && \$6 ~ pattern)${udpawknetstat}"
    else
        lsof -nP -a -p "${pid}" -iTCP -sTCP:LISTEN | awk "(NR>1)${tcpawklsof}" || true
        lsof -nP -a -p "${pid}" -iUDP | grep -v -- "->" | awk "(NR>1)${udpawklsof}" || true
    fi
}

grep_by_name() {
    local name="$1"
    if [ "$NETSTAT" = true ]; then
        netstat -tulpn 2>/dev/null | awk -v pattern="/$name" \
            "(NR > 2 && \$7 ~ pattern)${tcpawknetstat}
             (NR > 2 && \$6 ~ pattern)${udpawknetstat}"
    else
        processes="$(ps axo pid=,command=)"
        pids="$(echo "$processes" | grep "${name}" | awk '{print $1}' | xargs printf '%s,')"
        lsof -nP -a -p "${pids}" -iTCP -sTCP:LISTEN | awk "(NR>1)${tcpawklsof}" || true
        lsof -nP -a -p "${pids}" -iUDP | grep -v -- "->" | awk "(NR>1)${udpawklsof}" || true
    fi
}

all_port() {
    if [ "$NETSTAT" = true ]; then
        netstat -tlpn 2>/dev/null | awk "NR>2${tcpawknetstat}"
        netstat -ulpn 2>/dev/null | awk "NR>2${udpawknetstat}"
    else
        lsof -nP -iTCP -sTCP:LISTEN | awk "(NR>1)${tcpawklsof}" || true
        lsof -nP -iUDP | grep -v -- "->" | awk "(NR>1)${udpawklsof}" || true
    fi
}

main() {
    local arg result line
    if [ "${#args}" -eq 0 ]; then
        result="$(all_port)"
    else
        for arg in "${args[@]}"; do
            if [ "${PIDMODE}" = "true" ]; then
                result="${result}$(grep_by_pid "$arg")"
            else
                if [[ -n ${arg//[0-9]/} ]]; then
                    result="${result}$(grep_by_name "$arg")"
                else
                    result="${result}$(grep_by_port "$arg")"
                fi
            fi
        done
    fi
    result="$(echo "$result" | grep -v '^$')"
    if [ -n "$result" ]; then
        if [ ! "${NOHEAD}" = true ]; then
            printf "%-8s %-20s %-12s %-30s\n" "Proto" "ListenAddress" "PID" "ProcessName"
        fi
        if [ "$NETSTAT" = true ]; then
            echo "${result}"
        else
            while IFS= read -r line; do
                printf '%s %s\n' "${line}" "$(pidname "$(awk '{print $3}' <<<"${line}")")"
            done <<<"${result}"
        fi
    fi
}

if [ "$EUID" -ne 0 ]; then
    echo >&2 "You would have to be root to see all process."
fi

main
