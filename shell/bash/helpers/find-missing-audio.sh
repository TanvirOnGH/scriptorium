#!/bin/sh

usage() {
	echo "Usage: $0 directory [--delete | --move target_directory]"
	echo "Find video files missing audio in the specified directory."
	echo "Options:"
	echo "  --delete: Delete video files missing audio."
	echo "  --move target_directory: Move video files missing audio to the specified directory."
}

has_audio() {
	file="$1"
	# Use ffprobe to check if the file has an audio stream
	if ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of default=noprint_wrappers=1:nokey=1 "$file" | grep -q '^audio$'; then
		return 0
	else
		return 1
	fi
}

if [ "$#" -lt 1 ]; then
	usage
	exit 1
fi

directory="$1"
action="$2"
target_directory="$3"

if [ ! -d "$directory" ]; then
	echo "Error: '$directory' is not a valid directory."
	exit 1
fi

if [ "$action" = "--move" ]; then
	if [ -z "$target_directory" ]; then
		echo "Error: Target directory must be specified with --move."
		usage
		exit 1
	fi

	if [ ! -d "$target_directory" ]; then
		echo "Creating target directory: $target_directory"
		mkdir -p "$target_directory" || {
			echo "Failed to create target directory: $target_directory"
			exit 1
		}
	fi
fi

missing_audio_files=0
for file in "$directory"/*; do
	if [ -f "$file" ]; then
		# Get the file extension
		ext="${file##*.}"
		case "$ext" in
		mp4 | mkv | avi | mov | flv | webm | mpg | mpeg | wmv)
			if ! has_audio "$file"; then
				case "$action" in
				--delete)
					echo "Deleting file with missing audio: $file"
					rm "$file" || { echo "Failed to delete $file"; }
					;;
				--move)
					echo "Moving file with missing audio: $file"
					mv "$file" "$target_directory/" || { echo "Failed to move $file"; }
					;;
				*)
					echo "Missing audio: $file"
					;;
				esac
				missing_audio_files=$((missing_audio_files + 1))
			fi
			;;
		*)
			# Skip non-video files
			;;
		esac
	fi
done

if [ $missing_audio_files -eq 0 ]; then
	echo "All video files have audio."
else
	case "$action" in
	--delete)
		echo "$missing_audio_files video files were deleted."
		;;
	--move)
		echo "$missing_audio_files video files were moved to $target_directory."
		;;
	*)
		echo "$missing_audio_files video files are missing audio."
		;;
	esac
fi
