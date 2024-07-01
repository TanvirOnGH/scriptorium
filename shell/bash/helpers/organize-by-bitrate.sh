#!/bin/bash

usage() {
	echo "Usage: $0 [directory] [type]"
	echo "Organizes video files by bitrate into different categories."
	echo "Type options: video. If not provided, checks video files."
	exit 1
}

create_directories() {
	local dir="$1"
	mkdir -p "$dir/low" || {
		echo "Error: Could not create '$dir/low'."
		exit 1
	}
	mkdir -p "$dir/medium" || {
		echo "Error: Could not create '$dir/medium'."
		exit 1
	}
	mkdir -p "$dir/high" || {
		echo "Error: Could not create '$dir/high'."
		exit 1
	}
	mkdir -p "$dir/very-high" || {
		echo "Error: Could not create '$dir/very-high'."
		exit 1
	}
}

organize_by_bitrate() {
	local dir="$1"

	if [[ ! -d "$dir" ]]; then
		echo "Error: '$dir' is not a valid directory."
		exit 1
	fi

	create_directories "$dir"

	# Define file patterns and command for getting bitrate
	local patterns=("*.mp4" "*.mkv" "*.avi" "*.mov" "*.flv" "*.wmv" "*.webm" "*.mpg" "*.mpeg")
	local get_bitrate_cmd=("ffprobe" "-v" "error" "-select_streams" "v:0" "-show_entries" "stream=bit_rate" "-of" "default=noprint_wrappers=1:nokey=1")

	# Build find command dynamically with quoted patterns
	local find_command=("find" "$dir" "-type" "f")
	for pattern in "${patterns[@]}"; do
		find_command+=("-iname" "$pattern")
	done
	find_command+=("-false")

	# Execute find command and process files
	"${find_command[@]}" | while IFS= read -r file; do
		# Get file bitrate
		local bitrate
		bitrate=$("${get_bitrate_cmd[@]}" "$file" 2>/dev/null)

		if [[ $? -ne 0 || -z "$bitrate" ]]; then
			echo "Error: Could not get bitrate for file '$file'."
			continue
		fi

		# Convert bitrate from bps to kbps
		local bitrate_kbps=$((bitrate / 1000))

		# Define bitrate categories in kbps
		local low_bitrate_limit=500
		local medium_bitrate_limit=2000
		local high_bitrate_limit=5000

		if [[ "$bitrate_kbps" -le "$low_bitrate_limit" ]]; then
			target_dir="$dir/low"
		elif [[ "$bitrate_kbps" -le "$medium_bitrate_limit" ]]; then
			target_dir="$dir/medium"
		elif [[ "$bitrate_kbps" -le "$high_bitrate_limit" ]]; then
			target_dir="$dir/high"
		else
			target_dir="$dir/very-high"
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

organize_by_bitrate "$target_dir"
