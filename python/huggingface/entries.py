import sys, json

if len(sys.argv) > 1:
    file_path = sys.argv[1]
else:
    file_path = input("Enter the path to the JSON file: ")

with open(file_path) as f:
    data = json.load(f)

total_entries = len(data)
print(f"Total entries in {file_path}: {total_entries}")
