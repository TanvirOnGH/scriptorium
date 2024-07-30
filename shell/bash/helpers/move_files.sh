#!/bin/sh

show_help() {
	echo "Usage: $0 [-s source_dir] [-d dest_dir] [-t file_type] [-e extensions]"
	echo ""
	echo "Options:"
	echo "  -s  Source directory (default: current directory)"
	echo "  -d  Destination directory (required)"
	echo "  -t  File type (video, audio, photo)"
	echo "  -e  File extensions (space-separated, overrides file type)"
	echo "  -h  Show this help message and exit"
}

move_files() {
	src_dir="$1"
	dest_dir="$2"
	exts="$3"

	mkdir -p "$dest_dir"

	for ext in $exts; do
		find "$src_dir" -type f -iname "*.$ext" -exec mv {} "$dest_dir" \;
	done
}

# Default values
SRC_DIR="."
DEST_DIR=""
FILE_TYPE=""
EXTS=""

while getopts "s:d:t:e:h" opt; do
	case $opt in
	s) SRC_DIR="$OPTARG" ;;
	d) DEST_DIR="$OPTARG" ;;
	t) FILE_TYPE="$OPTARG" ;;
	e) EXTS="$OPTARG" ;;
	h)
		show_help
		exit 0
		;;
	*)
		show_help
		exit 1
		;;
	esac
done

if [ -z "$DEST_DIR" ]; then
	read -p "Enter the destination directory: " DEST_DIR
fi

if [ -z "$FILE_TYPE" ] && [ -z "$EXTS" ]; then
	read -p "Enter the file type (video, audio, photo) or file extensions (space-separated): " input
	case $input in
	video) FILE_TYPE="video" ;;
	audio) FILE_TYPE="audio" ;;
	photo) FILE_TYPE="photo" ;;
	*) EXTS="$input" ;;
	esac
fi

case $FILE_TYPE in
video) EXTS="mp4 avi mkv mov flv wmv webm mpg mpeg m4v" ;;
audio) EXTS="mp3 wav flac aac ogg wma m4a alac aiff" ;;
photo) EXTS="jpg jpeg png gif bmp tiff tif webp heic heif" ;;
esac

if [ -n "$EXTS" ]; then
	move_files "$SRC_DIR" "$DEST_DIR" "$EXTS"
else
	echo "Error: No file extensions or file type provided."
	show_help
	exit 1
fi
