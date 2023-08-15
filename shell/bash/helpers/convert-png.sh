#!/bin/sh

# Converts all image files of any format to PNG, ensuring each converted image has a unique name.
# Requires: ImageMagick

for file in *.*; do
    # Requires `file` to check file type
    if [ -f "$file" ] && file --mime-type "$file" | grep -q "image"; then
        convert "$file" "output-$file.png"
    fi
done
