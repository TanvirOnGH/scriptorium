#!/bin/bash

usage() {
	echo "Usage: $0 [directory] [type]"
	echo "Organizes images and videos by dimensions into different categories."
	echo "Type options: image, video. If not provided, checks both."
	exit 1
}

create_directories() {
	local dir="$1"
	mkdir -p "$dir/extra-small" || {
		echo "Error: Could not create '$dir/extra-small'."
		exit 1
	}
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
	mkdir -p "$dir/extra-large" || {
		echo "Error: Could not create '$dir/extra-large'."
		exit 1
	}
}

organize_by_dimensions() {
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
		local patterns=("*.jpg" "*.jpeg" "*.png")
		local get_dimensions_cmd=("identify" "-format" "%w %h")
		;;
	video)
		local patterns=("*.mp4" "*.mkv" "*.avi")
		local get_dimensions_cmd=("ffprobe" "-v" "error" "-select_streams" "v:0" "-show_entries" "stream=width,height" "-of" "csv=p=0")
		;;
	*)
		local patterns=("*.jpg" "*.jpeg" "*.png" "*.mp4" "*.mkv" "*.avi")
		local get_dimensions_cmd=("identify" "-format" "%w %h")
		;;
	esac

	# Build find command dynamically with quoted patterns
	local find_command=("find" "$dir" "-type" "f")
	for pattern in "${patterns[@]}"; do
		find_command+=("-iname" "$pattern")
	done
	find_command+=("-false")

	# Execute find command and process files
	"${find_command[@]}" | while IFS= read -r file; do
		# Get file dimensions
		local dimensions
		dimensions=$("${get_dimensions_cmd[@]}" "$file" 2>/dev/null)

		if [[ $? -ne 0 || -z "$dimensions" ]]; then
			echo "Error: Could not get dimensions for file '$file'."
			continue
		fi

		read -r width height <<<"$(echo "$dimensions" | tr ' ' '\n')"

		# Define dimension categories
		local extra_small_width_limit=640
		local extra_small_height_limit=360
		local small_width_limit=1280
		local small_height_limit=720
		local medium_width_limit=1920
		local medium_height_limit=1080
		local large_width_limit=2560
		local large_height_limit=1440

		if [[ "$width" -le "$extra_small_width_limit" && "$height" -le "$extra_small_height_limit" ]]; then
			target_dir="$dir/extra-small"
		elif [[ "$width" -le "$small_width_limit" && "$height" -le "$small_height_limit" ]]; then
			target_dir="$dir/small"
		elif [[ "$width" -le "$medium_width_limit" && "$height" -le "$medium_height_limit" ]]; then
			target_dir="$dir/medium"
		elif [[ "$width" -le "$large_width_limit" && "$height" -le "$large_height_limit" ]]; then
			target_dir="$dir/large"
		else
			target_dir="$dir/extra-large"
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

organize_by_dimensions "$target_dir" "$file_type"
