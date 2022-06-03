#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_NAME="$(basename "$0")"
DIR="$(pwd || exit 1)"

FILENAME=""
SORT_TMP_PREFIX="__tmp$RANDOM"
TMP_LINES=65535
PARALLEL=1
SORT_ARGUMENT=()
OUTPUT=""
TEST=0

die() {
    echo >&2 "$@"
    exit 1
}

checked_argument() {
    if [ -z "$2" ]; then
        die "$1 needs an arguments"
    fi
    printf "%s" "$2"
}

set_filename() {
    if [ -n "$FILENAME" ]; then
        die "Too many arguments"
    fi
    FILENAME="$1"
}

VERSION="1.0"

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTION]... <input_file>

Version: 1.0
Objetive: Program to sort lines in a multi TB file (pseudo map-reduce).
Dependences: bash, sort, find, split, read, printf, rm, xargs

Assumptions:
1. There is no other file in the folder with filename starting with input prefix.
2. There is enough free disk space to create a copy of input file and to store
   the output results file. In the worst the case I would suggest to have
   available disk space equal to twice the size of the input file.
3. Two instance of the script would be run simultaneously in a same folder with
   different prefixes. As temporarily files generated may conflict, same prefix
   won't works. Default behaviour uses random number, which gets from \$RANDOM,
   to avoid filename conflict.

Options:
       --extra-sort-option  extra flags that sends to sort.
    -h --help               display this help and exit.
    -l --lines=NUMBER       NUMBER lines per temp file (default: 65535).
    -o --output=FILE        output FILE (default to input file with a '.sorted' suffix).
    -p --parallel=NUMBER    change the number of sorts run concurrently to NUMBER (default to 1).
       --prefix             PREFIX of the temporaily files (default: __tmp and a random number).
       --version            ouput version information and exit.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
    -p | --parallel)
        PARALLEL="$(checked_argument "$1" "$2")"
        shift 2
        ;;
    -l | --lines)
        TMP_LINES="$(checked_argument "$1" "$2")"
        shift 2
        ;;
    --prefix)
        SORT_TMP_PREFIX="$(checked_argument "$1" "$2")"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    -o | --output)
        OUTPUT="$(checked_argument "$1" "$2")"
        shift 2
        ;;
    --extra-sort-option)
        # want split words here.
        # shellcheck disable=SC2207
        SORT_ARGUMENT+=($(checked_argument "$1" "$2"))
        shift 2
        ;;
    --test)
        TEST=1
        shift 1
        ;;
    --version)
        echo "$SCRIPT_NAME $VERSION"
        echo "Written by ko-han."
        exit 0
        ;;
    --)
        if [ "$#" -ne 2 ]; then
            die "Too many arguments"
        fi
        set_filename "$2"
        shift 2
        break
        ;;
    -*)
        die "Unknown option: $1"
        ;;
    *)
        set_filename "$1"
        shift 1
        ;;
    esac
done

if [ -z "$FILENAME" ]; then
    usage
    exit 1
fi
if [ -z "$OUTPUT" ]; then
    OUTPUT="${FILENAME}.sorted"
fi
if [ ! -f "$FILENAME" ]; then
    die "file not exists: $FILENAME"
fi
if [ -f "$OUTPUT" ]; then
    die "output file exists: $OUTPUT"
fi
INPUT_DIR="$(dirname "$FILENAME" || exit 1)"
if [ -z "$INPUT_DIR" ]; then
    die "cannot get input file folder name".
fi
BASE_FILENAME="$(basename "$FILENAME")"

TEMP_FILES=()

list_temp_files() {
    while IFS= read -r -d $'\0'; do
        TEMP_FILES+=("$REPLY")
    done < <(find "$INPUT_DIR" -name "${SORT_TMP_PREFIX}*" -type f -print0)
}

clean() {
    find "$INPUT_DIR" -name "${SORT_TMP_PREFIX}*" -type f -exec rm {} +
}

__sort_large_file_subsort() {
    subfilename="$1"
    subfilename_tmp="${subfilename}.u"

    sort "${SORT_ARGUMENT[@]}" "${subfilename}" -o "${subfilename_tmp}"
    mv "${subfilename_tmp}" "${subfilename}"
}
export -f __sort_large_file_subsort

trap 'clean' EXIT

echo "1/4: splitting input file"
cd "$INPUT_DIR"
split -a 12 -d -l "${TMP_LINES}" "$BASE_FILENAME" "$SORT_TMP_PREFIX"
cd "$DIR"
list_temp_files

echo "2/4: processing individual files."
printf "%s\0" "${TEMP_FILES[@]}" | xargs --null -P "${PARALLEL}" -n 1 -I % bash -c '__sort_large_file_subsort %' _ {}

echo "3/4: merging results"
sort "${SORT_ARGUMENT[@]}" -m "${TEMP_FILES[@]}" -o "${OUTPUT}"

echo "4/4: cleaning"
clean

if [ "$TEST" -ne 0 ]; then
    _test_out=/tmp/sort-large-file.sh.testout
    echo "extra: sort result $_test_out"
    sort -o "$_test_out" "${SORT_ARGUMENT[@]}" "$FILENAME"
    diff -a "$OUTPUT" "$_test_out"
fi
