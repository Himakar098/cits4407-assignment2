#!/bin/bash

# Function to print the header of a file
print_header() {
    echo "Header of $1:"
    head -n 1 "$1"
    echo
}

# Check if exactly three arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 file1.tsv file2.tsv file3.tsv" >&2
    exit 1
fi

# Print the headers of each file
for file in "$@"; do
    print_header "$file"
done

