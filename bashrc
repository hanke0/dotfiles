# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

[[ -f /etc/bashrc ]] && . /etc/bashrc

export PATH=$HOME/.bin:$HOME/.local/bin:$PATH

# history about
shopt -s histappend
export HISTIGNORE="?"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
shopt -s checkwinsize
shopt -s cdspell
export EDITOR='vim'
export TERM=xterm-256color
#export TERM=screen-256color
export GPG_TTY=$(tty)
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" >/dev/null 2>&1
done
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

COLOR_RESET=$(echo -en '\001\033[0m\002')
COLOR_WHITE=$(echo -en '\001\033[01;37m\002')
COLOR_RED=$(echo -en '\001\033[00;31m\002')
COLOR_GREEN=$(echo -en '\001\033[00;32m\002')
COLOR_YELLOW=$(echo -en '\001\033[00;33m\002')
COLOR_BLUE=$(echo -en '\001\033[00;34m\002')
COLOR_MAGENTA=$(echo -en '\001\033[00;35m\002')
COLOR_PURPLE=$(echo -en '\001\033[00;35m\002')
COLOR_CYAN=$(echo -en '\001\033[00;36m\002')
COLOR_LIGHTGRAY=$(echo -en '\001\033[00;37m\002')
COLOR_LIGHTRED=$(echo -en '\001\033[01;31m\002')
COLOR_LIGHTGREEN=$(echo -en '\001\033[01;32m\002')
COLOR_LIGHTYELLOW=$(echo -en '\001\033[01;33m\002')
COLOR_LIGHTBLUE=$(echo -en '\001\033[01;34m\002')
COLOR_LIGHTMAGENTA=$(echo -en '\001\033[01;35m\002')
COLOR_LIGHTPURPLE=$(echo -en '\001\033[01;35m\002')
COLOR_LIGHTCYAN=$(echo -en '\001\033[01;36m\002')

#prompt
__git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [[ $(id -u) -eq 0 ]]; then
  PS1="[${COLOR_RED}\u${COLOR_RESET}"
else
  PS1="[${COLOR_GREEN}\u${COLOR_RESET}"
fi
PS1+="@${COLOR_CYAN}\h${COLOR_RESET}:${COLOR_YELLOW}\w${COLOR_RESET}]${COLOR_BLUE}"
PS1+="\$(__git_branch)\n${COLOR_PURPLE}» ${COLOR_RESET}"

[[ -f /etc/bash_completion ]] && . /etc/bash_completion
[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
[[ -f /usr/local/etc/bash_completion ]] && . /usr/local/etc/bash_completion
[[ -f /usr/local/etc/profile.d/z.sh ]] && . /usr/local/etc/profile.d/z.sh
