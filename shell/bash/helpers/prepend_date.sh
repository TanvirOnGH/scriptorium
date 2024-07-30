#!/bin/sh

prepend_date() {
	date_prefix=$(date +%Y-%m-%d)
	for file in "$1"/*; do
		[ -e "$file" ] || continue # skip if no file exists

		if [ -d "$file" ]; then
			# Recursively process directories
			prepend_date "$file"
		else
			# Prepend date to filename
			dir=$(dirname "$file")
			filename=$(basename "$file")
			new_filename="${date_prefix}_$filename"

			if [ "$filename" != "$new_filename" ]; then
				echo "Rename '$filename' to '$new_filename'? [y/N]"
				read -r answer
				if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
					mv "$file" "$dir/$new_filename"
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

prepend_date "$dir"
