#!/bin/sh

convert_to_lowercase() {
	for file in "$1"/*; do
		[ -e "$file" ] || continue # skip if no file exists

		if [ -d "$file" ]; then
			# Recursively process directories
			convert_to_lowercase "$file"
		else
			# Convert filename to lowercase
			dir=$(dirname "$file")
			filename=$(basename "$file")
			lowercase_filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')

			if [ "$filename" != "$lowercase_filename" ]; then
				echo "Rename '$filename' to '$lowercase_filename'? [y/N]"
				read -r answer
				if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
					mv "$file" "$dir/$lowercase_filename"
				fi
			fi
		fi
	done
}

if [ -z "$1" ]; then
	echo "No directory path provided. Use current directory? [y/N]"
	read -r use_current_dir

	if [ "$use_current_dir" = "y" ] || [ "$use_current_dir" = "Y" ]; then
		dir="."
	else
		echo "Please provide the directory path:"
		read -r dir
	fi
else
	dir="$1"
fi

if [ ! -d "$dir" ]; then
	echo "The provided path is not a directory."
	exit 1
fi

convert_to_lowercase "$dir"
