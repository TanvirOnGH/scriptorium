#!/usr/bin/env python3
import os
import shutil
import subprocess
import re

QUALITY_FOLDERS = {
    "1080": "1080p",
    "720": "720p",
    "480": "480p",
    "360": "360p",
    "240": "240p",
}

VIDEO_EXTENSIONS = [
    ".mp4",
    ".mkv",
    ".avi",
    ".mov",
    ".flv",
    ".wmv",
    ".webm",
    ".mpg",
    ".mpeg",
    ".3gp",
    ".rmvb",
]


def get_video_resolution(filepath):
    """Get the resolution of the video using ffprobe."""
    try:
        result = subprocess.run(
            [
                "ffprobe",
                "-v",
                "error",
                "-select_streams",
                "v:0",
                "-show_entries",
                "stream=height",
                "-of",
                "csv=s=x:p=0",
                filepath,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        resolution = result.stdout.strip()
        return resolution if resolution else None
    except Exception as e:
        print(f"Error getting resolution for {filepath}: {e}")
        return None


def organize_videos_by_quality(base_dir):
    """Organize video files by their quality (resolution)."""
    for root, _, files in os.walk(base_dir):
        for file in files:
            if any(file.lower().endswith(ext) for ext in VIDEO_EXTENSIONS):
                filepath = os.path.join(root, file)
                resolution = get_video_resolution(filepath)

                if resolution:
                    # Match resolution to folder
                    folder = None
                    for res, folder_name in QUALITY_FOLDERS.items():
                        if re.search(f"{res}", resolution):
                            folder = folder_name
                            break

                    if folder:
                        destination_dir = os.path.join(base_dir, folder)
                        os.makedirs(destination_dir, exist_ok=True)
                        shutil.move(filepath, destination_dir)
                        print(f"Moved '{file}' to '{folder}'")
                    else:
                        print(f"Resolution not recognized for '{file}', skipping.")
                else:
                    print(f"Could not detect resolution for '{file}'")


if __name__ == "__main__":
    base_directory = os.getcwd()
    organize_videos_by_quality(base_directory)
