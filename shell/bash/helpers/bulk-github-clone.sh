#!/bin/bash
# <https://docs.github.com/en/rest/>
# Incomplete script. It does not work as expected.
# More features to be added.
# Work in progress. (WIP)

if [ -z "$1" ]; then
	echo "Usage: $0 <username>"
	exit 1
fi

username=$1

clone_repositories() {
	local repos_url="$1"
	echo "Fetching repositories information from $repos_url ..."
	repos_info=$(curl -s "$repos_url" | jq -r '.[] | "\(.name) \(.clone_url)"')
	total_repos=$(echo "$repos_info" | wc -l)

	echo "Total repositories: $total_repos"
	echo "Repositories to be downloaded:"
	echo "$repos_info"
	echo ""

	read -p "Do you want to proceed with cloning? (y/n): " confirm
	if [ "$confirm" != "y" ]; then
		echo "Exiting."
		exit 0
	fi

	echo "Cloning repositories from $repos_url ..."
	echo "$repos_info" | while read -r repo_info; do
		repo_name=$(echo "$repo_info" | awk '{print $1}')
		repo_url=$(echo "$repo_info" | awk '{print $2}')
		echo "Cloning $repo_name from $repo_url ..."
		git clone "$repo_url"
	done

	echo "All repositories cloned successfully."
}

echo "Which type of repositories do you want to clone?"
echo "1. All repositories"
echo "2. Only forked repositories"
echo "3. Only source repositories (non-forks)"

read -p "Enter your choice (1/2/3): " choice

case $choice in
1)
	read -p "Enter programming language (leave blank for all): " lang
	if [ -z "$lang" ]; then
		clone_repositories "https://api.github.com/users/$username/repos"
	else
		clone_repositories "https://api.github.com/users/$username/repos?language=$lang"
	fi
	;;
2)
	read -p "Enter programming language (leave blank for all): " lang
	if [ -z "$lang" ]; then
		clone_repositories "https://api.github.com/users/$username/repos?type=forks"
	else
		clone_repositories "https://api.github.com/users/$username/repos?type=forks&language=$lang"
	fi
	;;
3)
	read -p "Enter programming language (leave blank for all): " lang

	# Replace spaces with '+'
	lang=${lang// /+}
	if [ -z "$lang" ]; then
		clone_repositories "https://api.github.com/users/$username/repos"
	else
		clone_repositories "https://api.github.com/users/$username/repos?language=$lang"
	fi
	;;
*)
	echo "Invalid choice. Exiting."
	exit 1
	;;
esac
