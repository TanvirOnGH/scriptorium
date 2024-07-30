import sys, json

if len(sys.argv) > 1:
    file_path = sys.argv[1]
else:
    file_path = input("Enter the path to the JSON file: ")

with open(file_path) as f:
    data = json.load(f)

sorted_data = sorted(data, key=lambda d: list(d.keys()))

with open(file_path, "w") as f:
    json.dump(sorted_data, f, indent=2)
