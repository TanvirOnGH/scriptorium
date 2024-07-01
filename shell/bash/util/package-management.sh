#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible

detect_package_manager() {
	if command_exists apt; then
		package_manager_frontend="apt"
	elif command_exists dnf; then
		package_manager_frontend="dnf"
	elif command_exists pacman; then
		package_manager_frontend="pacman"
	elif command_exists nix; then
		package_manager_frontend="nix"
	elif command_exists brew; then
		package_manager_frontend="brew"
	elif command_exists apk; then
		package_manager_frontend="apk"
	elif command_exists emerge; then
		package_manager_frontend="portage"
	elif command_exists cave; then
		package_manager_frontend="cave"
	else
		die 1 "No package manager found!"
	fi
}

detect_package_manager

package_manager_update() {
	case "$package_manager_frontend" in
	apt)
		apt update
		;;
	dnf)
		dnf update -y
		;;
	pacman)
		unimplemented
		;;
	nix)
		nix-channel --update
		;;
	brew)
		brew update
		;;
	apk)
		apk update
		;;
	portage)
		emerge --sync --quiet
		;;
	cave)
		cave sync
		;;
	*)
		die 1 "Error trying to update package repositories"
		;;
	esac
}

package_manager_upgrade() {
	case "$package_manager_frontend" in
	apt)
		apt upgrade -y
		;;
	dnf)
		dnf upgrade -y
		;;
	pacman)
		pacman -Syu --noconfirm
		;;
	nix)
		nix-env -u
		;;
	brew)
		brew upgrade
		;;
	apk)
		apk upgrade
		;;
	portage)
		emerge -quDN world
		;;
	cave)
		cave resolve -qx world
		;;
	*)
		die 1 "Error trying to upgrade packages"
		;;
	esac
}

package_manager_install() {
	case "$package_manager_frontend" in
	apt)
		apt install -y "$1"
		;;
	dnf)
		dnf install -y "$1"
		;;
	pacman)
		pacman -S --noconfirm "$1"
		;;
	nix)
		nix-env -i "$1"
		;;
	brew)
		brew install "$1"
		;;
	apk)
		apk add "$1"
		;;
	portage)
		emerge -q "$1"
		;;
	cave)
		cave resolve -qx "$1"
		;;
	*)
		die 1 "Error trying to install $1"
		;;
	esac
}

package_manager_uninstall() {
	case "$package_manager_frontend" in
	apt)
		apt remove -y "$1"
		;;
	dnf)
		dnf remove -y "$1"
		;;
	pacman)
		pacman -R --noconfirm "$1"
		;;
	nix)
		nix-env -e "$1"
		;;
	brew)
		brew uninstall "$1"
		;;
	apk)
		apk del "$1"
		;;
	portage)
		emerge -C "$1"
		;;
	cave)
		cave remove -x "$1"
		;;
	*)
		die 1 "Error trying to uninstall $1"
		;;
	esac
}
