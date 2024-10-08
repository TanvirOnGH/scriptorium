#!/bin/sh

find_large_files() {
	directory="$1"
	size_threshold="$2"

	if [ -z "$directory" ]; then
		echo "Usage: $0 <directory> <size_in_MB>"
		return 1
	fi

	if [ ! -d "$directory" ]; then
		echo "Error: '$directory' is not a valid directory."
		return 1
	fi

	if [ -z "$size_threshold" ]; then
		size_threshold=100
	fi

	find "$directory" -type f -size +"$size_threshold"M -printf "%s %p\n" | sort -nr | awk '{size=$1/(1024*1024); print size" MB " $2}'
}

if [ "$#" -eq 2 ]; then
	directory="$1"
	size_threshold="$2"
	find_large_files "$directory" "$size_threshold"
elif [ "$#" -eq 1 ]; then
	directory="$1"
	find_large_files "$directory"
else
	echo "Usage: $0 <directory> [<size_in_MB>]"
fi
