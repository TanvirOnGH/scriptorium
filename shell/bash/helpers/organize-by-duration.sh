#!/bin/bash

usage() {
	echo "Usage: $0 [directory]"
	echo "Organizes media files by duration into different categories."
	exit 1
}

create_directories() {
	local dir="$1"
	mkdir -p "$dir/short" || {
		echo "Error: Could not create '$dir/short'."
		exit 1
	}
	mkdir -p "$dir/medium" || {
		echo "Error: Could not create '$dir/medium'."
		exit 1
	}
	mkdir -p "$dir/long" || {
		echo "Error: Could not create '$dir/long'."
		exit 1
	}
}

convert_duration_to_minutes() {
	local duration="$1"
	local duration_minutes
	duration_minutes=$(awk "BEGIN {print int($duration / 60)}")
	echo "$duration_minutes"
}

organize_by_duration() {
	local dir="$1"

	if [[ ! -d "$dir" ]]; then
		echo "Error: '$dir' is not a valid directory."
		exit 1
	fi

	create_directories "$dir"

	# Define file patterns and command for getting duration
	local patterns=("*.mp4" "*.mkv" "*.avi" "*.mov" "*.flv" "*.wmv" "*.webm" "*.mpg" "*.mpeg" "*.mp3" "*.wav")
	local get_duration_cmd=("ffprobe" "-v" "error" "-select_streams" "a:0" "-show_entries" "stream=duration" "-of" "default=noprint_wrappers=1:nokey=1")

	# Build find command dynamically with quoted patterns
	local find_command=("find" "$dir" "-type" "f")
	for pattern in "${patterns[@]}"; do
		find_command+=("-iname" "$pattern")
	done
	find_command+=("-false")

	# Execute find command and process files
	"${find_command[@]}" | while IFS= read -r file; do
		# Get file duration
		local duration
		duration=$("${get_duration_cmd[@]}" "$file" 2>/dev/null)

		if [[ $? -ne 0 || -z "$duration" ]]; then
			echo "Error: Could not get duration for file '$file'."
			continue
		fi

		# Convert duration to minutes
		local duration_minutes
		duration_minutes=$(convert_duration_to_minutes "$duration")

		# Define duration categories in minutes
		local short_duration_limit=5
		local long_duration_limit=30

		if [[ "$duration_minutes" -le "$short_duration_limit" ]]; then
			target_dir="$dir/short"
		elif [[ "$duration_minutes" -le "$long_duration_limit" ]]; then
			target_dir="$dir/medium"
		else
			target_dir="$dir/long"
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

organize_by_duration "$target_dir"
