# input  : [ $(read_yes ) ] && echo yes;
# output : yes
# $1 is message when read input print
function _read_yes() {
    local input yes="0" x=($@)
    for i in "${x[@]}"; do
        if [ "$i" = "-y" ]; then
            return 0
        fi
    done
    read -r -p "$1[yes/No] " input
    case $input in
    [yY][eE][sS] | [yY])
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

function extract() {
    local e=0 i c
    for i in $*; do
        if [ -f $i -a -r $i ]; then
            c=
            case $i in
            *.tar.bz2) c='tar xjf' ;;
            *.tar.gz) c='tar xzf' ;;
            *.bz2) c='bunzip2' ;;
            *.gz) c='gunzip' ;;
            *.tar) c='tar xf' ;;
            *.tbz2) c='tar xjf' ;;
            *.tgz) c='tar xzf' ;;
            *.7z) c='7z x' ;;
            *.Z) c='uncompress' ;;
            *.exe) c='cabextract' ;;
            *.rar) c='unrar x' ;;
            *.xz) c='unxz' ;;
            *.zip) c='unzip' ;;
            *)
                echo "$0: cannot extract \`$i': Unrecognized file extension" >&2
                e=1
                ;;
            esac
            [[ -n $c ]] && command $c "$i"
        else
            echo "$0: cannot extract \`$i': File is unreadable" >&2
            e=2
        fi
    done
    return $e
}

TRASH_DIR="$HOME/.trash"

# replace `rm`,  put files to trash instead of a real delete action
function trash() {
    if [ ! -d "$TRASH_DIR" ]; then
        mkdir -p "$TRASH_DIR"
    fi
    local i
    for i in $*; do
        if [[ ! $i =~ ^- ]]; then
            local filename=$(realpath $i)
            if [ -a "$filename" ]; then
                local DT=$(date +%Y-%m-%d)
                local p=$(dirname "$TRASH_DIR"/"$DT"/"$filename")
                if [ ! -d "$p" ]; then
                    mkdir -p "$p"
                fi
                mv -f "$filename" "$TRASH_DIR/$DT$filename"
            fi
        fi
    done
}

export PYTHON_ENV_HOME="$HOME/.virtualenvs/"

[ ! -d ${PYTHON_ENV_HOME} ] && mkdir ${PYTHON_ENV_HOME}

function mkenv() {
    local args=($@)
    [ ! -a $PYTHON_ENV_HOME ] && mkdir -p $PYTHON_ENV_HOME
    virtualenv "$PYTHON_ENV_HOME$1" ${args[@]:1}
    return $?
}

function rmenv() {
    _read_yes "Do you want to remove $1?" $*
    [ $? -eq 0 ] && rm -rf "$PYTHON_ENV_HOME$1" && return 0
    return 1
}

function workon() {
    local venv=$1
    if [ -z $venv ]; then
        echo "Chose one env:"
        ls $PYTHON_ENV_HOME
        return 0
    fi
    source "$PYTHON_ENV_HOME$1/bin/activate"
}

complete -W "$(ls $PYTHON_ENV_HOME)" rmenv
complete -W "$(ls $PYTHON_ENV_HOME)" workon

function aenv() {
    local d=$1
    if [ -z $d ]; then
        d="."
    fi

    if [ -d "$d/.env" ]; then
        source "$d/.env/bin/activate"
    elif [ -d "$d/venv" ]; then
        source "$d/venv/bin/activate"
    elif [ -d "$d/.venv" ]; then
        source "$d/.venv/bin/activate"
    else
        echo "don't have env"
    fi
}

function history-stat() {
    if [ "$1" == "-h" ]; then
        echo "stat history shell command, accept a number like head -n"
        return 1
    fi
    if [ -n $1 ]; then
        local __history_limit=$1
    else
        local __history_limit=10
    fi
    history |
        awk '{CMD[$2]++;count++;} END { for (a in CMD )print CMD[ a ]" " CMD[ a ]/count*100 "% " a }' |
        grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n$__history_limit
}

function pidofport() {
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "get pid of process listen on given port"
        return 1
    else
        local __port_pid=$(ss -tnlp | grep ":$1" | tr ',' "\n" | grep "pid" | awk -F '=' '{print $2}')
        echo $__port_pid
    fi
}

function cmdofpid() {
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "get process command of given pid"
        return 1
    else
        ps -F -p 67992 | grep -v CMD | awk '{for(i=11;i<=NF;i++) printf"%s ",$i};NF>11 {print ""}'
    fi
}

function topof() {
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "top filter by command names"
    else
        top -c -p $(pgrep -d',' -f $1) -o PID
    fi
}

function memofpid() {
    if [ $# != 2 ]; then
        echo "Usage(kb): memofpid [share|private|rss|pss|size] [pid]"
        return 1
    fi

    [[ ! -e /proc/$2 ]] && echo "pid $2 not exist" && return 1

    case $1 in
    s | share)
        grep ^Share /proc/$2/smaps | awk '{sum += $2} END {print sum}'
        ;;
    p | private)
        grep ^Private /proc/$2/smaps | awk '{sum += $2} END {print sum}'
        ;;
    r | rss | Rss)
        grep ^Rss /proc/$2/smaps | awk '{sum += $2} END {print sum}'
        ;;
    pss | Pss)
        grep ^Pss /proc/$2/smaps | awk '{sum += $2} END {print sum}'
        ;;
    size)
        grep ^Size /proc/$2/smaps | awk '{sum += $2} END {print sum}'
        ;;
    *)
        echo "Usage(kb): memofpid [share|private|rss|pss|size] [pid]"
        return 1
        ;;
    esac
}

function kill-jobs() {
    jobs -l | awk '{print $2}' | xargs kill
}

function __kill_benchmark() {
    [[ -e "./__pid_file_temp" ]] && cat "./__pid_file_temp" | xargs kill >/dev/null 2>&1
    rm -f "./__pid_file_temp"
    set -m
}

function benchmark() {
    set +m
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "Usage: benchmark [-n10] command..."
        return 1
    else
        local currency=10
        local cmd i
        if [ "${1:0:2}" == "-n" ]; then
            currency=${1#*n}
            cmd=${@:2}
        else
            cmd=$*
        fi
        [[ -e "./__pid_file_temp" ]] && rm "./__pid_file_temp"
        echo "COMMAND: $cmd"
        echo "START $currency jobs"
        echo
        trap __kill_benchmark SIGINT
        trap __kill_benchmark SIGTERM

        for ((i = 1; i < ($currency + 1); i++)); do
            {
                local __cost=$(/usr/bin/time -p $cmd 2>&1 | grep real | awk '{print $2}')
                echo "$(printf "%03d" $i) finish cost $__cost"
                echo $! >__pid_file_temp
            } &
            echo "$(printf "%03d" $i) start"
        done
        wait

        __kill_benchmark
        echo
        echo FINISH!
    fi
}

function pip-remove() {
    local x=($@)
    if [ "$1" == "-h" ]; then
        echo "Usage: pip-remove [package] ..."
        echo "This will fully remove package and it's requires if no other package requires."
        return 1
    else
        local s=$(pip list --format=freeze --disable-pip-version-check | grep -i $1)
        if [ -z "$s" ]; then
            echo "can't find package $1"
            return 1
        fi
        # other package requires
        local Array2=($(pip list --format=freeze --disable-pip-version-check | grep -i -v $1 |
            awk -F '==' '{print $1}' | xargs pip show --disable-pip-version-check | grep ^Requires: |
            awk -F ":" '{print $2}' | tr ',' '\n' | grep -v '^[[:blank:]]$' | uniq))
        # package requires
        local Array1=($(echo $s | awk -F '==' '{print $1}' | xargs pip show --disable-pip-version-check | grep ^Requires: |
            awk -F ":" '{print $2}' | tr ',' '\n' | grep -v '^[[:blank:]]$' | uniq))

        # find package requires - other package requires
        local Array3=() i skip
        for i in "${Array1[@]}"; do
            skip=
            for j in "${Array2[@]}"; do
                [[ $i == $j ]] && {
                    skip=1
                    break
                }
            done
            [[ -n $skip ]] || Array3+=("$i")
        done
        _read_yes "Do you want delete $1?" ${x[@]}
        [ $? -eq 0 ] && pip uninstall -y $*
        if [ -n "${Array3[*]}" ]; then
            for i in "${Array3[@]}"; do
                pip-remove $i ${x[@]:1}
            done
        fi
    fi
    return 0
}

function tmux-kill() {
    if [[ $# -eq 0 ]]; then
        tmux ls | grep : | cut -d: -f1 | xargs -I{} tmux kill-session -t {}
    else
        local i
        for i in $@; do
            tmux kill-session -t $i
        done
    fi
}

function tmux-default() {
    if [[ -z $(tmux ls | cut -d: -f1 | grep default) ]]; then
        tmux -2 new -n default -s default
    else
        tmux at -t default
    fi
}

alias t=tmux-default

function my-rsync() {
    rsync -azchP \
    --exclude '/**/.tox' --exclude "/**/.git" --exclude "/**/.idea" \
    --exclude "*.pyc" --exclude "*.pyd" --exclude "/**/__pycache__" \
    --exclude "/**/*.egg-info" --exclude "/**/build" --exclude "/**/dist" \
    --exclude "/**/.pytest_cache" --exclude "/**/.env" \
    --exclude "/**/.vscode" --exclude ".DS_Store" --exclude "Thumbs.db" \
    --exclude "*esktop.ini" --exclude "/**/*.code-workspace" \
    --exclude "/**/sdist" \
    $*
}