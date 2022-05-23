#!/bin/bash

# Program to sort the entries in a multi TB file (pseudo map-reduce).
# Version: 1.0

### Usage: sort-large-file.sh <inputfile>

## Assumptions:
# 1. There is no other file in the folder with filename starting with "$SORT_TMP_PREFIX"
# 2. There is enough free disk space to create a copy of input file and to store the output results file. In the worst the case I would suggest to have available disk space equal to twice the size of the input file.
# 3. Two instance of the script wont be run simultaneously in a same folder. As temporarily (_tmp) files generated may conflict. Will fix this in next version

## Performance tuning
# To best utilize the script, try to set 'temp_filesize' to be smaller than the number of lines in your input file.
# 'temp_filesize' represents number of lines of input data that are processed as a unit.
# Based on available RAM, # of cores, and number of lines in the input file, set optimal value for 'temp_filesize'

###---- Default value: You may want to change

SCRIPT_NAME="$(basename "$0")"

FILENAME=""
SORT_TMP_PREFIX="__tmp"
TMP_FILESIZE=65536
PARALLEL=1
SORT_ARGUMENT=
OUTPUT=""

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

usage() {
    echo "Usage: $SCRIPT_NAME [--parallel parallel] [--filesize bytes] [--prefix __tmp] [-o filename] [--extra-sort-option string]  <input_file>"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
    --parallel)
        PARALLEL="$(checked_argument "$1" "$2")"
        shift 2
        ;;
    --filesize)
        TMP_FILESIZE="$(checked_argument "$1" "$2")"
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
        SORT_ARGUMENT="$(checked_argument "$1" "$2")"
        shift 2
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

function __sort_large_file_subsort {
    subfilename=$1
    subfilename_tmp=$1".u"

    sort $SORT_ARGUMENT ${subfilename} -o ${subfilename_tmp}
    mv ${subfilename_tmp} ${subfilename}
}
export -f __sort_large_file_subsort

clean() {
    rm -f "$SORT_TMP_PREFIX"*
}

echo "1/4: splitting inputfile, cores available ${PARALLEL}"
split -a 7 -l "${TMP_FILESIZE}" "$FILENAME" "$SORT_TMP_PREFIX"

trap 'clean' EXIT

echo "2/4: processing individual files" ## processing individual files
ls "$SORT_TMP_PREFIX"* | xargs -P "${PARALLEL}" -n 1 -I % bash -c '__sort_large_file_subsort %' _ {}

echo "3/4: merging results" ## merging results
sort $SORT_ARGUMENT -m "$SORT_TMP_PREFIX"* -o "${OUTPUT}"

echo "4/4: cleaning" ## cleaning
clean
