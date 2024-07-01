#!/bin/bash

usage() {
	echo "Usage: $0 [directory]"
	echo "Organizes files by their type into different directories."
	exit 1
}

create_directories() {
	local dir="$1"
	mkdir -p "$dir/images" || {
		echo "Error: Could not create '$dir/images'."
		exit 1
	}
	mkdir -p "$dir/videos" || {
		echo "Error: Could not create '$dir/videos'."
		exit 1
	}
	mkdir -p "$dir/documents" || {
		echo "Error: Could not create '$dir/documents'."
		exit 1
	}
	mkdir -p "$dir/audio" || {
		echo "Error: Could not create '$dir/audio'."
		exit 1
	}
	mkdir -p "$dir/archives" || {
		echo "Error: Could not create '$dir/archives'."
		exit 1
	}
}

organize_by_type() {
	local dir="$1"

	if [[ ! -d "$dir" ]]; then
		echo "Error: '$dir' is not a valid directory."
		exit 1
	fi

	create_directories "$dir"

	# Define file patterns and their target directories
	declare -A file_patterns=(
		["images"]="*.jpg *.jpeg *.png *.gif *.bmp *.tiff *.webp *.raw *.heif"
		["videos"]="*.mp4 *.mkv *.avi *.mov *.flv *.wmv *.webm *.mpg *.mpeg *.ts *.3gp *.rm *.rmvb *.mov *.swf"
		["audio"]="*.mp3 *.wav *.flac *.aac *.ogg *.m4a *.opus *.wma *.aiff *.alac"
		["documents"]="*.pdf *.doc *.docx *.xls *.xlsx *.ppt *.pptx *.odt *.rtf *.tex *.md *.epub *.mobi"
		["archives"]="*.zip *.tar *.gz *.rar *.7z *.bz2 *.xz *.tar.gz *.tar.bz2 *.tar.xz"
	)

	for category in "${!file_patterns[@]}"; do
		local patterns=${file_patterns[$category]}
		local target_dir="$dir/$category"

		# Move files to their respective category directories
		for pattern in $patterns; do
			find "$dir" -maxdepth 1 -type f -name "$pattern" -print0 | while IFS= read -r -d '' file; do
				if ! mv "$file" "$target_dir/" 2>/dev/null; then
					echo "Error: Could not move file '$file' to '$target_dir'."
				else
					echo "Moved '$file' to '$target_dir'."
				fi
			done
		done
	done
}

if [[ -n "$1" ]]; then
	target_dir="$1"
else
	read -r -p "Enter the directory to organize files: " target_dir
fi

organize_by_type "$target_dir"
