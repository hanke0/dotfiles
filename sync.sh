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

__ask_user_permit() {
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
  local backupdir=~/.dotfiles.backup

  local file
  if [[ ! -d "$backupdir" ]]; then
    ${dryrun} mkdir -p "$backupdir"
  fi
  for file in "${__han_dotfiles[@]}"; do
    if [[ -L ~/"$file" ]]; then
      ${dryrun} unlink ~/"$file"
    fi
    if [[ -e ~/"$file" ]]; then
      if __ask_user_permit "$file"; then
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
  __setup_han_dotfiles
  ;;
esac

unset __setup_han_dotfiles
unset __han_dotfiles
unset __ask_user_permit
