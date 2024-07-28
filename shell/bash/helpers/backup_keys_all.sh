#!/bin/sh
# shellcheck disable=SC2181

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <gpg-key-id-or-email> <backup-directory>"
    exit 1
fi

GPG_KEY_ID="$1"
BACKUP_DIR="$2"

mkdir -p "$BACKUP_DIR"

# Backup SSH keys and configuration
cp ~/.ssh/id_rsa* "$BACKUP_DIR/" 2>/dev/null
cp ~/.ssh/id_ed25519* "$BACKUP_DIR/" 2>/dev/null
cp ~/.ssh/id_dsa* "$BACKUP_DIR/" 2>/dev/null
cp ~/.ssh/id_ecdsa* "$BACKUP_DIR/" 2>/dev/null
cp ~/.ssh/known_hosts* "$BACKUP_DIR/" 2>/dev/null
cp ~/.ssh/config "$BACKUP_DIR/" 2>/dev/null
cp ~/.ssh/authorized_keys "$BACKUP_DIR/" 2>/dev/null

# Check if the SSH files were copied
if [ $? -eq 0 ]; then
    echo "SSH keys and configuration files have been backed up to $BACKUP_DIR."
else
    echo "No SSH keys or configuration files were found to backup."
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

# Backup GPG trust database
gpg --export-ownertrust >"$BACKUP_DIR/ownertrust.gpg"
if [ $? -eq 0 ]; then
    echo "GPG ownertrust database has been backed up to $BACKUP_DIR/ownertrust.gpg."
else
    echo "Failed to export GPG ownertrust database."
fi

# Backup GPG directories and other important files
cp -r ~/.gnupg/openpgp-revocs.d "$BACKUP_DIR/" 2>/dev/null
cp -r ~/.gnupg/private-keys-v1.d "$BACKUP_DIR/" 2>/dev/null
cp ~/.gnupg/gpg.conf "$BACKUP_DIR/" 2>/dev/null
cp ~/.gnupg/pubring.kbx "$BACKUP_DIR/" 2>/dev/null
cp ~/.gnupg/trustdb.gpg "$BACKUP_DIR/" 2>/dev/null
cp ~/.gnupg/random_seed "$BACKUP_DIR/" 2>/dev/null
cp ~/.gnupg/secring.gpg "$BACKUP_DIR/" 2>/dev/null
cp ~/.gnupg/ssb* "$BACKUP_DIR/" 2>/dev/null

# Check if the GPG files were copied
if [ $? -eq 0 ]; then
    echo "GPG keys and configuration files have been backed up to $BACKUP_DIR."
else
    echo "No GPG keys or configuration files were found to backup."
fi
