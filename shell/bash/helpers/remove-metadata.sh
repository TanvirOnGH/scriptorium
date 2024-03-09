#!/bin/bash

remove_image_metadata() {
    for file in "$1"/*.{jpg,jpeg,png,gif,bmp,tiff,tif,webp}; do
        if [ -f "$file" ]; then
            echo "Removing metadata from: $file"
            exiftool -all= "$file"
        fi
    done
}

remove_video_metadata() {
    for file in "$1"/*.{mp4,mkv,avi,mov,wmv,flv}; do
        if [ -f "$file" ]; then
            echo "Removing metadata from: $file"
            ffmpeg -i "$file" -map_metadata -1 -c:v copy -c:a copy "${file%.*}_no_metadata.${file##*.}"
        fi
    done
}

remove_audio_metadata() {
    for file in "$1"/*.{mp3,flac,wav,ogg,m4a}; do
        if [ -f "$file" ]; then
            echo "Removing metadata from: $file"
            sox "$file" "${file%.*}_no_metadata.${file##*.}" trim 0 999999999
        fi
    done
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Error: Directory not found."
    exit 1
fi

echo "Removing metadata from files in directory: $1"

remove_image_metadata "$1"
remove_video_metadata "$1"
remove_audio_metadata "$1"

echo "Metadata removal complete."
