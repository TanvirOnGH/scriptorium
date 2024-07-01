#!/bin/sh
# shellcheck disable=SC3010,SC3043,SC3045
# Converts all image files of any format to PNG, ensuring each converted image has a unique name
# while ignoring already generated files

# Requires ImageMagick and file

# Function to convert images and move to old directory
convert_and_move() {
	local file="$1"
	local counter=1
	local new_file="output-${counter}.png"

	while [ -e "$new_file" ]; do
		counter=$((counter + 1))
		new_file="output-${counter}.png"
	done

	convert "$file" "$new_file"
	mv "$file" old/
	converted=$((converted + 1))
}

# Main script
if [ $# -eq 0 ]; then
	read -r -p "Enter the path to the directory: " directory
else
	directory="$1"
fi

if [ -d "$directory" ]; then
	cd "$directory" || exit
	mkdir -p old

	converted=0

	for file in *.*; do
		if [[ ! "$file" =~ ^output-[0-9]+\.png$ ]]; then
			if [ -f "$file" ] && file --mime-type "$file" | grep -q "image"; then
				convert_and_move "$file"
			fi
		fi
	done

	if [ "$converted" -eq 0 ]; then
		printf "%s\n" "No files found to convert. (Ignores: output-<num>.png)"
	else
		printf "%s\n" "Converted $converted files."
	fi
else
	printf "%s\n" "Error: Directory '$directory' not found."
fi
