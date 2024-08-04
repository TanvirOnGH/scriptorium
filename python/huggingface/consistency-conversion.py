import json
import sys


def convert_to_consistent_format(original_data):
    consistent_data = []
    for item in original_data:
        consistent_item = {
            "item_1": item["item_1"],
            "item_2": item["item_2"],
            "item_3": item["item_3"],
        }

        optional_fields = {
            key: value
            for key, value in item.items()
            if key not in ("item_1", "item_2", "item_3")
        }
        if optional_fields:
            consistent_item["optionalFields"] = optional_fields

        consistent_data.append(consistent_item)

    return consistent_data


if len(sys.argv) > 1:
    json_file_path = sys.argv[1]
else:
    json_file_path = input("Enter the path to the JSON file: ")

try:
    with open(json_file_path, "r") as json_file:
        original_data = json.load(json_file)
        consistent_data = convert_to_consistent_format(original_data)

    with open(json_file_path, "w") as json_file:
        json.dump(consistent_data, json_file, indent=2)

    print(f"Data has been converted and written to {json_file_path}")

except FileNotFoundError:
    print(f"File not found: {json_file_path}")
except json.JSONDecodeError:
    print("Invalid JSON format in the provided file.")
