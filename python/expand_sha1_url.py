import requests
import argparse

def expand_sha1_url(repo, short_sha1):
    api_url = f"https://api.github.com/repos/{repo}/commits/{short_sha1}"
    response = requests.get(api_url)
    if response.status_code == 200:
        full_sha1 = response.json()['sha']
        commit_url = f"https://github.com/{repo}/commit/{full_sha1}"
        print(f"Full commit URL: {commit_url}")
    else:
        print("Error: Could not find the commit. Make sure the short SHA-1 value is correct and try again.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Expand short SHA-1 to full commit URL.')
    parser.add_argument('--repo', type=str, help='GitHub repository in the format "owner/repo"')
    parser.add_argument('--short_sha1', type=str, help='Short SHA-1 commit hash')

    args = parser.parse_args()

    repo = args.repo if args.repo else input("Enter the GitHub repository (owner/repo): ")
    short_sha1 = args.short_sha1 if args.short_sha1 else input("Enter the short SHA-1 value: ")

    expand_sha1_url(repo, short_sha1)
