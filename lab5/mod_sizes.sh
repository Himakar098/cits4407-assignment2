#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: sizes.sh [OPTIONS]"
    echo "Options:"
    echo "  -d DIRECTORY    Count files in DIRECTORY instead of ."
    echo "  -h              Display this help message and exit"
    exit 0
}

# Initialize directory variable with default value
directory="."

# Process command-line options
while getopts "hd:" opt; do
    case $opt in
        h)
            display_help
            ;;
        d)
            directory="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Shift command line arguments to ignore processed options
shift $((OPTIND - 1))

# Change directory
cd "$directory" || exit 1

# Print stats for each file
for file in *; do
    # Check if the file is a regular file
    if [ -f "$file" ]; then
        # Get the file size using wc -c and cut
        size=$(wc -c < "$file" | cut -d ' ' -f 1)
        echo "$size $file"
    fi
done

# Print the size and name of the largest file
largest=$(ls -l | grep '^-' | awk '{print $5, $9}' | sort -nr | head -n 1)
echo "Largest is $largest"

# Print the sum of all file sizes
total=$(ls -l | grep '^-' | awk '{sum+=$5} END {print sum}')
echo "Sum is $total"
