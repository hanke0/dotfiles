#!/usr/bin/env bash

set -e
set -o pipefail

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
$1=(cat <<'__EOF__'
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

PARTS_COMMENT="!! Contents within this block are managed by https://github.com/hanke0/dotfiles !!"
PARTS_ID=hanke0/dotfiles
PARTS_SUFFIX=.bak
PARTS_DRYRUN=
PARTS_YES=

adparts_read_yes() {
    case "$PARTS_YES" in
    1 | true)
        return 0
        ;;
    esac
    local answer
    answer=
    read -r -p "$@" answer
    case "$answer" in
    y* | Y* | '')
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

addparts_awk_comment() {
    case "$1" in
    '"')
        echo '\"'
        ;;
    *)
        echo "$1"
        ;;
    esac
}

addparts_backupfile() {
    if [ -z "$PARTS_SUFFIX" ]; then
        return 0
    fi
    if [ -f "$1" ]; then
        cp -f "$1" "$1$PARTS_SUFFIX"
    fi
}

addparts_check() {
    local file awkleading awktrailing
    file="$1"
    awkleading="$2"
    awktrailing="$3"
    if ! [ -e "$file" ]; then
        printf "OK"
        return 0
    fi

    awk "(\$0 == \"$awkleading\"){ start=1 }
(\$0 == \"$awktrailing\") { if (start) start=0; else print \"RAW FINISH\"; }
END { if (!start) { print \"OK\" } }
" "$file"
}

addparts_append() {
    local dest src awkleading awktrailing
    dest="$1"
    src="$2"
    awkleading="$3"
    awktrailing="$4"
    if ! [ -e "$file" ]; then
        cat "$src"
        return 0
    fi

    awk "(\$0 == \"$awkleading\"){ start=1 }
(\$0 == \"$awktrailing\") { end=1 }
(!start && !end){print}
(start && end) { added=1; while ((getline<\"$src\") > 0) {print} }
(end){ start=0;end=0 }
END { if (!added) { while ((getline<\"$src\") > 0) {print} } }
" "$dest"
}

addparts() {
    local file commentsign content
    local textfile note leading trailing awkcommentsign awkleading awktrailing
    file="$1"
    commentsign="$2"
    content="$3"

    awkcommentsign=$(addparts_awk_comment "$commentsign")
    leading=">>> $PARTS_ID >>>"
    trailing="<<< $PARTS_ID <<<"
    awkleading="$awkcommentsign $leading"
    awktrailing="$awkcommentsign $trailing"

    if [ "$(addparts_check "$file" "$awkleading" "$awktrailing")" != "OK" ]; then
        echo >&2 "file has a bad block of contents, please check it: $file"
        return 1
    fi
    textfile=$(mktemp --tmpdir= hanke0.dotfiles.XXXXXXXX.tmp)
    if [ -z "$textfile" ]; then
        echo >&2 "cannot make temporery file"
        return 1
    fi
    cat >"$textfile" <<EOF
$commentsign $leading
$commentsign $PARTS_COMMENT
$content
$commentsign $trailing
EOF
    text=$(addparts_append "$file" "$textfile" "$awkleading" "$awktrailing")
    rm -f "$textfile"
    note=""
    if ! [ -e "$file" ]; then
        note="create file $file"
        echo "!!! $note with following content(diff output)"
        diff <(cat <<<"$text") <(cat <<<"") || true
    else
        if diff <(cat <<<"$text") "$file" >/dev/null 2>&1; then
            return 0
        fi
        note="change file $file"
        echo "!!! $note with following content(diff output)"
        diff <(cat <<<"$text") "$file" || true
    fi
    case "$PARTS_DRYRUN" in
    1 | true)
        return 0
        ;;
    esac
    if adparts_read_yes "!!! $note [Y/n]?"; then
        addparts_backupfile "$file"
        cat >"$file" <<<"$text"
    fi
}
# <<< hanke0/dotfiles <<<

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
    command_uagent
    ssh-add "${OPTARGS[@]}"
}

command_copyid() {
    OPTDEF=(
        -i "" FILE sshkey "sshkey(identity_file)"
    )
    local sshkey
    parseoption "$(
        cat <<EOF
Usage: $0 copyid [-i sshkey] [user@]host...
copy sshkey(identity_file) from local to remote for login
authtication without password.

EOF
    )" "$@" || exit 1
    local host
    if [ -z "$sshkey" ]; then
        sshkey=$(get_local_sshkey)
        if [ -z "$sshkey" ]; then
            echo >&2 "cannot find sshkey"
            return 1
        fi
    fi
    for host in "${OPTARGS[@]}"; do
        if ! ssh-copy-id -i "$sshkey" "$host"; then
            echo >&2 "fail to push $host"
            return 1
        fi
    done
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

command_uagent() {
    OPTDEF=()
    parseoption "$(
        cat <<EOF
Usage: $0 useragent
Start a user agent. set environment into ~/.ssh/agent.env.

EOF
    )" || exit 1
    local env agent_run_state
    env=~/.ssh/agent.env
    # shellcheck disable=SC1090
    test -f "$env" && . "$env" >/dev/null

    # agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
    agent_run_state=$(
        ssh-add -l >/dev/null 2>&1
        echo $?
    )

    if [ ! "$SSH_AUTH_SOCK" ] || [ "$agent_run_state" = 2 ]; then
        (
            umask 077
            ssh-agent -s >"$env"
        )
        # shellcheck disable=SC1090
        . "$env" >/dev/null
    fi
}

command_new() {
    OPTDEF=(
        -C "" comment comment "set ssh key comment"
        -t "" type keytype "spect the type of key to create. The possiblae values are \"ed25519\"(default) or \"rsa\""
    )
    local comment keytype
    local sshopts=()
    parseoption "$(
        cat <<EOF
Usage: $0 new [-C comment] [filename]
Create new sshkey.

EOF
    )" "$@" || exit 1

    local destination defdest
    case "$keytype" in
    ed25519 | "")
        keytype=ed25519
        defdest=~/.ssh/id_ed25519
        ;;
    rsa)
        keytype="rsa-sha2-512"
        defdest=~/.ssh/id_rsa
        ;;
    *)
        echo >&2 "unknown key type"
        return 1
        ;;
    esac
    if [ -z "${OPTARGS[0]}" ]; then
        destination="$defdest"
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
    ssh-keygen -t "$keytype" -C "$comment" -f "${destination}"
}

command_password() {
    OPTDEF=()
    local sshopts=()
    parseoption "$(
        cat <<EOF
Usage: $0 password filename
Changing the private key's passphrase without changing the key

EOF
    )" "$@" || exit 1
    local file
    for file in "${OPTARGS[@]}"; do
        ssh-keygen -f "file" -p
    done
}

usage() {
    cat <<EOF
Usage: ${0##*/} command [command options]...
A useful tools for SSH key control.

Commands:
    add       addd sshkey into ssh-agent
    copyid    push sshkey on remote machine for connections remote without password
    test      test connection through ssh
    new       create new sshkey
    password  change the private key's passphrase without changing the key
    uagent    start a user agent if no ssh-agent has been started

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
uagent)
    command_uagent "$@"
    ;;
add | copyid | test | new | password)
    uagent
    "command_$command" "$@"
    ;;
*)
    echo >&2 "unknow command: $command"
    exit 1
    ;;
esac
