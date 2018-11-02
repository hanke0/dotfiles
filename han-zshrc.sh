#!/bin/bash

set -e

config=("bash/export.sh" "bash/plugin.sh" "bash/functions.sh" "bash/alias.sh" "zsh/.zshrc")

tmp=~/.han.zsh.tmp
to_file=${1:-~/.zsh_config}


function delete_tmp() {
    if [ -e ${tmp} ]; then
        rm ${tmp}
    fi
}

function get_setting() {
    set +e
    for var in ${config[@]}; do
        echo 'downloading' $var
        echo "" >>${tmp}
        echo "# ------------------------ $var start ----------------------------" >>${tmp}
        echo "" >>${tmp}
        curl -fsSL 'https://raw.githubusercontent.com/ko-han/dotfiles/master/'"$var" >>${tmp}
        echo "" >>${tmp}
        echo "# ------------------------ $var finish ----------------------------" >>${tmp}
        echo "" >>${tmp}
    done
    set -e
}

function set_setting() {
    cat ${tmp} >>${to_file}
}

function delete_bashrc() {
    if [ -e ${to_file} ]; then
        read -r -p "Do you want delete ${to_file}?[yes/No] " input
        case $input in
        [yY][eE][sS] | [yY])
            rm ${to_file}
            ;;
        *) ;;
        esac
    fi
}

function activate() {
    set +e
    read -r -p "Add activate to ~/.zshrc?[Y/N] " input
    case $input in
    [yY][eE][sS] | [yY])
        echo "" >>~/.bashrc
        echo "# add by han-zshrc" >>~/.zshrc
        echo "[ -f ${to_file} ] && source ${to_file}" >>~/.zshrc
        echo "add '[ -f ${to_file} ] && source ${to_file}' to ~/.zshrc"
        ;;
    *) ;;

    esac
    set -e
}

echo "--------------- han-zshrc----------------"

delete_tmp
get_setting
delete_bashrc
set_setting
delete_tmp
activate
