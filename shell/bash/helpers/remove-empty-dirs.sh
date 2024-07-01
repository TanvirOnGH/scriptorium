#!/bin/sh

usage() {
	echo "Usage: $0 [path]"
	echo "If no path is provided, you will be prompted to enter one."
}

confirm_deletion() {
	echo "The following empty directories will be deleted:"
	echo "$1"
	echo "Do you want to proceed? (y/n): \c"
	read -r confirmation
	case "$confirmation" in
	y | Y) ;;
	*)
		echo "Aborting deletion."
		exit 1
		;;
	esac
}

if [ "$#" -gt 1 ]; then
	usage
	exit 1
fi

path="$1"

if [ -z "$path" ]; then
	echo "Enter the path to search for empty directories: \c"
	read -r path
fi

if [ ! -d "$path" ]; then
	echo "Error: '$path' is not a valid directory."
	exit 1
fi

empty_dirs=$(find "$path" -type d -empty)

if [ -z "$empty_dirs" ]; then
	echo "No empty directories found."
else
	confirm_deletion "$empty_dirs"
	echo "$empty_dirs" | xargs rmdir
	echo "Empty directories deleted."
fi
