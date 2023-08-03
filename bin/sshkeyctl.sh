#!/usr/bin/env bash

set -e
set -o pipefail

commandusage() {
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
    if eval "declare -p $1 " 2>/dev/null | grep -q '^declare \-a' >/dev/null 2>&1; then
        eval "$1+=('$2')"
    else
        eval "$1='$2'"
    fi
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
            commandusage "$usage" "${OPTDEF[@]}"
            return 1
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

get_local_sshkey() {
    local file
    for file in ~/.ssh/id_ed25519 ~/.ssh/id_rsa; do
        if [ -f "$file" ]; then
            echo "$file"
            return
        fi
    done
}

command_add() {
    OPTDEF=()
    parseoption "$(
        cat <<EOF
Usage: $0 add [files]...
Add ssh key file into ssh-agent. Starts a new ssh-agent if
there are no agents has been started.
EOF
    )" "$@" || exit 1
    local key
    if [ ${#OPTARGS[@]} -eq 0 ]; then
        key=$(get_local_sshkey)
        if [ -n "$key" ]; then
            OPTARGS=("$key")
        fi
    fi
    if [ "${SSH_AGENT_PID:-0}" -ne 0 ]; then
        ssh-add "${OPTARGS[@]}"
    else
        ssh-agent bash --init-file <(
            cat <<EOF
. ~/.bashrc
ssh-add ${OPTARGS[@]}
EOF
        )
    fi
}

command_copyid() {
    OPTDEF=(
        -i "" FILE sshkey "sshkey(identity_file)"
    )
    local sshkey
    parseoption "$(
        cat <<EOF
Usage: $0 copyid [-i sshkey] [user@]host
copy sshkey(identity_file) from local to remote for login
authtication without password.

EOF
    )" "$@" || exit 1

    if [ -n "$sshkey" ]; then
        ssh-copy-id -i "$sshkey" "${OPTARGS[@]}"
    else
        sshkey=$(get_local_sshkey)
        if [ -z "$key" ]; then
            echo >&2 "cannot find sshkey"
            return 1
        fi
        ssh-copy-id "$sshkey" "${OPTARGS[@]}"
    fi
}

command_test() {
    OPTDEF=(
        -i "" FILE sshkey "sshkey(identity_file)"
        -o "" OPT sshopts "ssh options, cound set many times"
    )
    local sshkey
    local sshopts=()
    parseoption "$(
        cat <<EOF
Usage: $0 test [-i sshkey] [user@]host
Test connection through SSH.

EOF
    )" "$@" || exit 1
    local tmp exitcode
    local opts=()
    exitcode=0
    if [ -n "$sshkey" ]; then
        opts+=(-i "$sshkey")
    fi
    for tmp in "${sshopts[@]}"; do
        opts+=(-o "$tmp")
    done
    for tmp in "${OPTARGS[@]}"; do
        if ! ssh -q "${opts[@]}" "$tmp" exit; then
            echo >&2 "connection to $tmp fail"
            exitcode=1
        else
            echo "connection to $tmp success"
        fi
    done
    return $exitcode
}

command_new() {
    OPTDEF=(
        -C "" comment comment "set ssh key comment"
    )
    local comment
    local sshopts=()
    parseoption "$(
        cat <<EOF
Usage: $0 new [-C comment] [filename]
Test connection through SSH.

EOF
    )" "$@" || exit 1

    local destination
    if [ -z "${OPTARGS[0]}" ]; then
        destination=~/.ssh/id_ed25519
    else
        destination="${OPTARGS[0]}"
    fi
    if [ -e "$destination" ]; then
        echo >&2 "$destination exits"
        return 1
    fi
    if [ -z "$comment" ]; then
        comment="$(whoami)@$(uname -n)-$(date -I)"
    fi
    ssh-keygen -t ed25519 -C "$comment" -f "${destination}"
}

usage() {
    cat <<EOF
Usage: ${0##*/} command [command options]...
A useful tools for SSH key control.

Commands:
    add       addd sshkey into ssh-agent
    copyid    push sshkey on remote machine for connections remote without password
    test      test connection through ssh

Use "$0 <command> --help" for more information about a given command.
EOF
}

command="$1"
shift
case "$command" in
-h | --help)
    usage
    exit 1
    ;;
add | copyid | test | new)
    "command_$command" "$@"
    ;;
*)
    echo >&2 "unknow command: $command"
    exit 1
    ;;
esac
