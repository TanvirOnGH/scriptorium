#!/bin/sh

: '
Script that automates pulling updates from Git repositories in a specified directory from its subdirectories.

It checks if each subdirectory is a Git repository and pulls updates if it is.
If a subdirectory is not a Git repository, the script skips it.
'

is_git_dir() {
	if [ -d "$1/.git" ]; then
		return 0
	else
		return 1
	fi
}

git_pull_all() {
	if [ -d "$1" ]; then
		cd "$1" || exit
	else
		echo "Directory $1 not found"
		exit 1
	fi

	# Loop through all sub-directories in the specified directory
	for d in */; do
		if [ "$d" = "*/" ]; then
			echo "No directories found"
			exit 1
		fi

		if ! is_git_dir "$d"; then
			echo "Skipping $d"
		else
			(
				cd "$d" && git pull || echo "Failed to pull $d"
				echo "Successfully pulled $d"
				echo ""
			)
		fi
	done
}

main() {
	if [ -z "$1" ]; then
		echo "Please specify a directory"
		exit 1
	fi

	git_pull_all "$1"
}

main "$1"
