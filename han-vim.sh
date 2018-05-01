#!/bin/bash

set -e

function getPlug() {
    curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

function cleanOldSetting() {
    rm -rf ~/.vimrc ~/.vim
}

function getSetting() {
    curl -fsSLo ~/.vimrc https://github.com/ko-han/dotfiles/blob/master/.vimrc
}

function PlugInstall() {
    vim -c "PlugInstall"
}

function main() {
    cleanOldSetting
    getSetting
    getPlug
    PlugInstall
}

echo "--------------- han-vim ----------------"
echo
while :
    do
        read -r -p "This will delete '~/.vim' and '~/.vimrc', Continue to install? [Y/n] " input
        case $input in
            [yY][eE][sS]|[yY])
                main
                exit 0
                ;;
            [nN][oO]|[nN])
                exit 1
                ;;
            *)
                echo "Invalid input..."
                ;;
        esac
done
