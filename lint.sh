#!/usr/bin/env bash

_bash_format() {
    shfmt -w -i 4 "$@"
}
shfmt_option=(shfmt -w -i 4)
shellcheck_option=(shellcheck)

find ./ -type f -name "*.sh" -exec "${shfmt_option[@]}" {} +
find ./ -type f -name "*.sh" -exec "${shellcheck_option[@]}" {} +

"${shfmt_option[@]}" .bashrc
"${shellcheck_option[@]}" .bashrc
