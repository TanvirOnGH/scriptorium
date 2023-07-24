#!/bin/sh
# shellcheck disable=SC3045,SC3043

: '
Script to rename all files in the directory specified as the first argument with a random UUID.
If the directory is not specified or does not exist, an error message is displayed, and the script exits.
If there are no files to rename, a message is printed, and the script exits.
Before renaming, the script displays a list of files that will be renamed and prompts the user for confirmation.
If the user confirms, the script renames all files in the directory with a random UUID.
If a file cannot be renamed, an error message is displayed.
N.B: It ignores the script itself and directories.
'

warn="1"

warning() {
  printf "%s\n\n" "WARNING: Doesn't work if the filenames contain spaces." >&2
}

print_usage() {
  printf "%s\n" "Usage: $0 DIRECTORY" >&2
}

check_directory() {
  if [ ! -d "$1" ]; then
    printf "%s\n" "$1: No such directory" >&2
    exit 1
  fi
}

generate_new_names() {
  files_to_rename=$(ls -p | grep -v / | grep -v "${0##*/}")
  if [ -z "$files_to_rename" ]; then
    printf "%s\n" "No files to rename in '$1'" >&2
    exit 0
  fi

  printf "%s\n\n" "The following files in '$1' will be renamed:"
  local i=0
  for file in $files_to_rename; do
    local new_name="$(uuidgen)"
    if printf "%s\n" "$file" | grep -Eq '\.[^.]+$'; then
      new_name="$new_name.${file##*.}"
    fi
    printf "%s\n" "    $file -> $new_name"
    new_names[$i]=$new_name
    i=$((i+1))
  done
}

confirm_renaming() {
  read -r -p "Do you want to continue with renaming the files? (y/n) " response
  if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    exit 0
  fi
}

rename_files() {
  local i=0
  for file in $files_to_rename; do
    local new_name="${new_names[$i]}"
    i=$((i+1))

    if mv "$file" "$new_name"; then
      printf "%s\n" "Renamed: $file -> $new_name"
    else
      printf "%s\n" "Error could not rename: $file -> $new_name" >&2
    fi
  done
}

main() {
  if [ "$warn" = "1" ]; then
    warning
  fi

  local dir="$1"

  if [ -z "$dir" ]; then
    print_usage
    exit 1
  fi

  check_directory "$dir"
  cd "$dir" || exit 1

  generate_new_names "$dir"
  printf "%s\n" ""
  confirm_renaming
  printf "%s\n" ""
  rename_files
}

main "$1"
