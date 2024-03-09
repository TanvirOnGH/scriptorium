import sys, json

if len(sys.argv) > 1:
    file_path = sys.argv[1]
else:
    file_path = input("Enter the path to the JSON file: ")

with open(file_path) as f:
    data = json.load(f)

def reorder_section(section):
    return {
        "title": section.get("title", ""),
        "description": section.get("description", ""),
        "type": section.get("type", "")
    }

for section_idx, section in enumerate(data):
    data[section_idx] = reorder_section(section)

with open(file_path, 'w') as json_file:
    json.dump(data, json_file, indent=2)
