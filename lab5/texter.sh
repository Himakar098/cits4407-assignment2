#!/bin/bash

# Check if the number of arguments is odd
if [ $# -eq 0 ] || [ $(( $# % 2 )) -eq 1 ]; then
    echo "Usage: ./texter.sh filename1 content1 [filename2 content2 ...]"
    exit 1
fi

# Loop through the arguments two at a time
while (( "$#" >= 2 )); do
    filename=$1
    content=$2
    echo "$content" > "$filename"
    shift 2
done
