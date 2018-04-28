export PATH=/usr/local/miniconda3/bin:$PATH
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

if [ -f /usr/local/share/bash-completion/bash_completion ]; then
    . /usr/local/share/bash-completion/bash_completion
fi

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

alias grep='grep --color'
alias egrep='egrep --color'
alias ls='ls -G'
alias la='ls -a -l'
alias ll='ls -l'
alias cls='clear'
alias sv='brew service'
alias cask='brew cask'
alias cat='ccat'
alias env='conda env'
