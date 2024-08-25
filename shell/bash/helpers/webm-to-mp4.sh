#!/bin/sh

for file in *.webm; do
	[ -e "$file" ] || continue

	# Remove the .webm extension and add .mp4
	output="${file%.webm}.mp4"

	ffmpeg -i "$file" -c:v libx264 -c:a aac "$output"

	# Optional: Uncomment the next line if you want to delete the original .webm file after conversion
	# rm "$file"

	echo "Converted: $file -> $output"
done
