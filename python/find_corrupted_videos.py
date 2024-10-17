import os
import cv2

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


def is_corrupted(video_path):
    """Check if a video file is corrupted."""
    cap = cv2.VideoCapture(video_path)
    is_opened = cap.isOpened()
    cap.release()
    return not is_opened


def find_corrupted_videos(directory):
    """Recursively find corrupted video files in the given directory."""
    corrupted_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(tuple(VIDEO_EXTENSIONS)):
                video_path = os.path.join(root, file)
                if is_corrupted(video_path):
                    corrupted_files.append(video_path)
    return corrupted_files


if __name__ == "__main__":
    current_directory = os.getcwd()
    corrupted_videos = find_corrupted_videos(current_directory)

    if corrupted_videos:
        print("Corrupted video files found:")
        for video in corrupted_videos:
            print(video)
    else:
        print("No corrupted video files found.")
