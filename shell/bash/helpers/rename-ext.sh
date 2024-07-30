#!/bin/sh

usage() {
	echo "Usage: $0 oldext newext [directory]"
	echo "Example: $0 md txt /path/to/directory"
	exit 1
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
	usage
fi

oldext="$1"
newext="$2"
directory="${3:-.}"

if [ ! -d "$directory" ]; then
	echo "Directory $directory does not exist."
	exit 1
fi

# Find files with the old extension
files=$(find "$directory" -maxdepth 1 -type f -name "*.$oldext")

if [ -z "$files" ]; then
	echo "No files with the extension .$oldext found in $directory."
	exit 1
fi

echo "The following files will be renamed:"
for file in $files; do
	echo "$file -> ${file%."$oldext"}.$newext"
done

echo ""

echo "Do you want to proceed? (y/n)"
read -r answer

if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
	echo "Operation cancelled."
	exit 1
else
	echo ""
fi

for file in $files; do
	newfile="${file%."$oldext"}.$newext"
	if mv -- "$file" "$newfile"; then
		echo "Renamed: $file -> $newfile"
	else
		echo "Error renaming $file"
	fi
done
