#!/bin/bash

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
