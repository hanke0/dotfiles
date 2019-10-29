# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

[[ -f /etc/bashrc ]] && . /etc/bashrc

export PATH=$HOME/.bin:$HOME/.local/bin:$PATH

# history about
export HISTIGNORE="?"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth

shopt -s histappend
# check the window size after each command and, if necessary,
shopt -s checkwinsize
# * Recursive globbing, e.g. `echo **/*.txt`
shopt -s "globstar" >/dev/null 2>&1

export EDITOR='vim'
export TERM=xterm-256color
#export TERM=screen-256color
export GPG_TTY=$(tty)

COLOR_RESET='\e[0m'
COLOR_RED='\e[31m'
COLOR_GREEN='\e[32m'
COLOR_YELLOW='\e[33m'
COLOR_BLUE='\e[34m'
COLOR_PURPLE='\e[35m'
COLOR_CYAN='\e[36m'
COLOR_LIGHTGRAY='\e[37m'

#prompt
__git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [[ $(id -u) -eq 0 ]]; then
    PS1='[\[\e[31m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\]:\[\e[33m\]\w\[\e[m\]]\[\e[34m\]$(__git_branch)\[\e[m\]\n\[\e[35m\]» \[\e[m\]'
else
    PS1='[\[\e[32m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\]:\[\e[33m\]\w\[\e[m\]]\[\e[34m\]$(__git_branch)\[\e[m\]\n\[\e[35m\]» \[\e[m\]'
fi

[[ -f /etc/bash_completion ]] && . /etc/bash_completion
[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
[[ -f /usr/local/etc/bash_completion ]] && . /usr/local/etc/bash_completion
[[ -f /usr/local/etc/profile.d/z.sh ]] && . /usr/local/etc/profile.d/z.sh
# shellcheck disable=SC1090
[[ -n "$HOME" && -f "$HOME/.alias" ]] && . "$HOME/.alias"
