#!/usr/bin/env bash
RAW_PARAMS=("$@")

OPTIONS=di:r:v
LONGOPTIONS=debug,inputdir:,random:,verbose

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")

[[ $? -ne 0 ]] && exit 3

eval set -- "$PARSED"

while true; do
    [[ -z "$1" ]] && break
    case "$1" in
    -d | --debug)
        echo "debug" "$1"
        shift
        ;;
    -i | --inputdir)
        echo "inputdir" "$1" "$2"
        shift 2
        ;;
    -v | --verbose)
        echo "verbose $1"
        shift
        ;;
    -r | --random)
        echo "random" "$1" "$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "arguments error $1"
        ;;
    esac
done

echo "unknown: " "$@"
echo "raw:" "${RAW_PARAMS[@]}"
