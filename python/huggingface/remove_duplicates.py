import sys, json

if len(sys.argv) > 1:
    file_path = sys.argv[1]
else:
    file_path = input("Enter the path to the JSON file: ")

with open(file_path) as f:
    data = json.load(f)

unique_data = []

num_duplicates_removed = 0

for d in data:
    if d not in unique_data:
        unique_data.append(d)
    else:
        num_duplicates_removed += 1

with open(file_path, "w") as f:
    json.dump(unique_data, f, indent=2)

print(f"Removed {num_duplicates_removed} duplicates from {file_path}")
