#!/bin/sh

usage() {
	echo "Usage: $0 source_directory [target_directory]"
	echo "Extract all archives in the source_directory."
	echo "If target_directory is provided, move all extracted items there."
}

confirm_extraction() {
	file="$1"
	echo "The following file will be extracted: $file"
	echo "Do you want to proceed? (y/n): \c"
	read -r confirmation
	case "$confirmation" in
	y | Y) ;;
	*)
		echo "Skipping extraction of $file."
		return 1
		;;
	esac
	return 0
}

extract_archive() {
	file="$1"
	output_dir="$2"

	if ! confirm_extraction "$file"; then
		return
	fi

	case "$file" in
	*.zip)
		echo "Extracting ZIP archive: $file"
		unzip -q "$file" -d "${output_dir:-${file%.zip}}" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.rar)
		echo "Extracting RAR archive: $file"
		unrar x -y "$file" "${output_dir:-${file%.rar}}/" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.tar.gz | *.tgz)
		echo "Extracting TAR.GZ archive: $file"
		mkdir -p "${output_dir:-${file%.tar.gz}}"
		tar -xzf "$file" -C "${output_dir:-${file%.tar.gz}}" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.tar.xz | *.txz)
		echo "Extracting TAR.XZ archive: $file"
		mkdir -p "${output_dir:-${file%.tar.xz}}"
		tar -xJf "$file" -C "${output_dir:-${file%.tar.xz}}" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.tar.bz2 | *.tbz)
		echo "Extracting TAR.BZ2 archive: $file"
		mkdir -p "${output_dir:-${file%.tar.bz2}}"
		tar -xjf "$file" -C "${output_dir:-${file%.tar.bz2}}" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.tar.zst | *.tzst)
		echo "Extracting TAR.ZST archive: $file"
		mkdir -p "${output_dir:-${file%.tar.zst}}"
		tar --use-compress-program=zstd -xvf "$file" -C "${output_dir:-${file%.tar.zst}}" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.7z)
		echo "Extracting 7Z archive: $file"
		7z x "$file" -o"${output_dir:-${file%.7z}}" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.tar)
		echo "Extracting TAR archive: $file"
		mkdir -p "${output_dir:-${file%.tar}}"
		tar -xf "$file" -C "${output_dir:-${file%.tar}}" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.xz)
		echo "Extracting XZ file: $file"
		unxz "$file" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.lz)
		echo "Extracting LZ file: $file"
		unlz "$file" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.lzma)
		echo "Extracting LZMA file: $file"
		unlzma "$file" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.cab)
		echo "Extracting CAB file: $file"
		cabextract "$file" || {
			echo "Failed to extract $file"
			return 1
		}
		;;
	*.iso)
		echo "Extracting ISO file: $file"
		mkdir -p "${output_dir:-${file%.iso}}"
		mount -o loop "$file" "${output_dir:-${file%.iso}}" || {
			echo "Failed to mount $file"
			return 1
		}
		;;
	*)
		echo "Unsupported archive format: $file"
		return 1
		;;
	esac
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	usage
	exit 1
fi

source_directory="$1"
target_directory="$2"

if [ ! -d "$source_directory" ]; then
	echo "Error: '$source_directory' is not a valid directory."
	exit 1
fi

if [ -n "$target_directory" ] && [ ! -d "$target_directory" ]; then
	echo "Creating target directory: $target_directory"
	mkdir -p "$target_directory" || {
		echo "Failed to create target directory: $target_directory"
		exit 1
	}
fi

for archive in "$source_directory"/*; do
	if [ -f "$archive" ]; then
		extract_archive "$archive" "$target_directory"
	fi
done

echo "Extraction completed."
