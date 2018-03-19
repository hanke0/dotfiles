#!/bin/bash

TMP=$HOME"/tmp_han_vim_config"


function main() {
    git clone  https://github.com/ko-han/.vim.git $TMP
    echo
    echo "delete "$TMP"/.git"
    rm -rf $TMP"/.git"
    ls -A $TMP | xargs -i -t cp -rf $TMP/{} ~/
    chmod +x ~/renew-vim.sh
    echo "delete "$TMP
    rm -rf $TMP
    echo
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
