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

__setup_han_dotfiles() {
  local dryrun="$1"
  local backupdir=~/.dotfiles.backup

  local file
  if [[ ! -d "$backupdir" ]]; then
    ${dryrun} mkdir -p "$backupdir"
  fi
  for file in "${__han_dotfiles[@]}"; do
    if [[ -L ~/"$file" ]]; then
      ${dryrun} unlink ~/"$file"
    else
      if [[ -e ~/"$file" ]]; then
        ${dryrun} cp -rf ~/"$file" "$backupdir/$file"
      fi
    fi
    ${dryrun} cp -rf "$file" ~/
  done
  ${dryrun} . ~/.bashrc
}

case "$1" in
-n | --dry-run | n | dry | dry-run)
  __setup_han_dotfiles "echo"
  ;;
-h | --help | help)
  echo "$0" "[-n --dry-run] [-h --help]"
  ;;
*)
  echo -n "Do you wish to overwrite ${__han_dotfiles[*]}?[y/N] "
  read -r answer
  case ${answer} in
  [Yy]*)
    __setup_han_dotfiles
    ;;
  *) ;;
  esac
  ;;
esac
unset __setup_han_dotfiles
unset __han_dotfiles
