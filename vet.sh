#!/usr/bin/env bash

shfmt -w -i 4 -- .bashrc *.sh **/*.sh
shellcheck -e SC1090 -- .bashrc *.sh **/*.sh

ignorecomplete=(
    _bash-complete.sh
    update-dotfiles.sh
    create-simple-systemd-service.sh
    lib.sh
    local-rsync.sh
)

is_ignore_complete() {
    local f
    for f in "${ignorecomplete[@]}"; do
        if [ "$1" = "$f" ]; then
            return 0
        fi
    done
    return 1
}

find ./bin -type f -name '*.sh' -print0 | while IFS= read -r -d '' file; do
    filename="$(basename "$file")"
    if is_ignore_complete "$filename"; then
        continue
    fi
    if ! grep -o "$filename" ./bin/_bash-complete.sh >/dev/null; then
        echo >&2 "WARNING: $filename has no completion"
    fi
done
