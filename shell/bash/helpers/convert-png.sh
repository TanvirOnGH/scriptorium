#!/bin/sh

# Converts all images of any format to png ensuring each converted image has a unique name.
# Requires: ImageMagick

for file in *.*; do
    if [ -f "$file" ]; then
        convert "$file" "output-$file.png"
    fi
done
