import os
import subprocess
import sys


def git_pull_all_repositories(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if ".git" in dirnames:  # Check if it's a Git repository
            repo_dir = os.path.join(dirpath, ".git")
            repository_path = os.path.abspath(os.path.join(repo_dir, ".."))
            print(f"Pulling repository: {repository_path}")

            try:
                subprocess.run(
                    ["git", "pull"],
                    cwd=repository_path,
                    check=True,
                )
                print("Pull successful.\n")
            except subprocess.CalledProcessError as e:
                print(f"Pull failed: {e}\n")


if __name__ == "__main__":
    if len(sys.argv) == 2:
        root_directory = sys.argv[1]
    else:
        print("Usage: python script.py <root_directory>")
        sys.exit(1)

    git_pull_all_repositories(root_directory)
