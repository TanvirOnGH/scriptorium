import os
import shutil
import argparse

# Organizes files in a directory based on their extensions


def organize_files(directory):
    if not os.path.isdir(directory):
        print(f"The directory {directory} does not exist.")
        return

    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        # Only process files
        if os.path.isfile(file_path):
            extension = os.path.splitext(filename)[1].lower()
            if extension:
                destination_dir = os.path.join(
                    directory, extension[1:]
                )  # Remove the dot from the extension
                os.makedirs(destination_dir, exist_ok=True)
                shutil.move(file_path, os.path.join(destination_dir, filename))
                print(f"Moved {filename} to {destination_dir}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Organize files in a directory based on their extensions."
    )
    parser.add_argument(
        "directory", type=str, help="The path to the directory to organize."
    )

    args = parser.parse_args()
    organize_files(args.directory)
