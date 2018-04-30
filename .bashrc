trans='\[\e[m\]'
dark='\[\e[0;30m\]'
red='\[\e[0;31m\]'
green='\[\e[0;32m\]'
yellow='\[\e[0;33m\]'
blue='\[\e[0;34m\]'
purple='\[\e[0;35m\]'
greenblue='\[\e[0;36m\]'
white='\[\e[0;37m\]'

PS1="[$green\u$greenblue@$green\h$trans:$blue\w$trans]$red\$$trans "

shopt -s autocd

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

export TERM=xterm-256color        # for common 256 color terminals (e.g. gnome-terminal)

[ -f /usr/local/share/bash-completion/bash_completion ] && . /usr/local/share/bash-completion/bash_completion

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

[ -f ~/.bash_alias ] && . ~/.bash_alias

