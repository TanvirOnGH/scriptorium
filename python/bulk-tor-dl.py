import requests
import socks
import socket
import os

socks.set_default_proxy(socks.SOCKS5, "localhost", 9050)
socket.socket = socks.socksocket

base_url = "http://xyz.onion/image_"
identifier = "image_"
extension = "png"

start_index = 1
end_index = 99

if extension != "":
    extension = "." + extension

for i in range(start_index, end_index + 1):
    # 010 to 099
    url = f"{base_url}{i:02d}{extension}" if i <= 9 else f"{base_url}{i:03d}{extension}"
    file_name = f"{identifier}{i:02d}{extension}" if i <= 9 else f"{identifier}{i:03d}{extension}"

    if os.path.exists(file_name):
        print(f"Skipping {file_name}, already downloaded.")
        continue

    try:
        response = requests.get(url)

        if response.status_code == 200:
            with open(file_name, "wb") as file:
                file.write(response.content)
            print(f"Downloaded: {file_name}")
        else:
            print(f"Failed to download: {url}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
