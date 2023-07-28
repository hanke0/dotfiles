#!/usr/bin/env bash

set -e
set -o pipefail

ALWAYS_YES=false
DRYRUN=

print_help() {
    cat <<EOF
Usage: ${0##*/} [OPTION]...

OPTION:
  -y --yes            Don't ask for confirmation of install options.
  -n --dry-run        Show what this script would do
  -v --verbose        Verbose output command
  -b --backup=SUFFIX  Make backup when given suffix (default to $SUFFIX).
                      Do not backup when suffix is empty.
EOF
}

SUFFIX=.hanke0.dotfiles.bak
while [ $# -gt 0 ]; do
    case "$1" in
    -b | --backup)
        SUFFIX="$2"
        shift 2
        ;;
    -b=* | --backup=*)
        SUFFIX="${1#*=}"
        shift
        ;;
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

getrealpath() (
    file=
    path=$1
    [ -d "$path" ] || {
        file=/$(basename -- "$path")
        path=$(dirname -- "$path")
    }
    {
        path=$(cd -- "$path" && pwd)$file
    } || exit $?
    printf %s\\n "/${path#"${path%%[!/]*}"}"
)

ABS_PATH="$(getrealpath "$0")"
ROOT_DIR="$(dirname "$ABS_PATH")"

if [ -z "$ROOT_DIR" ]; then
    echo >&2 "cannot get root folder"
    exit 1
fi

if ! [ -f "$ROOT_DIR/install.sh" ]; then
    echo >&2 "cannot get root foler"
    exit 1
fi

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

backup() {
    if [ -z "$SUFFIX" ]; then
        return 0
    fi
    if [ -f "$1" ]; then
        cp -f "$1" "$1$SUFFIX"
    fi
}

awk_comment() {
    case "$1" in
    '"')
        echo '\"'
        ;;
    *)
        echo "$1"
        ;;
    esac
}

START_SIGN=">>> hanke0/dotfiles >>>"
COMMENTLINE="!! Contents within this block are managed by https://github.com/hanke0/dotfiles !!"
FINISH_SIGN="<<< hanke0/dotfiles <<<"

check_content() {
    local commentsign file
    commentsign="$(awk_comment "$1")"
    file="$2"
    if ! [ -e "$file" ]; then
        printf "OK"
        return 0
    fi

    awk "(\$0 == \"$commentsign $START_SIGN\"){ start=1 }
(\$0 == \"$commentsign $FINISH_SIGN\") { if (start) start=0; else print \"RAW FINISH\"; }
END { if (!start) { print \"OK\" } }
" "$file"
}

append_content() {
    local commentsign file contentfile
    commentsign="$(awk_comment "$1")"
    file="$2"
    contentfile="$3"
    if ! [ -e "$file" ]; then
        cat "$contentfile"
        return 0
    fi

    awk "(\$0 == \"$commentsign $START_SIGN\"){ start=1 }
(\$0 == \"$commentsign $FINISH_SIGN\") { end=1 }
(!start && !end){print}
(start && end) { added=1; while ((getline<\"$contentfile\") > 0) {print} }
(end){ start=0;end=0 }
END { if (!added) { while ((getline<\"$contentfile\") > 0) {print} } }
" "$file"
}

add_parts() {
    local text commentsign file content textfile note
    content="$1"
    commentsign="$2"
    file="$3"
    if [ "$(check_content "$commentsign" "$file")" != "OK" ]; then
        echo >&2 "file has a bad block of contents, please check it: $file"
        exit 1
    fi
    textfile=/tmp/hanke0-dotfiles.tmp
    cat >"$textfile" <<EOF
$commentsign $START_SIGN
$commentsign $COMMENTLINE
$content
$commentsign $FINISH_SIGN
EOF
    text="$(append_content "$commentsign" "$file" "$textfile")"
    note=""
    if ! [ -e "$file" ]; then
        note="create file $file"
        echo "!!! $note with following content(diff output)"
        diff <(cat <<<"$text") <(cat <<<"") || true
    else
        if diff <(cat <<<"$text") "$file" >/dev/null 2>&1; then
            return 0
        fi
        note="change file $file"
        echo "!!! $note with following content(diff output)"
        diff <(cat <<<"$text") "$file" || true
    fi
    if in_dryrun; then
        return 0
    fi
    if read_yes "!!! $note [Y/n]?"; then
        backup "$file"
        cat >"$file" <<<"$text"
    fi
}

# bashrc config
add_parts "[[ -f '$ROOT_DIR/.bashrc' ]] && . '$ROOT_DIR/.bashrc'" "#" ~/.bashrc

# git config
$DRYRUN git config --global include.path "$ROOT_DIR/.gitconfig"

# tmux config
add_parts "source-file $ROOT_DIR/.tmux.conf" "#" ~/.tmux.conf

# vim config
add_parts "source $ROOT_DIR/.vimrc" '"' ~/.vimrc

# zsh config
add_parts "[[ -f '$ROOT_DIR/.zshrc' ]] && . '$ROOT_DIR/.zshrc'" "#" ~/.zshrc

# input config
add_parts "\$include $ROOT_DIR/.inputrc" "#" ~/.inputrc

add_parts "$(cat "$ROOT_DIR/.gitignore")" "#" ~/.gitignore

add_parts "$(cat "$ROOT_DIR/.bcrc")" "#" ~/.bcrc

echo "Success setup! All confguration will active in next login."
