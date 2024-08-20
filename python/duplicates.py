import os
import hashlib


def get_file_hash(file_path):
    hash_sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_sha256.update(chunk)
    return hash_sha256.hexdigest()


def find_duplicate_files(directory):
    file_hashes = {}
    duplicates = []

    for root, dirs, files in os.walk(directory):
        for filename in files:
            file_path = os.path.join(root, filename)
            file_hash = get_file_hash(file_path)

            if file_hash in file_hashes:
                duplicates.append((file_path, file_hashes[file_hash]))
            else:
                file_hashes[file_hash] = file_path

    return duplicates


if __name__ == "__main__":
    directory = input("Enter the directory path: ")
    if os.path.isdir(directory):
        if duplicate_files := find_duplicate_files(directory):
            print("Duplicate files found:")
            for file1, file2 in duplicate_files:
                print(f"File 1: {file1}")
                print(f"File 2: {file2}")
                print("=" * 30)
        else:
            print("No duplicate files found.")
    else:
        print("Invalid directory path.")
