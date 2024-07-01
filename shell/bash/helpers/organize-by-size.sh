#!/bin/bash

usage() {
	echo "Usage: $0 [directory] [type]"
	echo "Organizes files by size into different size categories."
	echo "Type options: image, video, audio. If not provided, checks all types."
	exit 1
}

create_directories() {
	local dir="$1"
	mkdir -p "$dir/small" || {
		echo "Error: Could not create '$dir/small'."
		exit 1
	}
	mkdir -p "$dir/medium" || {
		echo "Error: Could not create '$dir/medium'."
		exit 1
	}
	mkdir -p "$dir/large" || {
		echo "Error: Could not create '$dir/large'."
		exit 1
	}
}

organize_by_size() {
	local dir="$1"
	local file_type="$2"

	if [[ ! -d "$dir" ]]; then
		echo "Error: '$dir' is not a valid directory."
		exit 1
	fi

	create_directories "$dir"

	# Define file patterns based on type
	case "$file_type" in
	image)
		patterns="*.jpg *.jpeg *.png"
		;;
	video)
		patterns="*.mp4 *.mkv *.avi"
		;;
	audio)
		patterns="*.mp3 *.wav *.flac"
		;;
	*)
		patterns="*.jpg *.jpeg *.png *.mp4 *.mkv *.avi *.mp3 *.wav *.flac"
		;;
	esac

	# Build find command dynamically with quoted patterns
	find_command="find \"$dir\" -type f \\( $(printf -- '-iname \"%s\" -o ' "${patterns}") -false \\)"

	eval "$find_command" | while read -r file; do
		# Get file size in bytes
		filesize=$(stat -c %s "$file" 2>/dev/null)

		if [[ -z "$filesize" ]]; then
			echo "Error: Could not get size for file '$file'."
			continue
		fi

		# Define size categories in bytes
		small_limit=$((10 * 1024 * 1024))   # 10 MB
		medium_limit=$((100 * 1024 * 1024)) # 100 MB

		if [[ "$filesize" -le "$small_limit" ]]; then
			target_dir="$dir/small"
		elif [[ "$filesize" -le "$medium_limit" ]]; then
			target_dir="$dir/medium"
		else
			target_dir="$dir/large"
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
	read -r -p "Enter the directory to organize files: " target_dir
fi

file_type="${2,,}" # Convert to lowercase

organize_by_size "$target_dir" "$file_type"
