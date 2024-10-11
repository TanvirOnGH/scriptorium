# 4chan and sturdychan/2chen thread media downloader
# Based on: <https://github.com/SegoCode/4cget/raw/refs/heads/main/code/4cget.go>
# CAUTION #
"""
This script uses multithreading to download images from specified threads on supported imageboards.
Be aware that some CDNs may interpret this behavior as a DDoS attack, potentially leading to temporary bans or other issues.
Currently, there is no evidence that this occurs with 4chan.
"""

# Downloads the files organized by boards and threads:
"""
root
 └───board
      └───thread
           └───files
"""

import os
import re
import sys
import time
import math
import requests
from urllib.parse import urlparse
from concurrent.futures import ThreadPoolExecutor
import argparse

monitor_mode = False


class SiteInfo:
    def __init__(self, ID, URL, ImgRE):
        self.ID = ID
        self.URL = URL
        self.ImgRE = re.compile(ImgRE)


# TODO: Two separate scripts for 4chan and sturdychan/2chen
site_info_map = {
    "4chan": SiteInfo(
        "4chan", "https://boards.4chan.org", r'<a[^>]+href="(//is2\.4chan\.org[^"]+)"'
    ),
    "twochen": SiteInfo(
        "twochen",
        "https://sturdychan.help/",
        r"(https?://[^/]+/assets/images/src/[a-zA-Z0-9]+\.(?:png|jpg|jpeg|gif|bmp|webp|mp4|webm|mkv|avi|mov|wmv|flv|mp3|wav|ogg|m4a|flac))",
    ),
}


def find_images(html, site_id):
    """
    Extract image URLs from the given HTML based on the site specified.
    """
    out = []
    site_info = site_info_map.get(site_id)
    if not site_info:
        print(f"No site information found for ID: {site_id}", file=sys.stderr)
        return out

    matches = site_info.ImgRE.findall(html)
    for match in matches:
        url = match
        if site_id == site_info_map["4chan"].ID:
            url = url.replace("//is2.4chan.org", "https://i.4cdn.org")
        out.append(url)

    return list(set(out))  # Remove duplicates


def download_file(url, file_name, path):
    """
    Download a file from the given URL and save it to the specified path.
    """
    file_path = os.path.join(path, file_name)
    if os.path.exists(file_path):
        print(f"File already exists: {file_name} - Skipping Download")
        return

    resp = requests.get(url)
    if resp.status_code != 404:
        with open(file_path, "wb") as img:
            img.write(resp.content)
            b = len(resp.content)
            suffixes = ["B", "KB", "MB", "GB", "TB"]
            base = math.log(b, 1024)
            get_size = math.pow(1024, base - math.floor(base))
            get_suffix = suffixes[int(math.floor(base))]
            print(f"File downloaded: {file_name} - Size: {get_size:.2f} {get_suffix}")


def main():
    """
    Main function to handle argument parsing, URL validation, and initiating the download process.
    """
    global monitor_mode

    parser = argparse.ArgumentParser(
        description="Download images from specified threads on supported imageboards (4chan and sturdychan/2chen only)."
    )
    parser.add_argument(
        "url",
        help="URL of the thread to download images from (e.g., https://boards.4channel.org/<board>/thread/<N>#p<M>)",
    )
    parser.add_argument(
        "-m",
        "--monitor",
        type=int,
        metavar="SECONDS",
        help="Enable monitor mode and check for new images every N seconds (e.g., -m 10 to check every 10 seconds)",
    )

    args = parser.parse_args()
    input_url = args.url
    seconds_iteration = args.monitor

    if seconds_iteration:
        monitor_mode = True

    parsed_url = urlparse(input_url)
    if not parsed_url.scheme or not parsed_url.netloc:
        print(
            "Invalid URL! (Example: https://boards.4channel.org/<board>/thread/<N>#p<M>)",
            file=sys.stderr,
        )
        sys.exit(1)

    site_id = ""
    for site in site_info_map.values():
        parsed_site_url = urlparse(site.URL)
        if parsed_url.netloc == parsed_site_url.netloc:
            site_id = site.ID
            break

    if not site_id:
        print("Unsupported site!", file=sys.stderr)
        sys.exit(1)

    monitor_text = " in Monitor Mode!" if monitor_mode else ""
    print(f"Download Started ({input_url}){monitor_text}")
    print("")

    start = time.time()
    files = 0

    parts = input_url.split("/")
    board = parts[3]
    thread = parts[5] if site_id == site_info_map["4chan"].ID else parts[4]

    actual_path = os.getcwd()
    folder_path = os.path.join(actual_path, board, thread)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path, exist_ok=True)
        print(f"Folder created: {folder_path}")
    else:
        print(f"Folder already exists: {folder_path} - Skipping Creation")
        print("")

    try:
        with ThreadPoolExecutor() as executor:
            while True:
                resp = requests.get(input_url)
                body = resp.text
                futures = []
                for each in find_images(body, site_id):
                    name_img = each.split("/")[-1]
                    futures.append(
                        executor.submit(download_file, each, name_img, folder_path)
                    )
                    files += 1

                if not monitor_mode:
                    break
                else:
                    for i in range(seconds_iteration, -1, -1):
                        print(
                            f"\rChecking for new files in {i} seconds...",
                            end="",
                            flush=True,
                        )
                        time.sleep(1)
                    print()  # To move to the next line after the loop completes
    except KeyboardInterrupt:
        pass
    finally:
        executor.shutdown(wait=False)

    print("")
    print(f"Download Complete, {files} files in {time.time() - start:.2f} seconds!")


if __name__ == "__main__":
    main()
