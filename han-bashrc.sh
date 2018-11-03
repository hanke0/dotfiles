set -e

if [[ `ps -p $$` = *zsh* ]]
then
    # zsh
    config=(".zshrc" "export.sh" "functions.sh" "alias.sh")
    rc_file=$HOME/.zshrc
    to_dir=${HOME}/.han-zshrc
else
    # bash
    config=(".bashrc" "export.sh" "plugin.sh" "functions.sh" "alias.sh" "prompt.sh")
    rc_file=$HOME/.bashrc
    to_dir=${HOME}/.han-bashrc
fi


function get_setting() {
    [[ -d ${to_dir} ]] && /bin/rm -ri ${to_dir}
    [[ ! -d ${to_dir} ]] && mkdir ${to_dir}
    set +e
    for var in ${config[@]}; do
        echo 'downloading' $var
        curl -fsSL 'https://raw.githubusercontent.com/ko-han/dotfiles/master/bash/'"$var" > ${to_dir}/${var}
    done
    set -e
}


function add-activate() {
    set +e
    echo -n "Add activate to ${rc_file}?[y/N] "
    read input
    case $input in
    [yY][eE][sS] | [yY])
        echo "" >>~/.bashrc
        echo "# add by han-bashrc" >>${rc_file}
        for var in ${config[@]}; do
            echo "[[ -f ${to_dir}/${var} ]] && source ${to_dir}/${var}" >>$rc_file
        done
        ;;
    *) ;;

    esac
    set -e
}

get_setting
add-activate
