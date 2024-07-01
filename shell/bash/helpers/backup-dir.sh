#!/bin/sh

backup_directory() {
	src_dir="$1"
	dest_dir="$2"
	timestamp=$(date +"%Y%m%d_%H%M%S")
	backup_file="$dest_dir/backup_$timestamp.tar.gz"

	if [ ! -d "$src_dir" ]; then
		echo "Error: Source directory '$src_dir' does not exist."
		exit 1
	fi

	mkdir -p "$dest_dir"

	tar -czf "$backup_file" -C "$src_dir" .

	echo "Backup of '$src_dir' completed successfully. Backup file: $backup_file"
}

if [ $# -ne 2 ]; then
	echo "Usage: $0 <source_directory> <destination_directory>"
	exit 1
fi

backup_directory "$1" "$2"
