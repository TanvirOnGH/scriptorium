#!/bin/sh

USE_NIX_SHELL=true

run_command() {
    local cmd=$1
    if $USE_NIX_SHELL; then
        nix-shell -p hdparm --run "$cmd"
    else
        eval "$cmd"
    fi
}

check_status() {
    for disk in $(lsblk -d -n -o NAME,TYPE | grep disk | awk '{print $1}'); do
        if [[ -e /sys/class/block/$disk/device ]]; then
            local link=$(readlink -f /sys/class/block/$disk/device)
            if [[ $link == *"ata"* ]]; then
                run_command "sudo hdparm -C /dev/$disk"
            fi
        fi
    done
}

power_off() {
    for disk in $(lsblk -d -n -o NAME,TYPE | grep disk | awk '{print $1}'); do
        if [[ -e /sys/class/block/$disk/device ]]; then
            local link=$(readlink -f /sys/class/block/$disk/device)
            if [[ $link == *"ata"* ]]; then
                run_command "sudo hdparm -Y /dev/$disk"
                run_command "sudo hdparm -C /dev/$disk"
            fi
        fi
    done
}

if [ "$1" == "--status" ]; then
    check_status
    exit 0
fi

if [ "$1" == "--poweroff" ]; then
    echo "The following SATA HDDs and SSDs will be powered off:"
    for disk in $(lsblk -d -n -o NAME,MODEL | grep disk | awk '{print $1}'); do
        if [[ -e /sys/class/block/$disk/device ]]; then
            local link=$(readlink -f /sys/class/block/$disk/device)
            if [[ $link == *"ata"* ]]; then
                echo "/dev/$disk"
            fi
        fi
    done
    read -p "Are you sure you want to power off all detected SATA HDDs? (yes/no) " response
    if [ "$response" == "yes" ]; then
        power_off
    else
        echo "Operation cancelled."
    fi
    exit 0
fi

echo "Usage: $0 --status|--poweroff"
exit 1
