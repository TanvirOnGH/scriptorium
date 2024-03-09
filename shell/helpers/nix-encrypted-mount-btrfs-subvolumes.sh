#!/bin/sh
#- <https://nixos.wiki/wiki/Full_Disk_Encryption>
#- <https://nixos.wiki/wiki/Btrfs>

ROOT_DEVICE="nvme0n1p1"
BOOT_DEVICE="nvme0n1p2"

ENCRYPTED_MOUNT_PATH="cryptroot"
MOUNT_PATH="/mnt"

cryptsetup open /dev/"$ROOT_DEVICE" "$ENCRYPTED_MOUNT_PATH"

mount /dev/mapper/cryptroot "$MOUNT_PATH"

# ROOT
mkdir -p /mnt
mount -o compress=zstd,subvol=root /dev/mapper/cryptroot /mnt
mount -o compress=zstd,subvol=home /dev/mapper/cryptroot /mnt/home
mount -o compress=zstd,subvol=nix /dev/mapper/cryptroot /mnt/nix

# BOOT
mount /dev/"$BOOT_DEVICE" /mnt/boot
