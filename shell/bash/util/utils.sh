#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible

check_root() {
	if [ "$(id -u)" != "0" ]; then
		die 1 "The script needs to be executed as root!" 1>&2
	fi
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}
