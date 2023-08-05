#!/usr/bin/env bash

[ -z "$1" ] && exit 1

# shellcheck source=/dev/null
. ./templates/addparts.sh

content=
for file in templates/parseoption.sh templates/addparts.sh; do
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

addparts "$1" '#' "$content"
