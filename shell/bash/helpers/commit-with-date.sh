#!/bin/sh

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 \"commit message\" \"YYYY-MM-DD HH:MM:SS\""
	exit 1
fi

COMMIT_MESSAGE="$1"
COMMIT_DATE="$2"

GIT_COMMITTER_DATE="$COMMIT_DATE" git commit -m "$COMMIT_MESSAGE" --date="$COMMIT_DATE"
