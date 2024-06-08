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

shopt -s nullglob
files=("$directory"/*."$oldext")
shopt -u nullglob

if [ "${#files[@]}" -eq 0 ]; then
  echo "No files with the extension .$oldext found in $directory."
  exit 1
fi

echo "The following files will be renamed:"
for file in "${files[@]}"; do
  echo "$file -> ${file%.$oldext}.$newext"
done

echo ""

read -p "Do you want to proceed? (y/n) " answer
if [[ ! $answer =~ ^[Yy]$ ]]; then
  echo "Operation cancelled."
  exit 1
else
  echo ""
fi

for file in "${files[@]}"; do
  newfile="${file%.$oldext}.$newext"
  if mv -- "$file" "$newfile"; then
    echo "Renamed: $file -> $newfile"
  else
    echo "Error renaming $file"
  fi
done
