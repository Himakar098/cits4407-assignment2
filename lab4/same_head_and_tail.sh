#!/bin/bash

# Check if a filename is provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide a filename." >&2
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' does not exist or is not a regular file." >&2
    exit 1
fi

# Read the first and last lines of the file
first_line=$(head -n 1 "$1")
last_line=$(tail -n 1 "$1")

# Compare the first and last lines and print the result
if [ "$first_line" = "$last_line" ]; then
    echo "The first and last lines of '$1' are the same: $first_line"
else
    echo "The first and last lines of '$1' are different."
fi

