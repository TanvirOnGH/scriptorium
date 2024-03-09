import sys

if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    filename = input("Enter the name of the file to be processed: ")

with open(filename, 'r') as file:
    lines = file.readlines()

unique_lines = list(set(lines))
num_duplicates = len(lines) - len(unique_lines)

with open(filename, 'w') as file:
    file.writelines(unique_lines)

print(f"Removed {num_duplicates} duplicates.")
