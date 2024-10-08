#!/bin/sh

usage() {
	echo "Usage: $0 <find_pattern> <replace_pattern> [directory]"
	echo "Renames files in bulk using find and replace."
	echo "  find_pattern:    Pattern to search for in filenames."
	echo "  replace_pattern: Pattern to replace the found pattern with."
	echo "  directory:       Directory to search in (default: current directory)."
	exit 1
}

if [ $# -lt 2 ]; then
	usage
fi

find_pattern="$1"
replace_pattern="$2"
directory="${3:-.}"

if [ ! -d "$directory" ]; then
	echo "Error: '$directory' is not a valid directory."
	exit 1
fi

find "$directory" -depth -name "*$find_pattern*" -exec sh -c '
  for file_path do
    new_name=$(echo "$file_path" | sed "s/$1/$2/g")
    if [ "$file_path" != "$new_name" ]; then
      echo "Renaming \"$file_path\" to \"$new_name\""
      mv "$file_path" "$new_name" || echo "Failed to rename \"$file_path\""
    fi
  done
' sh {} + "$find_pattern" "$replace_pattern"
