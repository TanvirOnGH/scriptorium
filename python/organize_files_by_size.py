import os
import shutil

# Size thresholds in bytes
SIZE_THRESHOLDS = {
    "tiny": 1 * 1024,  # Files smaller than 1 KB
    "very_small": 10 * 1024,  # Files between 1 KB and 10 KB
    "small": 100 * 1024,  # Files between 10 KB and 100 KB
    "medium": 1 * 1024 * 1024,  # Files between 100 KB and 1 MB
    "large": 10 * 1024 * 1024,  # Files between 1 MB and 10 MB
    "very_large": 100 * 1024 * 1024,  # Files between 10 MB and 100 MB
    "huge": 1 * 1024 * 1024 * 1024,  # Files between 100 MB and 1 GB
    "massive": 10 * 1024 * 1024 * 1024,  # Files between 1 GB and 10 GB
    "gigantic": 100 * 1024 * 1024 * 1024,  # Files between 10 GB and 100 GB
    "colossal": 1 * 1024 * 1024 * 1024 * 1024,  # Files larger than 100 GB
}


def organize_files_by_size(directory):
    # Create subdirectories for each size category
    for category in SIZE_THRESHOLDS.keys():
        os.makedirs(os.path.join(directory, category), exist_ok=True)

    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)

        if os.path.isfile(file_path):
            file_size = os.path.getsize(file_path)

            # Determine the size category
            if file_size < SIZE_THRESHOLDS["tiny"]:
                category = "tiny"
            elif file_size < SIZE_THRESHOLDS["very_small"]:
                category = "very_small"
            elif file_size < SIZE_THRESHOLDS["small"]:
                category = "small"
            elif file_size < SIZE_THRESHOLDS["medium"]:
                category = "medium"
            elif file_size < SIZE_THRESHOLDS["large"]:
                category = "large"
            elif file_size < SIZE_THRESHOLDS["very_large"]:
                category = "very_large"
            elif file_size < SIZE_THRESHOLDS["huge"]:
                category = "huge"
            elif file_size < SIZE_THRESHOLDS["massive"]:
                category = "massive"
            elif file_size < SIZE_THRESHOLDS["gigantic"]:
                category = "gigantic"
            else:
                category = "colossal"

            shutil.move(file_path, os.path.join(directory, category, filename))


if __name__ == "__main__":
    target_directory = input("Enter the directory to organize: ")
    if os.path.isdir(target_directory):
        organize_files_by_size(target_directory)
        print("Files organized successfully.")
    else:
        print("The specified directory does not exist.")
