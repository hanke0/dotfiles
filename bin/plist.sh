#!/bin/bash

# >>> hanke0/dotfiles >>>
# !! Contents within this block are managed by https://github.com/hanke0/dotfiles !!

parseoption_usage() {
    local usage optshort optlong valtype varname help
    echo "$1"
    shift
    echo -e "\nOptons:"
    while [ $# -ne 0 ]; do
        optshort="$1"
        optlong="$2"
        valtype="$3"
        varname="$4"
        help="$5"
        shift 5
        case "$valtype" in
        flag)
            echo "  $optshort $optlong	$help"
            ;;
        *)
            if [ -n "$optlong" ]; then
                echo "  $optshort $optlong=$valtype	$help"
            else
                echo "  $optshort=$valtype	$help"
            fi
            ;;
        esac
    done
    echo "  --help        print this text and exit"
}

parseoption1_setvalue() {
    local script

    if eval "declare -p $1 " 2>/dev/null | grep -q '^declare \-a' >/dev/null 2>&1; then
        script=$(
            cat <<EOF
$1+=("\$(cat <<'__EOF__'
$2
__EOF__
)")
EOF
        )
    else
        script=$(
            cat <<EOF
$1=\$(cat <<'__EOF__'
$2
__EOF__
)
EOF
        )
    fi
    eval "$script"
}

# must set optname, optval and optlen
# return set by shiftnum
parseoption1() {
    local relopt relval
    local optshort optlong valtype varname help
    relopt="${optname%%=*}"
    relval="${optname#*=}"
    shiftnum=0
    while [ $# -ne 0 ]; do
        optshort="$1"
        optlong="$2"
        valtype="$3"
        varname="$4"
        help="$5"
        shift 5
        if [ "$relopt" != "$optshort" ] && [ "$relopt" != "$optlong" ]; then
            continue
        fi
        case "$valtype" in
        flag)
            if [ "$relopt" == "$optname" ]; then
                parseoption1_setvalue "$varname" 1
            else
                case "$relval" in
                -[0-9][0-9]* | [0-9][0-9]* | true)
                    parseoption1_setvalue "$varname" 1
                    ;;
                0 | false)
                    parseoption1_setvalue "$varname" 0
                    ;;
                *)
                    echo >&2 "bad flag value must be true(1) or false(0)"
                    return 1
                    ;;
                esac
            fi
            shiftnum=1
            return 0
            ;;
        *)
            if [ "$relopt" != "$optname" ]; then
                parseoption1_setvalue "$varname" "$relval"
                shiftnum=1
                return 0
            else
                if [ "$optlen" -lt 2 ]; then
                    echo >&2 "$relopt must provide a value"
                    return 1
                fi
                parseoption1_setvalue "$varname" "$optval"
                shiftnum=2
                return 0
            fi
            ;;
        esac
    done
    echo >&2 "unknown option: $relopt"
    return 1
}

# parseoption parse options, flags and arguments from a list of parameters.
# usage: parseoption helpstring [parameters]...
#
# Options are named key-value pairs. Keys start with one or two dashes (- or --),
# and a user can separate the key and value with an equal sign (=) or a space.
# This command is called with two options:
#    % example --count=5 --index 2
#
# Flags are like options, but without a paired value.
# Instead, their presence indicates a bool type value.
# A no equal sign(=) contained flag indicates a true value.
# A flag accepts an equal sign and a unsigned integer or true|false to
# define it's value explicitly, but it cannot pass value by a space.
# This command is called with three flags:
#    % example --verbose --quiet=false --strip=true
#
# Arguments are values given by a user and are read in order from first to last
# For example, this command is called with three file names as arguments:
#    % example file1.txt file2.txt file3.txt
#
# The defination of options, flags are passed by global variable `OPTDEF`.
# `OPTDEF` is a array of options defines, each options has 5 fields:
#    optshort:   short name of option, ignore it if got empty string
#    optlong:    long name of option, ignore it if got empty string
#    valtype:    option value type, special value flag defines a flag.
#    varname:    name of variable if option is set. flag value will be set 0 or 1
#    help:       help string of this option.
# This `OPTDEF` contains 1 option and 1 flag:
#    OPTDEF=(
#        ""      --count   NUM    varcount    "the number of run count"
#        -v      --verbose flag   varverbose  "verbose mode"
#    )
#
# Arguments are returned by global array variable `OPTARGS` as is
# input order.
#
# --help flag is added by default. If the help flag is set,
# following values are printed in order and exit:
#     1. the input helpstring
#     2. options and flags defined in OPTDEF
parseoption() {
    OPTARGS=()
    local usage
    usage="$1"
    shift 1
    local optname optval optlen shiftnum
    while [ $# -ne 0 ]; do
        case "$1" in
        --help | --help=*)
            parseoption_usage "$usage" "${OPTDEF[@]}"
            return 1
            ;;
        --)
            shift 1
            OPTARGS+=("$@")
            break
            ;;
        -*)
            optname="$1"
            optval="$2"
            optlen=$#
            parseoption1 "${OPTDEF[@]}" || return 1
            if [ "$shiftnum" -lt 1 ]; then
                return 1
            fi
            shift "$shiftnum"
            ;;
        *)
            OPTARGS+=("$1")
            shift
            ;;
        esac
    done
}

flagisset() {
    [ "$1" = 1 ]
}
# <<< hanke0/dotfiles <<<

OPTDEF=(
    -r --regexp PATTERN searchpattern "search cmd by regular expression. mutual exclusion with -f option."
    -f --fixed-string PATTERN searchfixedstring "search cmd by fixed string.  mutual exclusion with -r option."
    -e --exclude-regex PATTERN excludepattern "ignore cmd by regular expression."
    -E --exclude-fixed-string PATTERN excludefixedstring "ignore cmd by fixed string."
    -p --pid PIDs pidlist "select by process ids."
    "" --ppid PPIDs ppidlist "select by parent process ids."
    -g --group GROUPs grouplist "select by real group ids."
    "" --sid SIDs sidlist "select by session ids."
    -u --user USERs uidlist "select by user id or name."
    -c --command CMDs cmdlist "select by command name."
    -S --state STATE statecode "select by process state."
    -s --pidsid PID pidsid "select by pid's sid"
    -t --tree flag treeflag "acsii art process hierarchy."
    -a --simple flag simplecmd "output only executeable name istead "
    "" --self flag selfflag "do not ignore plist it self."
)

parseoption "$(
    cat <<EOF
Usage: $0 [OPTIONS..]
Search processes.

PRPCESS STATE CODES
    D    uninterruptible sleep (usually I/O)
    I    idle kernel thread
    R    running or runnable (on run queue)
    S    interruptible sleep (waiting for an
         event to complete)
    T    stopped by job control signal
    t    stopped by debugger during the tracing
    W    paging (not valid since Linux 2.6)
    X    dead (should never be seen)
    Z    defunct ("zombie") process, terminated
         but not reaped by its parent
EOF
)" "$@" || exit 1

if [ "${#OPTARGS[@]}" -gt 0 ]; then
    echo >&2 "Unknown arguments: ${OPTARGS[*]}"
    echo >&2 "Try '$(basename "$0usago") --help' for more information."
    exit 1
fi

fields="user=USER,pid=PID,ppid=PPID,sess=SID,state=STATE,etime=ELAPSED,start=STARTED,cputime=TIME,rss=RSS"
if flagisset "${simplecmd:-}"; then
    fields="${fields},comm=COMMAND"
else
    fields="${fields},args=COMMAND"
fi

psoptions=(
    -o "${fields}" -ww
)

_get_pid_sid() {
    local c
    c=$(ps -o sess= -p "$1" | sort -u | xargs printf '%s,')
    printf "%s" "${c%,}"
}

_add_options_if_not_empty() {
    local k v
    k="$1"
    v="$2"
    [ -n "$v" ] && psoptions+=("$k" "$v")
}

beforenum="${#psoptions[@]}"
_add_options_if_not_empty -p "${pidlist:-}"
_add_options_if_not_empty -p "${ppidlist:-}"
_add_options_if_not_empty -g "${grouplist:-}"
_add_options_if_not_empty -s "${sidlist:-}"
_add_options_if_not_empty -u "${uidlist:-}"
_add_options_if_not_empty -C "${cmdlist:-}"
[ -n "${pidsid:-}" ] && _add_options_if_not_empty -s "$(_get_pid_sid "$pidsid")"

if [ "${#psoptions[@]}" = "${beforenum}" ]; then
    psoptions+=(-e)
else
    if [ -n "$searchpattern" ]; then
        psoptions+=(-e)
    else
        [ -n "$searchfixedstring" ] && psoptions+=(-e)
    fi
fi

if flagisset "${treeflag:-}"; then
    psoptions+=(--forest)
fi

content=$(ps "${psoptions[@]}")
[ -z "$content" ] && {
    echo >&2 "ps failed, args:"
    printf '%q ' "${psoptions[@]}"
    exit 1
}
header=$(head -n 1 <<<"$content")
body=$(tail -n +2 <<<"$content")

if [ -n "${statecode}" ]; then
    statecode=$(tr '[:lower:]' '[:upper:]' <<<"$statecode")
    body=$(awk "\$4==\"${statecode}\"" <<<"$body")
fi

awkbody() {
    local awkscript
    awkscript="{c=\"\"; for(i=10;i<=NF;i++) c=c SUBSEP \$i} c$1 {print \$0}"
    body=$(awk "${awkscript}" <<<"$body")
}

if [ -n "$searchpattern" ]; then
    # shellcheck disable=SC2088
    awkbody "~/${searchpattern}/"
fi
if [ -n "$searchfixedstring" ]; then
    awkbody "==\"${searchfixedstring}\""
fi
if [ -n "$excludepattern" ]; then
    awkbody "!~/${excludepattern}/"
fi
if [ -n "$excludefixedstring" ]; then
    awkbody "!=${excludefixedstring}"
fi
if ! flagisset "${selfflag:-}"; then
    body=$(awk "\$2 != $$ && \$3 != $$ {print}" <<<"$body")
fi
echo "$header"
[ -n "$body" ] && echo "$body"
