#!/usr/bin/env bash

CYCLO_LIMIT=5
case "$1" in
[1-9][0-9]*)
    CYCLO_LIMIT="$1"
    ;;
'') ;;
-h | --help | \? | help)
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]... [CYCLO_LIMIT=5]
print the sum of the cyclo over CYCLO_LIMIT

OPTIONS:
  -h --help print this text and exit.
EOF
    exit 0
    ;;
*)
    echo >&2 "bad options:" "$@"
    echo >&2 "--help for more information."
    exit 1
    ;;
esac

find_cyclo() {
    find . ! -path './stub/*' ! -path './*_test.go' -regex '.+\.go' -exec gocyclo -over "$CYCLO_LIMIT" {} \;
}

data="$(find_cyclo)"
if [[ -z "$data" ]]; then
    echo "no go files"
else
    echo "$data"
    echo "$data" | eval "awk '{sum+=\$1-$CYCLO_LIMIT} END {print \"over $CYCLO_LIMIT sum: \" sum}'"
fi
