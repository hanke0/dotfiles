#!/usr/bin/env bash

[ -z "$1" ] && exit 1

dest="$1"
shift
if [ $# -eq 0 ]; then
    tpls=(
        templates/parseoption.sh
    )
else
    tpls=("$@")
fi

# shellcheck source=/dev/null
. ./templates/addparts.sh

content=
for file in "${tpls[@]}"; do
    if [ -z "$content" ]; then
        content=$(tail -n +2 "$file")
    else
        content="$(
            cat <<EOF
$content
$(tail -n +2 "$file")
EOF
        )"
    fi
done

addparts "$dest" '#' "$content"
