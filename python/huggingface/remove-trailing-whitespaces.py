import sys

if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    filename = input("Enter the name of the file to be processed: ")

with open(filename, 'r') as file:
    lines = file.readlines()

lines = [line.rstrip() + '\n' for line in lines]

with open(filename, 'w') as file:
    file.writelines(lines)

print("File processed successfully!")
