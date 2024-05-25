#!/bin/bash

# Function to display help
function display_help {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -o, --output-file   Specify the output file (default: requirements-combined.txt)"
    echo "  -d, --directory     Specify the directory to search for files (default: current directory)"
    echo "  -i, --input-file    Specify the input files (default: all files with 'requirements' in the name)"
    echo "  -h, --help          Display this help message"
    echo
}

# Default values
output_file="requirements-combined.txt"
directory=$(pwd)
input_files=()

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -o|--output-file) output_file="$2"; shift ;;
        -d|--directory) directory="$2"; shift ;;
        -i|--input-file) input_files+=("$2"); shift ;;
        -h|--help) display_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; display_help; exit 1 ;;
    esac
    shift
done

# Find all matching input files if not specified
if [ ${#input_files[@]} -eq 0 ]; then
    input_files=($(find "$directory" -type f -name "*requirements*.txt"))
fi

# Confirm the files to be combined
echo "The following files will be combined into $output_file:"
for file in "${input_files[@]}"; do
    echo "$file"
done

read -p "Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Check if output file exists and prompt for deletion
if [[ -f "$output_file" ]]; then
    echo "Output file $output_file already exists."
    read -p "Do you want to delete the existing file? (y/n): " delete_confirm
    if [[ "$delete_confirm" != "y" ]]; then
        echo "Operation cancelled."
        exit 1
    else
        rm "$output_file"
    fi
fi

# Combine the files
{
    for file in "${input_files[@]}"; do
        echo "# Contents of $file" >> "$output_file"
        cat "$file" >> "$output_file"
        echo -e "\n" >> "$output_file"
    done
} || {
    echo "An error occurred while combining the files."
    exit 1
}

echo "Files combined successfully into $output_file."
