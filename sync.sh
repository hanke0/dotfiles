#!/usr/bin/env bash

__setup_han_dotfiles() {
    local dryrun="$1"
    local backupdir=~/.dotfiles.backup

    local files=(
        .bashrc
        .condarc
        .gitconfig
        .gitignore
        .inputrc
        .tmux.conf
        .vimrc
        .zshrc
        bin
    )
    local file
    if [[ ! -d "$backupdir" ]]; then
        $dryrun mkdir -p "$backupdir"
    fi
    for file in "${files[@]}"; do
        if [[ -L ~/"$file" ]]; then
            $dryrun unlink ~/"$file"
        else
            if [[ -e ~/"$file" ]]; then
                $dryrun cp -rf ~/"$file" "$backupdir/$file"
            fi
        fi
        $dryrun cp -rf "$file" ~/
    done
    $dryrun . ~/.bashrc
}

case "$1" in
-n | --dry-run | n | dry | dry-run)
    __setup_han_dotfiles "echo"
    ;;
-h | --help | help)
    echo "$0" "[-n --dry-run] [-h --help]"
    ;;
*)
    __setup_han_dotfiles
    ;;
esac
unset __setup_han_dotfiles
