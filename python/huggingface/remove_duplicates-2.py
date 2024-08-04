import json
import sys


def remove_duplicate_entries(json_file_path):
    try:
        with open(json_file_path, "r") as file:
            data = json.load(file)

            if not isinstance(data, list):
                print("Error: JSON file should contain an array of objects.")
                return -1

            unique_entries = {}
            for entry in data:
                if "item_name" in entry:
                    item_name = entry["item_name"]
                    # Store only the first entry for each unique item_name
                    if item_name not in unique_entries:
                        unique_entries[item_name] = entry

            with open(json_file_path, "w") as output_file:
                json.dump(list(unique_entries.values()), output_file, indent=2)

    except FileNotFoundError:
        print(f"File not found: {json_file_path}")
        return -1
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
        return -1


if __name__ == "__main__":
    if len(sys.argv) == 2:
        json_file_path = sys.argv[1]
    else:
        json_file_path = input("Enter the path to the JSON file: ")

    remove_duplicate_entries(json_file_path)
    print(f"Duplicate entries removed. Changes saved to {json_file_path}")
