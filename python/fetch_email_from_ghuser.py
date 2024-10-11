"""
The GitHub token is required for authentication to access the GitHub API.
It ensures that the requests are authenticated and can bypass rate limits for unauthenticated requests.
You can obtain a personal access token from https://github.com/settings/tokens?type=beta
Ensure that the token has the 'Public Repositories (read-only)' permission.
"""

import requests
import argparse
import os
from collections import defaultdict


def fetch_repos(username, token, skip_forks, skip_sources):
    url = f"https://api.github.com/users/{username}/repos"
    headers = {"Authorization": f"token {token}"}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        repos = response.json()
        filtered_repos = []
        for repo in repos:
            if skip_forks and repo["fork"]:
                continue
            if skip_sources and not repo["fork"]:
                continue
            filtered_repos.append(repo["name"])
        return filtered_repos
    elif response.status_code == 403:
        return "Failed to fetch repositories. Status code: 403 (Forbidden). Check your rate limit or token."
    else:
        return f"Failed to fetch repositories. Status code: {response.status_code}"


def fetch_commits(username, repo_name, token):
    url = f"https://api.github.com/repos/{username}/{repo_name}/commits"
    headers = {"Authorization": f"token {token}"}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        commits = response.json()
        emails = [
            (commit["sha"], commit["commit"]["author"]["email"])
            for commit in commits
            if "commit" in commit and "author" in commit["commit"]
        ]
        return emails
    elif response.status_code == 404:
        return f"Repository {repo_name} not found."
    else:
        return f"Failed to fetch commits. Status code: {response.status_code}"


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Fetch unique email addresses from GitHub user commits."
    )
    parser.add_argument(
        "username",
        nargs="?",
        help="GitHub username to fetch repositories and commits from. Can also be set via the GITHUB_USERNAME environment variable.",
    )
    parser.add_argument(
        "token",
        nargs="?",
        help="GitHub personal access token for authentication. Can also be set via the GITHUB_TOKEN environment variable.",
    )
    parser.add_argument(
        "-a",
        "--all",
        action="store_true",
        help="Include emails ending with .noreply.github.com.",
    )
    parser.add_argument(
        "--skip-forks", action="store_true", help="Skip repositories that are forks."
    )
    parser.add_argument(
        "--skip-sources",
        action="store_true",
        help="Skip repositories that are not forks.",
    )
    parser.add_argument(
        "--count",
        action="store_true",
        help="Print the emails along with the total amount those were found in repos in how many commits.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arguments()
    username = args.username or os.getenv("GITHUB_USERNAME")
    token = args.token or os.getenv("GITHUB_TOKEN")

    if not username or not token:
        print(
            "Error: GitHub username and token must be provided either as arguments or via the GITHUB_USERNAME and GITHUB_TOKEN environment variables."
        )
        exit(1)

include_noreply = args.all
skip_forks = args.skip_forks
skip_sources = args.skip_sources
count_emails = args.count
repos = fetch_repos(username, token, skip_forks, skip_sources)
unique_emails = defaultdict(lambda: defaultdict(int))
idx = 1  # Global index

if isinstance(repos, list):
    for repo in repos:
        emails = fetch_commits(username, repo, token)
        if isinstance(emails, list):
            for sha, email in emails:
                if not include_noreply and email.endswith(".noreply.github.com"):
                    continue  # Skip .noreply.github.com emails
                unique_emails[email][repo] += 1
        else:
            print(emails)

    for email, repos in unique_emails.items():
        if count_emails:
            repo_commit_counts = ", ".join(
                [f"{repo}: {count} commits" for repo, count in repos.items()]
            )
            print(f"{idx}. {email} - {repo_commit_counts}")
        else:
            print(f"{idx}. {email}")
        idx += 1
else:
    print(repos)
