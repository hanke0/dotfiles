#!/usr/bin/env bash

__han_dotfiles=(
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

__han_dotfiles_ask=false

__ask_user_permit() {
    if [[ $__han_dotfiles_ask = "true" ]]; then
        return 0
    fi
    printf "%s" "Do you wish to overwrite ${1}?[y/N] "
    local answer
    read -r answer
    case ${answer} in
    [Yy]*)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

__setup_han_dotfiles() {
    local dryrun="$1"
    local backupdir=~/.dotfiles.backup/$(date +%Y-%m-%dT%H-%M-%S)

    local file
    if [[ ! -d "$backupdir" ]]; then
        ${dryrun} mkdir -p "$backupdir"
    fi
    for file in "${__han_dotfiles[@]}"; do
        if [[ -L ~/"$file" ]]; then
            ${dryrun} unlink ~/"$file"
        fi
        if __ask_user_permit "$file"; then
            if [[ -e ~/"$file" ]]; then
                ${dryrun} cp -rf ~/"$file" "$backupdir/$file"
            fi
            ${dryrun} cp -rf "$file" ~/
        fi
    done
    ${dryrun} . ~/.bashrc
}

case "$1" in
-n)
    __setup_han_dotfiles "echo"
    ;;
-h)
    echo "$0" "[-n] [-h] [-ny]"
    ;;
-y)
    __han_dotfiles_ask=true
    __setup_han_dotfiles
    ;;
-ny)
    __han_dotfiles_ask=true
    __setup_han_dotfiles "echo"
    ;;
*)
    __setup_han_dotfiles
    ;;
esac

unset __setup_han_dotfiles
unset __han_dotfiles
unset __ask_user_permit
unset __han_dotfiles_ask
