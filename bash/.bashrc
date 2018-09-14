# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

if [ -f /etc/bashrc ]; then
    . /etc/bashrc >/dev/null 2>&1
fi

# check the window size after each command and, if necessary,
shopt -s checkwinsize

shopt -s histappend

shopt -s cdspell

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" >/dev/null 2>&1
done;

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
