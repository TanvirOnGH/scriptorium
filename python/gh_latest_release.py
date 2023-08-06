import os
import requests, wget


def get_latest_release_url(owner, repo):
    api_url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    response = requests.get(api_url)
    if response.status_code == 200:
        data = response.json()
        if "assets" in data:
            for asset in data["assets"]:
                if "browser_download_url" in asset:
                    return asset["browser_download_url"]
    return None


def download_latest_release(url, download_path):
    try:
        wget.download(url, download_path)
        print("\nDownload completed successfully.")
    except Exception as e:
        print("\nAn error occurred during download:", e)


def main():
    owner = "github_owner"
    repo = "github_repo"
    download_path = "release.zip"

    release_url = get_latest_release_url(owner, repo)
    if release_url:
        download_latest_release(release_url, download_path)
    else:
        print("Unable to fetch the latest release URL.")


if __name__ == "__main__":
    main()
