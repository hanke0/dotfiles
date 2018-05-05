export TERM=xterm-256color

# check the window size after each command and, if necessary,
shopt -s checkwinsize

shopt -s autocd

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
