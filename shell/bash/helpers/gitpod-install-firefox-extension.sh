#!/bin/sh

# Usage: ./install_extension.sh <extension_xpi_url>
# Example: ./install_extension.sh "https://addons.mozilla.org/firefox/downloads/file/1234567/extension_name-1.0.0.xpi"

EXTENSION_URL="$1"

if [ -z "$EXTENSION_URL" ]; then
	echo "Usage: $0 <extension_xpi_url>"
	exit 1
fi

EXTENSION_FILE="/workspace/$(basename "$EXTENSION_URL")"
wget -O "$EXTENSION_FILE" "$EXTENSION_URL"

PROFILE_DIR=$(find ~/.mozilla/firefox -maxdepth 1 -name "*.default*" | head -n 1)

mkdir -p "$PROFILE_DIR/extensions"

EXTENSION_ID=$(basename "$EXTENSION_FILE" .xpi)
mv "$EXTENSION_FILE" "$PROFILE_DIR/extensions/$EXTENSION_ID@mozilla.org.xpi"

echo "Extension installed. Please restart Firefox for the changes to take effect."
