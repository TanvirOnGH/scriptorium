#!/bin/sh

# Script to install Firefox and configure custom user.js and chrome files

show_usage() {
	echo "Usage: $0 [-u user.js_path] [-c chrome_directory] [-h]"
	echo "Options:"
	echo "  -u user.js_path        Path to custom user.js file"
	echo "  -c chrome_directory    Path to custom chrome directory or files"
	echo "  -h                     Display help"
	exit 1
}

USER_JS=""
CHROME_DIR=""
while getopts "u:c:h" opt; do
	case "$opt" in
	u) USER_JS="$OPTARG" ;;
	c) CHROME_DIR="$OPTARG" ;;
	h) show_usage ;;
	*) show_usage ;;
	esac
done

sudo install -d -m 0755 /etc/apt/keyrings

wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null

gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla >/dev/null

sudo apt-get update && sudo apt-get install firefox -y

# Launch Firefox once to create the profile directory
firefox &
sleep 10 && pkill firefox

PROFILE_DIR=$(find ~/.mozilla/firefox -maxdepth 1 -name "*.default*" | head -n 1)

if [ -z "$PROFILE_DIR" ]; then
	echo "Firefox profile directory not found!"
	exit 1
fi

echo "Firefox profile directory: $PROFILE_DIR"

if [ -n "$USER_JS" ]; then
	if [ -f "$USER_JS" ]; then
		ln -sfn "$USER_JS" "$PROFILE_DIR/user.js"
		echo "Linked custom user.js: $USER_JS"
	else
		echo "Provided user.js file does not exist: $USER_JS"
		exit 1
	fi
fi

if [ -n "$CHROME_DIR" ]; then
	if [ -d "$CHROME_DIR" ]; then
		mkdir -p "$PROFILE_DIR/chrome"
		for item in "$CHROME_DIR"/*; do
			ln -sfn "$item" "$PROFILE_DIR/chrome"
		done
		echo "Linked custom chrome files from: $CHROME_DIR"
	else
		echo "Provided chrome directory does not exist: $CHROME_DIR"
		exit 1
	fi
fi
