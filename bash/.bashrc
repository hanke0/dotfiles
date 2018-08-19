export TERM=xterm-256color

if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# check the window size after each command and, if necessary,
shopt -s checkwinsize

# history
HISTSIZE=3000
HISTFILESIZE=3000
HISTCONTROL=erasedups
HISTIGNORE=”pwd:ls:ll:la:ipy:python:ipython”
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
