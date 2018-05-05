#!/bin/bash

set -e

config=(".bashrc" ".bash_alias" ".bash_path" ".bash_plugin" ".bash_prompt")

tmp=".bash.tmp"

function getSetting() {
    if [ -e ~/"$tmp" ]; then
        rm ~/"$tmp"
    fi
    set +e
    for var in  ${config[@]} ; do
        echo 'downloading' $var
        echo "------------------------ $var ----------------------------" >> ~/"$tmp"
        curl -fsSL 'https://raw.githubusercontent.com/ko-han/dotfiles/master/bash/'"$var" >> ~/"$tmp"
        echo "" >> ~/"$tmp"
    done
    set -e
}

function setSetting() {
    cat ~/"$tmp" >> ~/.bashrc
}

function deleteBashrc() {
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

function activateNow() {
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

getSetting
deleteBashrc
setSetting
activateNow




