#!/bin/bash

# Tool to filter files for content

USAGE="$0 DIR GREP_PAT"

DIR=$1
shift
GREP_PAT=$1

[ -z "$DIR" ] && echo "directory not set" && echo $USAGE && exit 1
[ -z "$GREP_PAT" ] && echo "grep pattern not set" && echo $USAGE && exit 1

for f in `find $DIR -type f`; do
    zgrep -E "$GREP_PAT" $f > $f.filtered
done
