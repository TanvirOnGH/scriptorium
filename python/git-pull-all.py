import os
import subprocess

# Improved version of git-pull-all.sh

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
    root_directory = input("Enter the root directory path: ")
    git_pull_all_repositories(root_directory)
