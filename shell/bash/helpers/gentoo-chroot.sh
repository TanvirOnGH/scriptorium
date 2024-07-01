#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible
# shellcheck disable=SC2034,SC1001

# Gentoo Linux chrooter

mount_dir="/mnt/gentoo"
shell="/bin/bash"

# For capturing Bugs
# kills the script if anything returns false
set -e

# Check for root
checkRoot() {
	if ! [ "$(id -u)" = 0 ]; then
		echo "The Script needs to be executed as Root!"
		exit 13
	fi
}

# Check for $1
checkArg() {
	if [ -z "$1" ]; then
		echo "Please provide a root partition as an argument! [e.g: /dev/sda1]"
		exit 1
	fi
}

checkRoot
checkArg "$1"

root_partition="$1"

mkdir "$mount_dir"
mount "$root_partition" "$mount_dir"

(
	cd "$mount_dir"

	# The "--make-rslave" operations are needed for systemd support.
	mount --rbind /dev "./dev"
	mount --make-rslave "./dev"
	mount -t proc /proc "./proc"
	mount --rbind /sys "./sys"
	mount --make-rslave "./sys"
	mount --rbind /tmp "./tmp"
)

chroot "$mount_dir" "$shell"
