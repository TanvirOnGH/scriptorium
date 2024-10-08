import requests
import argparse


def get_repo_stats(owner, repo, token=None):
    headers = {}
    if token:
        headers["Authorization"] = f"token {token}"
    url = f"https://api.github.com/repos/{owner}/{repo}"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        repo_data = response.json()
        stats = {
            "stars": repo_data["stargazers_count"],
            "forks": repo_data["forks_count"],
            "open_issues": repo_data["open_issues_count"],
            "watchers": repo_data["watchers_count"],
            "subscribers": repo_data["subscribers_count"],
        }
        return stats
    else:
        print(
            f"Error: {response.status_code} - {response.json().get('message', 'Unknown error')}"
        )
        return None


def main():
    parser = argparse.ArgumentParser(description="Get GitHub repository statistics.")
    parser.add_argument("repo", type=str, help="Repository in owner/repo format")
    parser.add_argument(
        "-t", "--token", type=str, help="GitHub API token (for private repos)"
    )

    args = parser.parse_args()
    owner, repo = args.repo.split("/")

    stats = get_repo_stats(owner, repo, args.token)
    if stats:
        print(f"Repository Statistics for {owner}/{repo}:")
        for key, value in stats.items():
            print(f"- {key.replace('_', ' ').title()}: {value}")


if __name__ == "__main__":
    main()
