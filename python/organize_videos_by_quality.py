#!/usr/bin/env python3
import os
import shutil
import subprocess

QUALITY_CATEGORIES = {
    "Very High": range(1081, 10000),  # Resolutions above 1080p
    "High": range(1080, 1081),  # 1080p
    "Medium": range(720, 1080),  # 720p
    "Low": range(240, 720),  # 240p - 480p
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
        return int(resolution) if resolution else None
    except Exception as e:
        print(f"Error getting resolution for {filepath}: {e}")
        return None


def categorize_by_quality(resolution):
    """Categorize resolution into Low, Medium, High, or Very High quality."""
    for category, resolution_range in QUALITY_CATEGORIES.items():
        if resolution in resolution_range:
            return category
    return None


def organize_videos_by_quality(base_dir):
    """Organize video files by their quality categories."""
    for root, _, files in os.walk(base_dir):
        for file in files:
            if any(file.lower().endswith(ext) for ext in VIDEO_EXTENSIONS):
                filepath = os.path.join(root, file)
                resolution = get_video_resolution(filepath)

                if resolution:
                    category = categorize_by_quality(resolution)

                    if category:
                        destination_dir = os.path.join(base_dir, category)
                        os.makedirs(destination_dir, exist_ok=True)
                        destination_file = os.path.join(destination_dir, file)

                        # Handle existing file case
                        if os.path.exists(destination_file):
                            base, extension = os.path.splitext(file)
                            counter = 1
                            # Create a new filename by appending a number
                            while os.path.exists(destination_file):
                                destination_file = os.path.join(
                                    destination_dir, f"{base}_{counter}{extension}"
                                )
                                counter += 1

                        shutil.move(filepath, destination_file)
                        print(f"Moved '{file}' to '{destination_file}'")
                    else:
                        print(f"Resolution not recognized for '{file}', skipping.")
                else:
                    print(f"Could not detect resolution for '{file}'")


if __name__ == "__main__":
    base_directory = os.getcwd()
    organize_videos_by_quality(base_directory)
