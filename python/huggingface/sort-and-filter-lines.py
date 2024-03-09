import sys


def total_char_count(line):
    return len(line)


def is_valid(line):
    return (
        line.strip().endswith(".")
        or line.strip().endswith("!")
        or line.strip().endswith("?")
        or line.strip().endswith("~")
    )


if len(sys.argv) > 1:
    input_file_path = sys.argv[1]
else:
    input_file_path = input("File path: ")

unique_lines = set()

with open(input_file_path, "r") as input_file:
    lines = input_file.readlines()

for line in lines:
    stripped_line = line.strip()
    if stripped_line not in unique_lines and is_valid(stripped_line):
        unique_lines.add(stripped_line)

sorted_lines = sorted(unique_lines, key=total_char_count)

for line in sorted_lines:
    print(line)
