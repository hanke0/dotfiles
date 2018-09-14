if [ -d "$HOME/.pyenv/bin" ]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
fi

export EDITOR='vim';

export TERM=xterm-256color

# history
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth
# Ignores all one-word and two-word commands for more efficient
# bash history searching
export HISTIGNORE="?:??"

export GPG_TTY=$(tty)