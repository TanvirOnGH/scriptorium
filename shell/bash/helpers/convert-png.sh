#!/bin/sh

# Converts all image files of any format to PNG, ensuring each converted image has a unique name
# while ignoring already generated files

mkdir -p old

converted=0

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

            # Move the old file to the "old" directory
            mv "$file" old/

            converted=$((converted + 1)) # Increment the counter
        fi
    fi
done

if [ "$converted" -eq 0 ]; then
    printf "%s\n" "No files found to convert. (Ignores: output-<num>.png)"
else
    printf "%s\n" "Converted $converted files."
fi
