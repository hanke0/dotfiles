#!/usr/bin/env bash

set -e

case "$DEBUG" in
true | 1 | on)
    set -x
    ;;
*) ;;
esac

ABS_PATH="$(realpath "$0")"
ROOT_DIR="$(dirname "$ABS_PATH")"
ME="$(whoami)"

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

append_content() {
    file="$1"
    content="$2"
    patten="$3"
    if [ -z "$patten" ]; then
        patten="$content"
    fi
    if ! grep -qF "$patten" "$file"; then
        echo "$content" >>"$file"
    fi
}

# bashrc config
_put_content "export PATH=\"\$PATH:$ROOT_DIR/bin\"" ~/.bashrc
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
CRON_JOB="/bin/bash $ROOT_DIR/update.sh"
if type crontab >/dev/null 2>&1; then
    crontab -l >/dev/null || true # ignore error of no cron job for user.
    cronfile="/tmp/handotfiles-cron-$ME.job"
    data="$(crontab -l)"
    echo "$data" | grep -v "$ROOT_DIR" >"$cronfile"
    printf "%s\n" "* * * * * $CRON_JOB" >>"$cronfile"
    # Tips for mac user: add cron to the Full Disk Access group
    cat "$cronfile" | grep -E -v "^$" | crontab -
fi

echo "Success setup! All confguration will active in next login."
optional_sh="/tmp/han-dotfiles-optional-$ME.sh"
cat >"$optional_sh" <<EOF
# Optional configuration

# git ignore
ln -s $ROOT_DIR/.gitignore $(echo ~)/.gitignore

# condarc
ln -s $ROOT_DIR/.condarc $(echo ~)/.condarc
EOF

echo "Execute the following command to activate the above options."
echo "sh $optional_sh"
