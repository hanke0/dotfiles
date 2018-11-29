# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

if [ -f /etc/bashrc ]; then
    . /etc/bashrc >/dev/null 2>&1
fi

# check the window size after each command and, if necessary,

export PATH=$HOME/.bin:$HOME/.local/bin:$PATH

# history about
shopt -s histappend
export HISTIGNORE="?"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth

shopt -s checkwinsize
shopt -s cdspell
export EDITOR='vim'
export TERM=xterm-256color
export GPG_TTY=$(tty)
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" >/dev/null 2>&1
done
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#prompt
__git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [[ $(id -u) -eq 0 ]]; then
    PS1='[\[\e[31m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\]:\[\e[33m\]\w\[\e[m\]]\[\e[34m\]$(__git_branch)\[\e[m\]\n\[\e[35m\]» \[\e[m\]'
else
    PS1='[\[\e[32m\]\u\[\e[m\]@\[\e[36m\]\h\[\e[m\]:\[\e[33m\]\w\[\e[m\]]\[\e[34m\]$(__git_branch)\[\e[m\]\n\[\e[35m\]» \[\e[m\]'
fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion >/dev/null 2>&1
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion >/dev/null 2>&1
elif [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion >/dev/null 2>&1
fi
[ -f ~/.z.sh ] && source ~/.z.sh >/dev/null 2>&1
[ -f ~/.alias ] && . ~/.alias
