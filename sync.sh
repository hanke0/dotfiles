#!/usr/bin/env bash
set -e

ABS_PATH="$(realpath "$0")"
ROOT_DIR="$(dirname "$ABS_PATH")"

_has_content() {
    if [[ ! -f $2 ]]; then
        return 1
    fi
    grep "$1" "$2" 2>&1 >/dev/null
}

_put_content() {
    if _has_content "$1" "$2"; then
        return 0
    fi
    echo "modified $2"
    echo "$1" >>"$2"
}

# bashrc config
_put_content "export PAHT=\"\$PATH:$ROOT_DIR/bin\" # modified by han" ~/.bashrc
_put_content "[[ -f '$ROOT_DIR/.bashrc' ]] && . '$ROOT_DIR/.bashrc'  # modified by han" ~/.bashrc

# git config
git config --global include.path "$ROOT_DIR/.gitconfig"

# tmux config
_put_content "source-file $ROOT_DIR/.tmux.conf  # modified by han" ~/.tmux.conf

# vim config
_put_content "source $ROOT_DIR/.vimrc \" modified by han" ~/.vimrc

# zsh config
_put_content "[[ -f '$ROOT_DIR/.zshrc' ]] && . '$ROOT_DIR/.zshrc'  # modified by han" ~/.zshrc

# input config
_put_content "\$include $ROOT_DIR/.inputrc # modified by han" ~/.inputrc

# cronjob auto update
CRON_JOB="su -s /bin/sh nobody -c 'cd $ROOT_DIR && /usr/bin/git pull -q origin master'"
if type crontab 2>&1 >/dev/null; then
    if crontab -l | grep "$CRON_JOB" 2>&1 >/dev/null; then
        echo "already has cron job"
    else
        (
            crontab -l
            printf "* * * * * $CRON_JOB\r\n"
        ) | crontab -
    fi
fi

cat <<EOF
Success setup! All configuration will active in next login.

# Optional configuration

# git ignore
cp -f $ROOT_DIR/.gitignore ~/.gitignore

# condarc
cp -f $ROOT_DIR/.condarc ~/.condarc
EOF
