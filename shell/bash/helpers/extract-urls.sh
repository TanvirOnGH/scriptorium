#!/bin/sh

# Extract URLs from lines of text and output them
# Usage: ./extract_urls.sh < input.txt

while read -r line; do
	# Use grep to extract URLs enclosed in quotes or plain URLs
	echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]*"
done
