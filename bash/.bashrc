
trans='\[\e[m\]'
dark='\[\e[0;30m\]'
red='\[\e[0;31m\]'
green='\[\e[0;32m\]'
yellow='\[\e[0;33m\]'
blue='\[\e[0;34m\]'
purple='\[\e[0;35m\]'
greenblue='\[\e[0;36m\]'
white='\[\e[0;37m\]'
gp='`B=$(git branch 2>/dev/null | sed -e "/^ /d" -e "s/* \(.*\)/\1/"); [[ "$B" != "" ]]\
    && echo -n -e "($B)"`'

PS1="[$green\u$greenblue@$green\h$trans:$blue\w$trans]$dark$gp$red\$$trans "

shopt -s autocd

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

export TERM=xterm-256color        # for common 256 color terminals (e.g. gnome-terminal)

[ -f /usr/local/share/bash-completion/bash_completion ] && . /usr/local/share/bash-completion/bash_completion

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

[ -f ~/.git-completion ] && . ~/.git-completion

[ -f ~/.bash_alias ] && . ~/.bash_alias

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
