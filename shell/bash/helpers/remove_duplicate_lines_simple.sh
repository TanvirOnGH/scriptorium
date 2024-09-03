#!/bin/sh

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <file>"
	exit 1
fi

# Read the file and remove duplicates
awk '!seen[$0]++' "$1"
