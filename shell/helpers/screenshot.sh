#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible
# shellcheck disable=SC1091

# Exit the script if anything fails
set -e

. ./lib/stdio.sh
. ../util/package-management.sh

pre_checks() {
    package_manager_update

    if ! command_exists curl; then
        package_manager_install curl
    fi

    if ! command_exists scrot; then
        package_manager_install scrot
    fi

    if [ -z "$DISPLAY" ]; then
        die 1 "DISPLAY variable is not set"
    fi
}

upload() {
    case "$1" in
    bashupload) curl bashupload.com -T "$2" ;;
    keep) curl --upload-file "$2" https://free.keep.sh ;;
    transfer) curl --upload-file "$2" https://transfer.sh/"$2" ;;
    *) die 1 "Invalid uploader" ;;
    esac
}

run() {
    pre_checks

    scrot "$1"
    upload "$2" "$1"
}

if [ "$#" -eq 0 ]; then
    println "Usage: <filename> <uploader>"
    exit 1
fi

run "$1" "$2"
