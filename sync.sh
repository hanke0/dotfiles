#!/usr/bin/env bash

set -e

ALWAYS_YES=false
DRYRUN=

print_help() {
    cat <<EOF
Usage: $(basename "$ABS_PATH") [OPTION]...

OPTION:
  -y --yes       Don't ask for confirmation of install options.
  -n --dry-run   Show what this script would do
  -v --verbose   Verbose output command
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
    -y | --yes)
        ALWAYS_YES=true
        shift
        ;;
    -n | --dry-run)
        DRYRUN='echo +'
        shift
        ;;
    -h | --help)
        print_help
        exit 1
        ;;
    -v | --verbose)
        set -x
        shift
        ;;
    *)
        echo >&2 "Bad options: $1"
        echo >&2 "Use -h or --help or more informations."
        exit 1
        ;;
    esac
done

ABS_PATH="$(realpath "$0")"
ROOT_DIR="$(dirname "$ABS_PATH")"
ME="$(whoami)"

read_yes() {
    if [ "$ALWAYS_YES" = "true" ]; then
        return 0
    fi
    local answer=
    read -r -p "$@" answer
    case "$answer" in
    y* | Y* | '')
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

in_dryrun() {
    test -n "$DRYRUN"
}

has_content() {
    if [ ! -f "$2" ]; then
        return 1
    fi
    grep -qF "$1" "$2"
}

append_content() {
    file="$2"
    content="$1"
    patten="$3"
    if [ -z "$patten" ]; then
        patten="$content"
    fi
    if ! has_content "$patten" "$file"; then
        if in_dryrun; then
            $DRYRUN "echo \"$content\" >>\"$file\""
        else
            echo "$content" >>"$file"
        fi
    fi
}

add_cronjob() {
    local schedule="$1"
    local commander="$2"
    local remove_pattern="$3"
    local f=
    local data=

    if [ -z "$3" ]; then
        remove_pattern="$2"
    fi
    f="$(mktemp /tmp/handotfiles-cron.$ME.XXXX)"
    data="$(crontab -l 2>/dev/null || true)"
    echo "$data" >"$f"
    data="$(grep -v "$remove_pattern" "$f")"
    printf "%s" "$data" >"$f"
    printf "\n%s %s" "$schedule" "$commander" >>"$f"
    data="$(cat "$f")"
    # remove leading whitespace characters
    data="${data#"${data%%[![:space:]]*}"}"
    if ! in_dryrun; then
        echo "$data" | crontab -
    else
        $DRYRUN "echo $data | contab -"
    fi
    rm "$f"
}

# bashrc config
append_content "export PATH=\"\$PATH:$ROOT_DIR/bin\"" ~/.bashrc
append_content "[[ -f '$ROOT_DIR/.bashrc' ]] && . '$ROOT_DIR/.bashrc'" ~/.bashrc

# git config
$DRYRUN git config --global include.path "$ROOT_DIR/.gitconfig"

# tmux config
append_content "source-file $ROOT_DIR/.tmux.conf" ~/.tmux.conf

# vim config
append_content "source $ROOT_DIR/.vimrc" ~/.vimrc

# zsh config
append_content "[[ -f '$ROOT_DIR/.zshrc' ]] && . '$ROOT_DIR/.zshrc'" ~/.zshrc

# input config
append_content "\$include $ROOT_DIR/.inputrc" ~/.inputrc

if read_yes "Add cronjob for updating: [Y/n]: "; then
    # cronjob auto update
    CRON_JOB="/bin/bash $ROOT_DIR/update.sh"
    if type crontab >/dev/null 2>&1; then
        add_cronjob "* * * * *" "$CRON_JOB" "$ROOT_DIR"
    fi
fi

link_yes() {
    if [ ! -f "$2" ]; then
        $DRYRUN ln -s "$1" "$2"
    else
        if read_yes "$2 Exists, do you want delete it? [Y/n]: "; then
            $DRYRUN rm "$2"
            $DRYRUN ln -s "$1" "$2"
        fi
    fi
}

if read_yes "Link ~/.gitignore? [Y/n]: "; then
    link_yes "$ROOT_DIR/.gitignore" ~/.gitignore
fi

if read_yes "Link ~/.condarc [Y/n]: "; then
    link_yes "$ROOT_DIR/.condarc" ~/.condarc
fi

echo "Success setup! All confguration will active in next login."
