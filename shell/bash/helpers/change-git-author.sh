#!/bin/sh

if [ "$#" -ne 4 ]; then
	echo "Usage: $0 \"Old Author Name\" \"old.email@example.com\" \"New Author Name\" \"new.email@example.com\""
	exit 1
fi

OLD_NAME="$1"
OLD_EMAIL="$2"
NEW_NAME="$3"
NEW_EMAIL="$4"

git filter-repo --commit-callback "
    if commit.author_name == b'$OLD_NAME':
        commit.author_name = b'$NEW_NAME'
    if commit.author_email == b'$OLD_EMAIL':
        commit.author_email = b'$NEW_EMAIL'
    if commit.committer_name == b'$OLD_NAME':
        commit.committer_name = b'$NEW_NAME'
    if commit.committer_email == b'$OLD_EMAIL':
        commit.committer_email = b'$NEW_EMAIL'
"
