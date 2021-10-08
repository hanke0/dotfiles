#!/usr/bin/env bash
set -e

ABS_PATH="$(realpath "$0")"
ROOT_DIR="$(dirname "$ABS_PATH")"

_has_content() {
    if [[ ! -f "$2" ]]; then
        return 1
    fi
    grep "$1" "$2" >/dev/null 2>&1
}

_put_content() {
    if _has_content "$1" "$2"; then
        return 0
    fi
    echo "modified $2"
    echo "$1" >>"$2"
}

# bashrc config
_put_content "export PAHT=\"\$PATH:$ROOT_DIR/bin\"" ~/.bashrc
_put_content "[[ -f '$ROOT_DIR/.bashrc' ]] && . '$ROOT_DIR/.bashrc'" ~/.bashrc

# git config
git config --global include.path "$ROOT_DIR/.gitconfig"

# tmux config
_put_content "source-file $ROOT_DIR/.tmux.conf" ~/.tmux.conf

# vim config
_put_content "source $ROOT_DIR/.vimrc" ~/.vimrc

# zsh config
_put_content "[[ -f '$ROOT_DIR/.zshrc' ]] && . '$ROOT_DIR/.zshrc'" ~/.zshrc

# input config
_put_content "\$include $ROOT_DIR/.inputrc" ~/.inputrc

# cronjob auto update
CRON_JOB="su -s /bin/sh nobody -c 'cd $ROOT_DIR && /usr/bin/git pull -q origin master'"
if type crontab >/dev/null 2>&1; then
    crontab -l || true # ignore error of no cron job for user.
    if crontab -l | grep "$CRON_JOB" >/dev/null 2>&1; then
        echo "already has cron job"
    else
        (
            crontab -l
            printf "%s" "* * * * * $CRON_JOB\r\n"
        ) | crontab -
    fi
fi

echo "Success setup! All configuration will active in next login."
optional_sh="/tmp/han-dotfiles-optional-$RANDOM.sh"
tee "$optional_sh" <<EOF
# Optional configuration

# git ignore
ln -s $ROOT_DIR/.gitignore $(echo ~)/.gitignore

# condarc
ln -s  $ROOT_DIR/.condarc $(echo ~)/.condarc
EOF

echo "Execute the following command to activate the above options."
echo "sh $optional_sh"
