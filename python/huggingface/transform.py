import json
import sys

if len(sys.argv) > 1:
    input_file_name = sys.argv[1]
else:
    input_file_name = input("Enter the name of the input JSON file: ")

try:
    with open(input_file_name, 'r') as file:
        original_data = json.load(file)
except FileNotFoundError:
    print(f"Error: File '{input_file_name}' not found.")
    sys.exit(1)

transformed_data = []

for item in original_data:
    if "concept" in item:
        item["type"] = "concept"
        item["title"] = item.pop("concept")
    elif "fact" in item:
        item["type"] = "fact"
        item["title"] = item.pop("fact")
    elif "hypothesis" in item:
        item["type"] = "hypothesis"
        item["title"] = item.pop("hypothesis")
    elif "law" in item:
        item["type"] = "law"
        item["title"] = item.pop("law")
    elif "theory" in item:
        item["type"] = "theory"
        item["title"] = item.pop("theory")

    transformed_data.append(item)

output_file_name = input("Enter the name of the output JSON file (default: transformed.json): ").strip()
if not output_file_name:
    output_file_name = "transformed.json"

with open(output_file_name, 'w') as file:
    json.dump(transformed_data, file, indent=2)

print(f"JSON data has been transformed and saved to '{output_file_name}'.")
