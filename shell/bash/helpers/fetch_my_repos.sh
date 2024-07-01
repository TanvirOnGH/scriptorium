#!/bin/sh

clone_or_pull() {
    repo_url="$1"
    repo_name=$(basename "$repo_url" .git)
    
    if [ -d "$repo_name" ]; then
        echo "Updating existing repository $repo_name..."
        cd "$repo_name" || exit
        git pull
        cd .. || exit
    else
        echo "Cloning repository $repo_name..."
        git clone "$repo_url"
    fi
}

fetch_github_repos() {
    username="$1"
    clone_method="$2"
    echo "Fetching GitHub repositories for $username using $clone_method method..."
    url="https://api.github.com/users/$username/repos?per_page=100"
    repos=""

    if [ "$clone_method" = "ssh" ]; then
        repos=$(curl -s "$url" | grep -o '"ssh_url": *"[^"]*"' | cut -d '"' -f 4)
    elif [ "$clone_method" = "https" ]; then
        repos=$(curl -s "$url" | grep -o '"clone_url": *"[^"]*"' | cut -d '"' -f 4)
    fi

    (
        cd GitHub || exit
        
        for repo in $repos; do
            clone_or_pull "$repo"
        done
    )
}

fetch_gitlab_repos() {
    username="$1"
    clone_method="$2"
    echo "Fetching GitLab repositories for $username using $clone_method method..."
    url="https://gitlab.com/api/v4/users/$username/projects?per_page=100"
    repos=""

    if [ "$clone_method" = "ssh" ]; then
        repos=$(curl -s "$url" | grep -o '"ssh_url_to_repo": *"[^"]*"' | cut -d '"' -f 4)
    elif [ "$clone_method" = "https" ]; then
        repos=$(curl -s "$url" | grep -o '"http_url_to_repo": *"[^"]*"' | cut -d '"' -f 4)
    fi

    (
        cd GitLab || exit

        for repo in $repos; do
            clone_or_pull "$repo"
        done
    )
}

if [ $# -lt 3 ]; then
    echo "Usage: $0 <method> <GitHub:Username> <GitLab:Username>"
    exit 1
fi

if [ "$1" != "ssh" ] && [ "$1" != "https" ]; then
    echo "Invalid cloning method. Please use 'ssh' or 'https'."
    exit 1
fi

mkdir -p GitHub GitLab

shift
for param in "$@"; do
    service=$(echo "$param" | cut -d ':' -f 1)
    username=$(echo "$param" | cut -d ':' -f 2)
    case $service in
        GitHub) fetch_github_repos "$username" "$1";;
        GitLab) fetch_gitlab_repos "$username" "$1";;
        *) echo "Unknown source for user: $param";;
    esac
done

echo "All repositories have been processed."
