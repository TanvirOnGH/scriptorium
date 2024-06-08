#!/bin/sh

algorithm="gzip"
compression_level="-1"
output_filename=""

usage() {
    echo "Usage: $0 [-a algorithm] [-l level] [-o output_filename] <file/directory>"
    echo "Options:"
    echo "  -a <algorithm>   Compression algorithm: gzip (default), bzip2, xz, zstd, lzma, lzop, compress"
    echo "  -l <level>       Compression level: -1 (default) to -9 (best) for gzip, bzip2, lzma, lzop, compress; 1 (fastest) to 19 (best) for zstd, -0 (store) to -9 (max) for xz"
    echo "  -o <filename>    Output filename (optional)"
    exit 1
}

while getopts ":a:l:o:" opt; do
    case ${opt} in
    a)
        algorithm="$OPTARG"
        ;;
    l)
        compression_level="$OPTARG"
        ;;
    o)
        output_filename="$OPTARG"
        ;;
    \?)
        usage
        ;;
    :)
        echo "Error: Option -$OPTARG requires an argument."
        usage
        ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    echo "Error: File/directory argument is missing."
    usage
fi

if [ ! -e "$1" ]; then
    echo "Error: File or directory '$1' not found."
    exit 1
fi

base=$(basename "$1")

if [ -f "$1" ]; then
    if [ -z "$output_filename" ]; then
        tar -c -$algorithm$compression_level -f "$base.$algorithm" "$1"
    else
        tar -c -$algorithm$compression_level -f "$output_filename" "$1"
    fi
    echo "File '$base' compressed successfully using $algorithm algorithm with compression level $compression_level."
elif [ -d "$1" ]; then
    # if it's a directory, compress the contents recursively
    if [ -z "$output_filename" ]; then
        tar -c -$algorithm$compression_level -f "$base.$algorithm" "$base"
    else
        tar -c -$algorithm$compression_level -f "$output_filename" "$base"
    fi
    echo "Directory '$base' compressed successfully using $algorithm algorithm with compression level $compression_level."
else
    echo "Error: '$1' is not a valid file or directory."
    exit 1
fi
