#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible

check_network() {
    if ! command_exists ping; then
        die 1 "ping not found"
    fi

    # Internet check
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        die 1 "Failed to ping 8.8.8.8"
    fi

    # DNS check
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        die 1 "Failed to ping google.com"
    fi
}
