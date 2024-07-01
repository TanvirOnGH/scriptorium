#!/bin/sh

LOG_DIR="/var/log"

# Maximum file size (in KB) for rotation
MAX_SIZE=10240

# Maximum age (in days) for rotation
MAX_AGE=30

usage() {
    echo "Usage: $0 [-s <size in KB>] [-a <age in days>] [-p <log directory>]"
    echo "  -s: Set maximum file size for rotation (in KB, default: 10240 KB)"
    echo "  -a: Set maximum age for rotation (in days, default: 30 days)"
    echo "  -p: Set log file directory (default: /var/log)"
    exit 1
}

while getopts "s:a:p:" opt; do
    case "$opt" in
    s)
        MAX_SIZE="$OPTARG"
        ;;
    a)
        MAX_AGE="$OPTARG"
        ;;
    p)
        LOG_DIR="$OPTARG"
        ;;
    \?)
        usage
        ;;
    esac
done

# Rotate log files based on size
find "$LOG_DIR" -type f -size +"$MAX_SIZE"k -exec sh -c '
  for f; do
    mv "$f" "$f.$(date +%Y-%m-%d)"
  done
' sh {} +

# Rotate log files based on age
find "$LOG_DIR" -type f -mtime +"$MAX_AGE" -exec sh -c '
  for f; do
    mv "$f" "$f.$(date +%Y-%m-%d)"
  done
' sh {} +

echo "Log files rotated."
