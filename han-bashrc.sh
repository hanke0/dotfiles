#!/bin/bash

set -e

config=(".bashrc" ".bash_alias" ".bash_path" ".bash_plugin" ".bash_prompt" ".bash_function")

tmp=".bash.tmp"

function delete_tmp() {
    if [ -e ~/"$tmp" ]; then
        rm ~/"$tmp"
    fi
}

function get_setting() {
    set +e
    for var in  ${config[@]} ; do
        echo 'downloading' $var
        echo "# ------------------------ $var ----------------------------" >> ~/"$tmp"
        curl -fsSL 'https://raw.githubusercontent.com/ko-han/dotfiles/master/bash/'"$var" >> ~/"$tmp"
        echo "" >> ~/"$tmp"
    done
    set -e
}

function set_setting() {
    cat ~/"$tmp" >> ~/.bashrc
}

function delete_bashrc() {
    if [ -e ~/.bashrc ]; then
    read -r -p "Do you want delete '~/.bashrc'?[y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            rm ~/.bashrc
            ;;
        *)
            ;;
    esac
    fi
}

function activate_now() {
    read -r -p "Activate now?[Y/N] " input
    case $input in
        [yY][eE][sS]|[yY])
            [ -e ~/.bashrc ] && . ~/.bashrc
            ;;
        *)
            ;;
    esac
}

echo "--------------- han-bashrc ----------------"
echo ""

delete_tmp
get_setting
delete_bashrc
set_setting
activate_now
delete_tmp



