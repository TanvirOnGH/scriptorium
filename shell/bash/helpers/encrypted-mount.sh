#!/bin/sh

ENCRYPTED_MOUNT_PATH="cryptroot"
MOUNT_PATH="/mnt"

cryptsetup open /dev/"$1" "$ENCRYPTED_MOUNT_PATH"

mount /dev/mapper/cryptroot "$MOUNT_PATH"
