import argparse
import requests
import time
import os
import re

"""
Example Usage:

1. View followers of a user:
    ./github_followers_following.py <username> --followers

2. View users a user is following:
    ./github_followers_following.py <username> --following

3. Follow the followers of a user:
    ./github_followers_following.py <username> --follow --count 10 --rate-limit 60

4. Unfollow the users a user is following:
    ./github_followers_following.py <username> --unfollow --count 10 --rate-limit 60

Required Token Permissions:

- user:follow
- read:user

To generate a GitHub token:

1. Go to GitHub Settings: https://github.com/settings/profile
2. Click on 'Developer settings'.
3. Click on 'Personal access tokens'.
4. Click 'Generate new token'.
5. Give your token a descriptive name.
6. Select the following scopes:
   - user (which includes read:user and user:follow).
7. Click 'Generate token'.
8. Copy the token and store it securely.

Set the token as an environment variable:

export GITHUB_TOKEN=<your_github_token>
"""

GITHUB_API_URL = "https://api.github.com"
RATE_LIMIT_DELAY = 3  # Delay in seconds to avoid hitting rate limits


def get_auth_token():
    """Fetch GitHub token from environment or prompt the user."""
    token = os.getenv("GITHUB_TOKEN")
    if not token:
        raise EnvironmentError(
            "GitHub token not found. Please set the GITHUB_TOKEN environment variable."
        )
    return token


def get_paginated_data(url, token):
    """Fetch paginated data from a given URL."""
    data = []
    page = 1
    while True:
        response = requests.get(
            f"{url}?page={page}&per_page=100",
            headers={"Authorization": f"token {token}"},
        )
        if response.status_code != 200:
            raise Exception(f"Failed to fetch data: {response.json()}")
        page_data = response.json()
        if not page_data:
            break
        data.extend(page_data)
        page += 1
    return data


def get_followers(username, token):
    """Fetch all followers of the specified user."""
    return get_paginated_data(f"{GITHUB_API_URL}/users/{username}/followers", token)


def get_following(username, token):
    """Fetch all users the specified user is following."""
    return get_paginated_data(f"{GITHUB_API_URL}/users/{username}/following", token)


def follow_user(username, token):
    """Follow a user."""
    response = requests.put(
        f"{GITHUB_API_URL}/user/following/{username}",
        headers={"Authorization": f"token {token}"},
    )
    if response.status_code == 204:
        print(f"Successfully followed {username}.")
    elif response.status_code == 404:
        print(f"User {username} not found.")
    elif response.status_code == 403:
        print(f"Rate limit exceeded. Waiting for {RATE_LIMIT_DELAY} seconds.")
        time.sleep(RATE_LIMIT_DELAY)
        follow_user(username, token)
    else:
        print(f"Failed to follow {username}: {response.json()}")


def unfollow_user(username, token):
    """Unfollow a user."""
    response = requests.delete(
        f"{GITHUB_API_URL}/user/following/{username}",
        headers={"Authorization": f"token {token}"},
    )
    if response.status_code == 204:
        print(f"Successfully unfollowed {username}.")
    elif response.status_code == 404:
        print(f"User {username} not found.")
    elif response.status_code == 403:
        print(f"Rate limit exceeded. Waiting for {RATE_LIMIT_DELAY} seconds.")
        time.sleep(RATE_LIMIT_DELAY)
        unfollow_user(username, token)
    else:
        print(f"Failed to unfollow {username}: {response.json()}")


def main():
    parser = argparse.ArgumentParser(
        description="GitHub followers/following management script."
    )
    parser.add_argument(
        "username", help="GitHub username to fetch followers and following users."
    )
    parser.add_argument(
        "--followers", action="store_true", help="View followers of the user."
    )
    parser.add_argument(
        "--following", action="store_true", help="View users the user is following."
    )
    parser.add_argument(
        "--follow", nargs="?", const=True, default=False, help="Follow fetched users."
    )
    parser.add_argument(
        "--unfollow",
        nargs="?",
        const=True,
        default=False,
        help="Unfollow fetched users.",
    )
    parser.add_argument(
        "--count", type=int, default=None, help="Number of users to follow/unfollow."
    )
    parser.add_argument(
        "--rate-limit",
        type=int,
        default=RATE_LIMIT_DELAY,
        help="Rate limit delay in seconds.",
    )
    args = parser.parse_args()

    # Validate the username
    if not re.match(r"^[a-zA-Z0-9-]+$", args.username):
        parser.error(
            "Invalid username. GitHub usernames can only contain alphanumeric characters and hyphens."
        )

    if (
        not args.followers
        and not args.following
        and not args.follow
        and not args.unfollow
    ):
        parser.error(
            "No action requested, add --followers, --following, --follow, or --unfollow"
        )

    token = get_auth_token()

    if args.followers:
        followers = get_followers(args.username, token)
        print(f"Followers of {args.username}:")
        for user in followers:
            print(user["login"])

    if args.following:
        following = get_following(args.username, token)
        print(f"Users {args.username} is following:")
        for user in following:
            print(user["login"])

    if args.follow:
        followers = get_followers(args.username, token)
        print(f"Following users...")
        for i, user in enumerate(followers[: args.count]):
            follow_user(user["login"], token)
            time.sleep(args.rate_limit)

    if args.unfollow:
        following = get_following(args.username, token)
        print(f"Unfollowing users...")
        for i, user in enumerate(following[: args.count]):
            unfollow_user(user["login"], token)
            time.sleep(args.rate_limit)


if __name__ == "__main__":
    main()
