# bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion >/dev/null 2>&1
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion >/dev/null 2>&1
elif [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion >/dev/null 2>&1
elif [ -f "$HOME/.bash_completion" ]; then
    . ~/.bash_completion >/dev/null 2>&1
fi

download-z() {
    curl -fsSLo ~/".z.sh" https://raw.githubusercontent.com/rupa/z/master/z.sh
}

[ -f ~/.z.sh ] && source ~/.z.sh >/dev/null 2>&1

[ -f ~/.fzf.bash ] && source ~/.fzf.bash >/dev/null 2>&1

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh >/dev/null 2>&1
