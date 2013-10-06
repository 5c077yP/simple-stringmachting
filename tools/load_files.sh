#!/bin/bash

# Tool to load files from multiple hosts

USAGE="$0 FILE HOSTNAMES"

FILE=$1
shift
HOSTS=$@

[ -z "$FILE" ] && echo "no file given" && echo $USAGE && exit 1
[ -z "$HOSTS" ] && echo "no hostname given" && echo $USAGE &&exit 1

for h in $HOSTS; do
    mkdir -p data/$h
    cd data/$h
    scp $h:$FILE .
    cd ../../
done
