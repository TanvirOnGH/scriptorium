#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible
# shellcheck disable=SC2034,SC1001

# Bedrock Linux Stratum chrooter

# Invoke with root device, mount point, stratum name and shell path.
# E.g: "script.sh /dev/sda1 /mnt gentoo /bin/bash"

# For capturing Bugs
# kills the script if anything returns false
set -e

# Check for root
checkRoot() {
    if ! [ "$(id -u)" = 0 ]; then
        echo "The Script needs to be executed as Root/Superuser!"
        exit 13
    fi

}

checkRoot

mount "$1" "$2"

# The "--make-rslave" operations are needed for systemd support.
mount --rbind /dev "$2/bedrock/strata/$3/dev"
mount --make-rslave "$2/bedrock/strata/$3/dev"
mount -t proc /proc "$2/bedrock/strata/$3/proc"
mount --rbind /sys "$2/bedrock/strata/$3/sys"
mount --make-rslave "$2/bedrock/strata/$3/sys"
mount --rbind /tmp "$2/bedrock/strata/$3/tmp"

chroot "$2/bedrock/strata/$3" "$4"
