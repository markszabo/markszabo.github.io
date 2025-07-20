#!/bin/bash

# Exit on error
set -e

# Check input
if [ -z "$1" ]; then
    echo "Usage: $0 <folder>"
    exit 1
fi

INPUT_DIR="$1"

# Validate folder
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: '$INPUT_DIR' is not a directory"
    exit 1
fi

# Process files
for file in "$INPUT_DIR"/*.{jpg,jpeg,JPG,JPEG,png,PNG}; do
    [ -e "$file" ] || continue  # skip if no match

    extension="${file##*.}"
    extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    tmp_file="${file}.tmp"

    if [[ "$extension_lower" == "jpg" || "$extension_lower" == "jpeg" ]]; then
        # Remove metadata and compress JPEG
        convert "$file" -strip -interlace Plane -sampling-factor 4:2:0 -quality 85 "$tmp_file"
    elif [[ "$extension_lower" == "png" ]]; then
        # Remove metadata from PNG
        convert "$file" -strip "$tmp_file"
    else
        continue
    fi

    mv "$tmp_file" "$file"
    echo "Processed: $(basename "$file")"
done

echo "✅ Done cleaning and compressing in: $INPUT_DIR"
