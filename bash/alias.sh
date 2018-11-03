alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias grep='grep --color'
alias egrep='egrep --color'

ls --color=auto >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi

alias la='ls -A'
alias ll='ls -lihF'
alias lla='ls -lihFA'
alias cls='clear'
alias vi='vim'
alias clsh='history -c'
alias du1='du -h --max-depth=1'

alias sv='brew services'
alias cask='brew cask'

alias ipy='ipython'

if type ccat >/dev/null 2>&1; then
    alias cat='ccat'
fi

if type icdiff >/dev/null 2>&1; then
    alias diff='icdiff'
fi

if which pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    alias py34="pyenv shell 3.4.8; echo use python 3.4.8"
    alias py35="pyenv shell 3.5.5; echo use python 3.5.5"
    alias py="pyenv shell 3.6.6; echo use python 3.6.6"
    alias py2="pyenv shell 2.7.15; echo use python 2.7.15"
fi

if which pyenv-virtualenv-init >/dev/null 2>&1; then eval "$(pyenv virtualenv-init -)"; fi
