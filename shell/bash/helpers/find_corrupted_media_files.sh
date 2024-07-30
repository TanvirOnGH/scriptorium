#!/bin/sh
# shellcheck disable=SC3045

# Dependencies: imagemagick, ffmpeg

show_help() {
	echo "Usage: $0 [-d directory] [-i image_exts] [-a audio_exts] [-v video_exts]"
	echo ""
	echo "Options:"
	echo "  -d  Directory to search (default: \$HOME)"
	echo "  -i  Image file extensions (default: jpg jpeg png gif bmp tiff tif webp heic heif)"
	echo "  -a  Audio file extensions (default: mp3 wav flac aac ogg wma m4a alac aiff)"
	echo "  -v  Video file extensions (default: mp4 avi mkv mov flv wmv webm mpg mpeg m4v)"
	echo "  -h  Show this help message and exit"
}

check_image() {
	file="$1"
	if ! identify "$file" >/dev/null 2>&1; then
		echo "Corrupted image file: $file"
	fi
}

check_audio() {
	file="$1"
	if ! ffmpeg -v error -i "$file" -f null - >/dev/null 2>&1; then
		echo "Corrupted audio file: $file"
	fi
}

check_video() {
	file="$1"
	if ! ffmpeg -v error -i "$file" -f null - >/dev/null 2>&1; then
		echo "Corrupted video file: $file"
	fi
}

# Default values
DIR="$HOME"
IMAGE_EXTS="jpg jpeg png gif bmp tiff tif webp heic heif"
AUDIO_EXTS="mp3 wav flac aac ogg wma m4a alac aiff"
VIDEO_EXTS="mp4 avi mkv mov flv wmv webm mpg mpeg m4v"

while getopts "d:i:a:v:h" opt; do
	case $opt in
	d) DIR="$OPTARG" ;;
	i) IMAGE_EXTS="$OPTARG" ;;
	a) AUDIO_EXTS="$OPTARG" ;;
	v) VIDEO_EXTS="$OPTARG" ;;
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

if [ -z "$DIR" ]; then
	read -r -p "Enter the directory to search: " DIR
fi

if [ -z "$IMAGE_EXTS" ]; then
	read -r -p "Enter image file extensions (space-separated): " IMAGE_EXTS
fi

if [ -z "$AUDIO_EXTS" ]; then
	read -r -p "Enter audio file extensions (space-separated): " AUDIO_EXTS
fi

if [ -z "$VIDEO_EXTS" ]; then
	read -r -p "Enter video file extensions (space-separated): " VIDEO_EXTS
fi

for ext in $IMAGE_EXTS; do
	find "$DIR" -type f -iname "*.$ext" -print0 | while IFS= read -r -d '' file; do
		check_image "$file"
	done
done

for ext in $AUDIO_EXTS; do
	find "$DIR" -type f -iname "*.$ext" -print0 | while IFS= read -r -d '' file; do
		check_audio "$file"
	done
done

for ext in $VIDEO_EXTS; do
	find "$DIR" -type f -iname "*.$ext" -print0 | while IFS= read -r -d '' file; do
		check_video "$file"
	done
done
