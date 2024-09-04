#!/bin/sh

FILE=""
COMMIT_MESSAGE=""
FILE_CONTENT="
"
FORCE_PUSH=false

for dir in */; do
	[ -d "$dir" ] || continue
	(
		cd "$dir" || echo "failed to cd into directory '$dir'"
		if [ -d ".git" ]; then
			echo "$FILE_CONTENT" >>"$FILE"

			git add "$FILE"
			git commit -m "$COMMIT_MESSAGE"

			if [ "$FORCE_PUSH" = true ]; then
				git push --force
			else
				git push
			fi
		fi
	)
done
