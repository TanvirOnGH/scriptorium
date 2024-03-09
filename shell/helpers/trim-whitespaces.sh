#!/bin/sh
# shellcheck disable=SC3045,SC3043

: '
Script to remove whitespace from all filenames in the directory specified.
'

print_usage() {
    printf "%s\n" "Usage: $0 DIRECTORY" >&2
}

check_directory() {
    if [ ! -d "$1" ]; then
        printf "%s\n" "$1: No such directory" >&2
        exit 1
    fi
}

confirm_trimming() {
    read -r -p "Do you want to continue with trimming of whitespaces from the filenames? (y/n) " response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        exit 0
    fi
}

main() {
    dir="$1"

    if [ -z "$dir" ]; then
        print_usage
        exit 1
    fi

    check_directory "$dir"
    confirm_trimming

    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            new_file=$(echo "$file" | tr -d '[:space:]')
            mv "$file" "$new_file"
        fi
    done

    printf "%s\n" "Whitespace removed from all files in $dir"
}

main "$1"
