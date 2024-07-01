#!/bin/bash

usage() {
	echo "Usage: $0 [directory]"
	echo "Organizes photos by orientation (landscape or portrait) recursively."
	exit 1
}

organize_photos() {
	local dir="$1"

	if [[ ! -d "$dir" ]]; then
		echo "Error: '$dir' is not a valid directory."
		exit 1
	fi

	mkdir -p "$dir/landscape" || {
		echo "Error: Could not create '$dir/landscape'."
		exit 1
	}
	mkdir -p "$dir/portrait" || {
		echo "Error: Could not create '$dir/portrait'."
		exit 1
	}

	# Find and process all image files
	find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r file; do
		# Use identify to get image dimensions (requires ImageMagick)
		dimensions=$(identify -format "%w %h" "$file" 2>/dev/null)

		if [[ -z "$dimensions" ]]; then
			echo "Error: Could not process file '$file'."
			continue
		fi

		read -r width height <<<"$dimensions"

		if [[ "$width" -ge "$height" ]]; then
			target_dir="$dir/landscape"
		else
			target_dir="$dir/portrait"
		fi

		if ! mv "$file" "$target_dir/" 2>/dev/null; then
			echo "Error: Could not move file '$file' to '$target_dir'."
		else
			echo "Moved '$file' to '$target_dir'."
		fi
	done
}

if [[ -n "$1" ]]; then
	target_dir="$1"
else
	read -r -p "Enter the directory to organize photos: " target_dir
fi

organize_photos "$target_dir"
