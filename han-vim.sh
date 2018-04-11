#!/bin/bash
set -e

TMP=$HOME"/tmp_han_vim_config"


function main() {
    echo "Download files..."
    git clone  https://github.com/ko-han/.vim.git $TMP  1>/dev/null 2>/dev/null
    echo "Copy files..."
    cp -R -f $TMP"/.vimrc" $TMP"/.vim" $HOME
    echo "Delete downloaded files"
    rm -rf $TMP
    echo "Great, All Things Hava Done, Enjoy It!"
}

if [ -d $TMP ]
then
    echo $TMP" exist, delete it(y/n)"
    read answer
    if [ $answer == "y" ]
    then
        rm -rf $TMP
        main
    else
        echo "Fail."
        exit 1
    fi
else
    main
fi
