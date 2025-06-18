#!/bin/bash

# Script to remove orphaned .uid files in the NeuroVision project
# An orphaned .uid file is one that doesn't have a corresponding .gd file

echo "Finding and removing orphaned .uid files..."
echo "========================================="

count=0
orphaned_files=()

# Find all .uid files and check if their corresponding .gd files exist
while IFS= read -r uid_file; do
    # Remove the .uid extension to get the base file path
    base_file="${uid_file%.uid}"
    
    # Check if the corresponding file exists
    if [ ! -f "$base_file" ]; then
        orphaned_files+=("$uid_file")
        ((count++))
    fi
done < <(find . -name "*.uid" -type f)

# Display the orphaned files
if [ ${#orphaned_files[@]} -eq 0 ]; then
    echo "No orphaned .uid files found!"
else
    echo "Found $count orphaned .uid files:"
    echo
    
    for file in "${orphaned_files[@]}"; do
        echo "  - $file"
    done
    
    echo
    echo "Would you like to remove these files? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo
        echo "Removing orphaned .uid files..."
        
        for file in "${orphaned_files[@]}"; do
            rm "$file"
            echo "  Removed: $file"
        done
        
        echo
        echo "Successfully removed $count orphaned .uid files!"
    else
        echo "Operation cancelled. No files were removed."
    fi
fi