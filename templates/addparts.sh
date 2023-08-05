#!/bin/bash

PARTS_COMMENT="!! Contents within this block are managed by https://github.com/hanke0/dotfiles !!"
PARTS_ID=hanke0/dotfiles
PARTS_SUFFIX=.bak
PARTS_DRYRUN=
PARTS_YES=

adparts_read_yes() {
    case "$PARTS_YES" in
    1 | true)
        return 0
        ;;
    esac
    local answer
    answer=
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

addparts_awk_comment() {
    case "$1" in
    '"')
        echo '\"'
        ;;
    *)
        echo "$1"
        ;;
    esac
}

addparts_backupfile() {
    if [ -z "$PARTS_SUFFIX" ]; then
        return 0
    fi
    if [ -f "$1" ]; then
        cp -f "$1" "$1$PARTS_SUFFIX"
    fi
}

addparts_check() {
    local file awkleading awktrailing
    file="$1"
    awkleading="$2"
    awktrailing="$3"
    if ! [ -e "$file" ]; then
        printf "OK"
        return 0
    fi

    awk "(\$0 == \"$awkleading\"){ start=1 }
(\$0 == \"$awktrailing\") { if (start) start=0; else print \"RAW FINISH\"; }
END { if (!start) { print \"OK\" } }
" "$file"
}

addparts_append() {
    local dest src awkleading awktrailing
    dest="$1"
    src="$2"
    awkleading="$3"
    awktrailing="$4"
    if ! [ -e "$file" ]; then
        cat "$src"
        return 0
    fi

    awk "(\$0 == \"$awkleading\"){ start=1 }
(\$0 == \"$awktrailing\") { end=1 }
(!start && !end){print}
(start && end) { added=1; while ((getline<\"$src\") > 0) {print} }
(end){ start=0;end=0 }
END { if (!added) { while ((getline<\"$src\") > 0) {print} } }
" "$dest"
}

addparts() {
    local file commentsign content
    local textfile note leading trailing awkcommentsign awkleading awktrailing
    file="$1"
    commentsign="$2"
    content="$3"

    awkcommentsign=$(addparts_awk_comment "$commentsign")
    leading=">>> $PARTS_ID >>>"
    trailing="<<< $PARTS_ID <<<"
    awkleading="$awkcommentsign $leading"
    awktrailing="$awkcommentsign $trailing"

    if [ "$(addparts_check "$file" "$awkleading" "$awktrailing")" != "OK" ]; then
        echo >&2 "file has a bad block of contents, please check it: $file"
        return 1
    fi
    textfile=$(mktemp --tmpdir= hanke0.dotfiles.XXXXXXXX.tmp)
    if [ -z "$textfile" ]; then
        echo >&2 "cannot make temporery file"
        return 1
    fi
    cat >"$textfile" <<EOF
$commentsign $leading
$commentsign $PARTS_COMMENT
$content
$commentsign $trailing
EOF
    text=$(addparts_append "$file" "$textfile" "$awkleading" "$awktrailing")
    rm -f "$textfile"
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
    case "$PARTS_DRYRUN" in
    1 | true)
        return 0
        ;;
    esac
    if adparts_read_yes "!!! $note [Y/n]?"; then
        addparts_backupfile "$file"
        cat >"$file" <<<"$text"
    fi
}
