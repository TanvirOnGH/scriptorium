#!/bin/sh
#- <https://nixos.wiki/wiki/Change_root>

ROOT_DEVICE="nvme0n1p1"
ROOT_MOUNT_PATH="/mnt"

# Requires NixOS live iso
nixos-enter --root "ROOT_MOUNT_PATH"

# Manual chroot
mount /dev/"$ROOT_DEVICE" "$ROOT_MOUNT_PATH"
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys
chroot /mnt /nix/var/nix/profiles/system/activate
chroot /mnt /run/current-system/sw/bin/bash
