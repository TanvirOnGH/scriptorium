import requests
import itertools
import argparse


def expand_sha1_url(repo, short_sha1):
    api_url = f"https://api.github.com/repos/{repo}/commits/{short_sha1}"
    response = requests.get(api_url)
    if response.status_code == 200:
        full_sha1 = response.json()["sha"]
        commit_url = f"https://github.com/{repo}/commit/{full_sha1}"
        print(f"Valid short SHA-1 found: {short_sha1}")
        print(f"Full commit URL: {commit_url}")
        return True
    return False


def brute_force_sha1(repo):
    characters = "0123456789abcdef"
    for combination in itertools.product(characters, repeat=4):
        short_hash = "".join(combination)
        if expand_sha1_url(repo, short_hash):
            return
    print("No valid short SHA-1 values found.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Brute force short SHA-1 values and expand to full commit URL."
    )
    parser.add_argument(
        "--repo", type=str, help='GitHub repository in the format "owner/repo"'
    )

    args = parser.parse_args()

    repo = (
        args.repo if args.repo else input("Enter the GitHub repository (owner/repo): ")
    )

    brute_force_sha1(repo)
