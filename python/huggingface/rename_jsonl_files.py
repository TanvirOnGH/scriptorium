import os
import sys


def rename_jsonl_files(directory):
    """Renames all *.jsonl files in the given directory from 0.jsonl to n.jsonl sequentially."""

    count = 0
    for filename in os.listdir(directory):
        if filename.endswith(".jsonl"):
            old_filepath = os.path.join(directory, filename)
            # If you anticipate even more files, adjust the padding width accordingly
            new_filename = (
                f"{count:04d}.jsonl"  # Pad with zeros for consistent formatting
            )
            new_filepath = os.path.join(directory, new_filename)
            os.rename(old_filepath, new_filepath)
            count += 1

    print(f"Renamed {count} JSONL files in the directory: {directory}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        directory_to_rename = sys.argv[1]
    else:
        directory_to_rename = input("Enter the directory containing the JSONL files: ")

    rename_jsonl_files(directory_to_rename)
