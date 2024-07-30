#!/bin/bash

VIDEO_EXTENSIONS="*.mp4 *.mkv *.avi *.mov *.wmv *.flv *.webm *.mpg *.mpeg *.3gp"
AUDIO_EXTENSIONS="*.mp3 *.wav *.flac *.aac *.ogg *.m4a *.wma *.opus"
IMAGE_EXTENSIONS="*.jpg *.jpeg *.png *.gif *.bmp *.tiff *.webp *.raw"

usage() {
	echo "Usage: $0 directory [--delete | --move target_directory] [--type video | audio | image]"
	echo "Find corrupted files in the specified directory."
	echo "Options:"
	echo "  --delete: Delete corrupted files."
	echo "  --move target_directory: Move corrupted files to the specified directory."
	echo "  --type type: Find corrupted files of a specific type (video, audio, image)."
	echo "  If --type is not specified, all types are checked."
	exit 1
}

check_directory() {
	if [ ! -d "$1" ]; then
		echo "Error: The specified directory '$1' does not exist."
		exit 1
	fi
}

find_corrupted_files() {
	dir="$1"
	type="$2"
	corrupted_files=""

	case "$type" in
	video)
		extensions="$VIDEO_EXTENSIONS"
		command_check="ffprobe"
		;;
	audio)
		extensions="$AUDIO_EXTENSIONS"
		command_check="ffprobe"
		;;
	image)
		extensions="$IMAGE_EXTENSIONS"
		command_check="identify"
		;;
	*)
		extensions="$VIDEO_EXTENSIONS $AUDIO_EXTENSIONS $IMAGE_EXTENSIONS"
		command_check="ffprobe identify"
		;;
	esac

	# Construct the find command arguments
	find_args=""
	for ext in $extensions; do
		find_args="$find_args -name $ext -o"
	done
	find_args="${find_args% -o}" # Remove trailing ' -o'

	# Use a temporary file to store results
	temp_file=$(mktemp)
	find "$dir" -type f \( "$find_args" \) -print0 |
		while IFS= read -r -d '' file; do
			if [ "$command_check" = "ffprobe" ]; then
				if ! ffprobe "$file" >/dev/null 2>&1; then
					echo "$file" >>"$temp_file"
				fi
			elif [ "$command_check" = "identify" ]; then
				if ! identify "$file" >/dev/null 2>&1; then
					echo "$file" >>"$temp_file"
				fi
			else
				if ! (ffprobe "$file" >/dev/null 2>&1 || identify "$file" >/dev/null 2>&1); then
					echo "$file" >>"$temp_file"
				fi
			fi
		done

	corrupted_files=$(<"$temp_file")
	rm -f "$temp_file"

	echo "$corrupted_files"
}

delete_files() {
	# handle filenames with special characters
	printf "%s\n" "$@" | xargs -d '\n' rm -f
}

move_files() {
	target_dir="$1"
	shift
	# handle filenames with special characters
	printf "%s\n" "$@" | xargs -d '\n' -I {} mv {} "$target_dir"
}

if [ $# -lt 1 ]; then
	usage
fi

directory="$1"
action=""
target_directory=""
type=""

shift

while [ $# -gt 0 ]; do
	case "$1" in
	--delete)
		action="delete"
		;;
	--move)
		action="move"
		if [ -z "$2" ] || [ ! -d "$2" ]; then
			echo "Error: Target directory for move is not specified or does not exist."
			usage
		fi
		target_directory="$2"
		shift
		;;
	--type)
		if [ "$2" = "video" ] || [ "$2" = "audio" ] || [ "$2" = "image" ]; then
			type="$2"
		else
			echo "Error: Invalid type specified. Must be video, audio, or image."
			usage
		fi
		shift
		;;
	*)
		echo "Error: Invalid option '$1'."
		usage
		;;
	esac
	shift
done

check_directory "$directory"

# Find corrupted files and handle them as a list
corrupted_files=$(find_corrupted_files "$directory" "$type")

if [ -z "$corrupted_files" ]; then
	echo "No corrupted files found."
	exit 0
fi

echo "Found corrupted files:"
printf "%s\n" "$corrupted_files"

case "$action" in
delete)
	delete_files "$corrupted_files"
	;;
move)
	move_files "$target_directory" "$corrupted_files"
	;;
*)
	echo "Error: No action specified. Use --delete or --move."
	exit 1
	;;
esac
