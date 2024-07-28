#!/bin/sh
# shellcheck disable=SC2181

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <gpg-key-id-or-email> <backup-directory>"
    exit 1
fi

GPG_KEY_ID="$1"
BACKUP_DIR="$2"

mkdir -p "$BACKUP_DIR"

# Backup SSH keys
cp ~/.ssh/id_rsa* "$BACKUP_DIR/" 2>/dev/null
cp ~/.ssh/id_ed25519* "$BACKUP_DIR/" 2>/dev/null

# Check if the SSH keys were copied
if [ $? -eq 0 ]; then
    echo "SSH keys have been backed up to $BACKUP_DIR."
else
    echo "No SSH keys were found to backup."
fi

# Backup GPG public keys
gpg --export --armor "$GPG_KEY_ID" >"$BACKUP_DIR/public-keys.gpg"
if [ $? -eq 0 ]; then
    echo "GPG public keys have been backed up to $BACKUP_DIR/public-keys.gpg."
else
    echo "Failed to export GPG public keys for $GPG_KEY_ID."
fi

# Backup GPG private keys
gpg --export-secret-keys --armor "$GPG_KEY_ID" >"$BACKUP_DIR/private-keys.gpg"
if [ $? -eq 0 ]; then
    echo "GPG private keys have been backed up to $BACKUP_DIR/private-keys.gpg."
else
    echo "Failed to export GPG private keys for $GPG_KEY_ID."
fi

echo "Backup completed."
