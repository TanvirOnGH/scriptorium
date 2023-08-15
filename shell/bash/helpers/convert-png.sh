#!/bin/sh

# Converts all image files of any format to PNG, ensuring each converted image has a unique name
# while ignoring already generated files

for file in *.*; do
    # Check if the file name matches the pattern "output-<num>.png"
    if [[ ! "$file" =~ ^output-[0-9]+\.png$ ]]; then
        # Requires `file` to check file type
        if [ -f "$file" ] && file --mime-type "$file" | grep -q "image"; then
            counter=1
            new_file="output-${counter}.png"
            while [ -e "$new_file" ]; do
                counter=$((counter + 1))
                new_file="output-${counter}.png"
            done

            # Requires ImageMagick
            convert "$file" "$new_file"
        fi
    fi
done
