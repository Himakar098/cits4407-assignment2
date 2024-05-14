#!/bin/bash

# Check if the number of command-line arguments is exactly 2
if [ "$#" -ne 2 ]; then
    echo "Error: Two file names are required." >&2
    exit 1
fi

# Check if the first file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' does not exist or is not a regular file." >&2
    exit 1
fi

# Check if the second file exists
if [ ! -f "$2" ]; then
    echo "Error: File '$2' does not exist or is not a regular file." >&2
    exit 1
fi

# Get the word count for each file
count1=$(cat "$1" | wc -w)
count2=$(cat "$2" | wc -w)

# Compare word counts and print the appropriate message
if [ "$count1" -gt "$count2" ]; then
    echo "$1"
elif [ "$count1" -lt "$count2" ]; then
    echo "$2"
else
    echo "equal length"
fi
