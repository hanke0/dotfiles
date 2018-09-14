# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export TERM=xterm-256color

if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# check the window size after each command and, if necessary,
shopt -s checkwinsize

# history
HISTSIZE=9999
HISTFILESIZE=9999
HISTCONTROL=ignoreboth
HISTIGNORE="pwd:ls:ll:la:ipy:python:"
shopt -s histappend;

shopt -s cdspell;

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null;
done;

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

