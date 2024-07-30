#!/bin/sh
# shellcheck disable=SC3045

# Dependencies: ffmpeg

show_help() {
	echo "Usage: $0 [-i input_video] [-o output_folder] [-r frame_rate]"
	echo ""
	echo "Options:"
	echo "  -i  Input video file (required)"
	echo "  -o  Output folder for extracted frames (required)"
	echo "  -r  Frame rate (default: 1 frame per second)"
	echo "  -h  Show this help message and exit"
}

# Default values
INPUT_VIDEO=""
OUTPUT_FOLDER=""
FRAME_RATE=1

while getopts "i:o:r:h" opt; do
	case $opt in
	i) INPUT_VIDEO="$OPTARG" ;;
	o) OUTPUT_FOLDER="$OPTARG" ;;
	r) FRAME_RATE="$OPTARG" ;;
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

if [ -z "$INPUT_VIDEO" ]; then
	read -r -p "Enter the input video file: " INPUT_VIDEO
fi

if [ -z "$OUTPUT_FOLDER" ]; then
	read -r -p "Enter the output folder for extracted frames: " OUTPUT_FOLDER
fi

if [ -z "$FRAME_RATE" ]; then
	read -r -p "Enter the frame rate (frames per second): " FRAME_RATE
fi

mkdir -p "$OUTPUT_FOLDER"

# Extract frames
ffmpeg -i "$INPUT_VIDEO" -vf "fps=$FRAME_RATE" "$OUTPUT_FOLDER/frame_%04d.png"

echo "Frames extracted to $OUTPUT_FOLDER"
