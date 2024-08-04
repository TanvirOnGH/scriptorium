import sys


def remove_empty_lines(file_path):
    try:
        with open(file_path, "r") as file:
            lines = file.readlines()

        non_empty_lines = [line for line in lines if line.strip()]

        with open(file_path, "w") as file:
            file.writelines(non_empty_lines)

        print(f"Empty lines removed from {file_path}")
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
    else:
        file_path = input("Enter the path of the text file: ")

    remove_empty_lines(file_path)
