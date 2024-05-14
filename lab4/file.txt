#!/bin/bash

# Get the file name from the command line argument
# Check if the file exists
# If the file exists, use the head and tail commands to print the third line of the file
# If the file does not exist, print an error message and exit
#!/bin/bash

# Get the file name from the command line argument
file="$1"

# Check if the file exists
if [ -e "$file" ]; then
    # Use head and tail commands to print the third line of the file
    line=$(head -n 3 "$file" | tail -n 1)
    echo "$line"
else
    # Print an error message if the file does not exist
    echo "Error: File '$file' does not exist."
    exit 1
fi

