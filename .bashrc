#!/bin/bash

command -v realpath >/dev/null 2>&1 || realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

path_append() {
    case ":${PATH}:" in
    *:"$1":*) ;;
    *)
        export PATH="$PATH:$1"
        ;;
    esac
}

path_push() {
    case ":${PATH}:" in
    *:"$1":*) ;;
    *)
        export PATH="$1:$PATH"
        ;;
    esac
}

ROOT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
if [ -n "$ROOT_DIR" ] && [ -d "$ROOT_DIR/bin" ]; then
    path_append "$ROOT_DIR/bin"
    # relative path is not really a problem here.
    # shellcheck disable=SC1091
    [ -f "$ROOT_DIR/bin/_bash-complete.sh" ] && . "$ROOT_DIR/bin/_bash-complete.sh"
fi

# history about
export HISTIGNORE="?"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth:erasedups
export PROMPT_COMMAND='history -a'
if [ -n "${BASH_VERSION-}" ]; then
    shopt -s histappend
    # check the window size after each command and, if necessary,
    shopt -s checkwinsize
    # * Recursive globbing, e.g. `echo **/*.txt`
    shopt -s "globstar" >/dev/null 2>&1
fi

export EDITOR='vim'

export COLOR_RESET="\e[0m"

export COLOR_BLACK="\e[0;30m"
export COLOR_RED="\e[0;31m"
export COLOR_GREEN="\e[0;32m"
export COLOR_YELLOW="\e[0;33m"
export COLOR_BLUE="\e[0;34m"
export COLOR_MAGENTA="\e[0;35m"
export COLOR_CYAN="\e[0;36m"
export COLOR_LIGHTGRAY="\e[0;37m"

export COLOR_BLACK_BOLD="\e[1;30m"
export COLOR_RED_BOLD="\e[1;31m"
export COLOR_GREEN_BOLD="\e[1;32m"
export COLOR_YELLOW_BOLD="\e[1;33m"
export COLOR_BLUE_BOLD="\e[1;34m"
export COLOR_MAGENTA_BOLD="\e[1;35m"
export COLOR_CYAN_BOLD="\e[1;36m"
export COLOR_LIGHTGRAY_BOLD="\e[1;37m"

# -- Prompt -------------------------------------------------------------------
if ! commanv -v "__git_ps1" >/dev/null 2>&1; then
    __git_ps1() {
        local branchname
        branchname="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
        if [ -n "$branchname" ]; then
            printf "$1" "$branchname"
        fi
    }
fi

if [ "$(id -u)" = "0" ]; then
    __ps1_user="\[${COLOR_RED_BOLD}\]\u\]${COLOR_RESET}\]"
else
    __ps1_user="\[${COLOR_GREEN}\]\u\[${COLOR_RESET}\]"
fi
if [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
    __ps1_host="\[${COLOR_RED_BOLD}\]\h\[${COLOR_RESET}\]"
else
    __ps1_host="\[${COLOR_CYAN}\]\h\[${COLOR_RESET}\]"
fi
__ps1_dir="\[${COLOR_YELLOW}\]\w\[${COLOR_RESET}\]"
__ps1_git="\[${COLOR_BLUE}\]\$(command -v __git_ps1 2>&1 >/dev/null && __git_ps1 '(%s)')\[${COLOR_RESET}\]"
__ps1_proxy="\$(if [ -n \"\$http_proxy\" ] || [ -n \"\$https_proxy\" ]; then printf \" ✈\"; fi;)"
__ps1_suffix="\n\[${COLOR_MAGENTA_BOLD}\]» \[${COLOR_RESET}\]"
export PS1="[${__ps1_user}@${__ps1_host}:${__ps1_dir}]${__ps1_git}${__ps1_proxy}${__ps1_suffix}"

# -- Functions --------------------------------------------------------------

tmux_open() {
    if tmux 'ls' 2>/dev/null | grep -- "$(whoami)"; then
        tmux attach-session -t "$(whoami)"
    else
        tmux -2 -u new-session -s "$(whoami)"
    fi
}

tmux_clean() {
    if tmux 'ls' 1>/dev/null 2>&1; then
        tmux 'ls' 2>/dev/null | grep : | cut -d: -f1 | xargs tmux kill-session -t
    fi
}

ts2date() {
    date -d @"$1" +%Y-%m-%dT%H:%M:%S%z 2>/dev/null || date -r "$1" +%Y-%m-%dT%H:%M:%S%z
}

int2hex() {
    printf "%x\n" "$1"
}

hex2int() {
    printf "%d\n" 0x"$1"
}

char2hex() {
    printf "%s" "$1" | od -t x1
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
o() {
    if [ $# -eq 0 ]; then
        open .
    else
        open "$@"
    fi
}
# Normalize `open` across Linux, macOS, and Windows.
# This is needed to make the `o` function (see below) cross-platform.
if [ ! "$(uname -s)" = 'Darwin' ]; then
    if grep --quiet --ignore-case microsoft /proc/version; then
        # Ubuntu on Windows using the Linux subsystem
        alias open='explorer.exe'
    else
        alias open='xdg-open'
    fi
fi

# `treeview` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
# Orginal written by mathiasbynens in project dotfiles(https://github.com/mathiasbynens/dotfiles).
treeview() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Run `dig` and display the most useful info
# Orginal written by mathiasbynens in project dotfiles(https://github.com/mathiasbynens/dotfiles).
function digsimple() {
    dig +nocmd "$1" any +multiline +noall +answer
}

set_shortcuts() {
    bind '"\e[A": history-search-backward' # UP
    bind '"\e[B": history-search-forward'  # DOWN
}

condaon() {
    conda deactivate && conda activate "$@" && type python && pip -V
}

areyouok() {
    echo "The previous command exit with code $?"
}

enable_proxy() {
    local proxy
    proxy="$1"
    if [ -z "$1" ]; then
        echo >&2 "proxy not provided"
        return 1
    fi
    # https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy/
    no_proxy="localhost,127.0.0.1,::1"
    http_proxy="$proxy"
    https_proxy="$proxy"
    export http_proxy https_proxy no_proxy
}

disable_proxy() {
    unset http_proxy https_proxy no_proxy
}

update_z() {
    rm -f ~/.z.sh/z.sh
    mkdir -p ~/.z.sh
    curl -sSL -o ~/.z.sh/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
    curl -sSL -o /usr/local/share/man/man1/z.1 https://raw.githubusercontent.com/rupa/z/master/z.1
}

# ~ is allowed here.
# shellcheck disable=SC1090
[ -f ~/.z.sh/z.sh ] && . ~/.z.sh/z.sh
if ! command -v 'z' >/dev/null 2>&1; then
    # z not exists
    _download_z() {
        echo "downloading z..."
        update_z
        # this will change z alias to real z
        # shellcheck disable=SC1090
        . ~/.z.sh/z.sh
        echo "active z success!"
    }
    alias z='_download_z'
fi

is_macOS() {
    [ "$(uname)" = "Darwin" ]
}

if is_macOS; then
    _active_brew_bash_completion() {
        local file
        for file in /opt/homebrew/etc/bash_completion.d/*; do
            # shellcheck source=/dev/null
            . "$file" >/dev/null 2>&1
        done
    }
    _active_brew_bash_completion
    unset _active_brew_bash_completion
    # shellcheck source=/dev/null
    [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

# -- Alias --------------------------------------------------------------------
if is_macOS; then
    alias ls='ls -G'
    if command -v gsed >/dev/null 2>&1; then
        alias sed="gsed"
    fi
else
    alias ls='ls --color=auto'
fi
alias ll='ls -Alhb'
alias la='ls -ACF'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias cls='clear'
alias tt='tmux_open'
