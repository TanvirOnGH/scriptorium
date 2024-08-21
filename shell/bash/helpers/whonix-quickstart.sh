#!/bin/sh

# Reference: <https://www.whonix.org/wiki/KVM>

WHONIX_VERSION="17.2.0.7"
DIRECTORY="/home/user/downloads"
IMAGE_FILE="Whonix-Xfce-$WHONIX_VERSION.Intel_AMD64.qcow2.libvirt.xz"

cd "$DIRECTORY" || handle_error "Failed to change directory to $DIRECTORY"

handle_error() {
	echo "Error: $1"
	exit 1
}

remove_whonix() {
	sudo virsh undefine Whonix-Workstation --remove-all-storage || handle_error "Failed to remove Whonix VMs"
	sudo virsh undefine Whonix-Gateway --remove-all-storage || handle_error "Failed to remove Whonix VMs"
}

check_whonix() {
	if [ -f /var/lib/libvirt/images/Whonix-Gateway.qcow2 ] || [ -f /var/lib/libvirt/images/Whonix-Workstation.qcow2 ]; then
		echo "Whonix VMs already exist. Do you want to remove them? (y/n)" || handle_error "Failed to prompt user"
		read -r response
		if [ "$response" = "y" ]; then
			remove_whonix || handle_error "Failed to remove Whonix VMs"
		fi
	fi
}

download_files() {
	if [ -f "$IMAGE_FILE" ]; then
		echo "Image file $IMAGE_FILE already exists. Skipping download."
	else
		wget "https://download.whonix.org/libvirt/$WHONIX_VERSION/$IMAGE_FILE" || handle_error "Failed to download $IMAGE_FILE"
	fi

	if [ -f "derivative.asc" ]; then
		echo "GPG key file derivative.asc already exists. Deleting it."
		rm -i derivative.asc || handle_error "Failed to delete existing GPG key file"
	fi

	wget https://www.whonix.org/keys/derivative.asc || handle_error "Failed to download GPG key"

	if [ -f "Whonix-Xfce-$WHONIX_VERSION.Intel_AMD64.qcow2.libvirt.xz.asc" ]; then
		echo "Image signature file Whonix-Xfce-$WHONIX_VERSION.Intel_AMD64.qcow2.libvirt.xz.asc already exists. Deleting it."
		rm -i Whonix-Xfce-$WHONIX_VERSION.Intel_AMD64.qcow2.libvirt.xz.asc || handle_error "Failed to delete existing image signature file"
	fi

	wget https://download.whonix.org/libvirt/$WHONIX_VERSION/Whonix-Xfce-$WHONIX_VERSION.Intel_AMD64.qcow2.libvirt.xz.asc || handle_error "Failed to download image signature"
}

verify_image() {
	gpg --keyid-format long --import --import-options show-only --with-fingerprint derivative.asc || handle_error "Failed to import GPG key"
	echo "916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA:6:" | gpg --import-ownertrust || handle_error "Failed to configure GPG trust level"
	gpg --import derivative.asc || handle_error "Failed to import GPG key"
	gpg --verify-options show-notations --verify Whonix-*.libvirt.xz.asc Whonix-*.libvirt.xz || handle_error "Image verification failed"
}

configure_networking() {
	sudo virsh -c qemu:///system net-autostart default
	sudo virsh -c qemu:///system net-start default
}

delete_existing_networks() {
	sudo virsh -c qemu:///system net-destroy Whonix-External || echo "Failed to destroy Whonix-External network, it may not exist"
	sudo virsh -c qemu:///system net-undefine Whonix-External || echo "Failed to undefine Whonix-External network, it may not exist"
	sudo virsh -c qemu:///system net-destroy Whonix-Internal || echo "Failed to destroy Whonix-Internal network, it may not exist"
	sudo virsh -c qemu:///system net-undefine Whonix-Internal || echo "Failed to undefine Whonix-Internal network, it may not exist"
}

decompress_image() {
	tar -xvf Whonix*.libvirt.xz || handle_error "Failed to decompress Whonix image"
}

accept_license() {
	touch WHONIX_BINARY_LICENSE_AGREEMENT_accepted || handle_error "Failed to accept license"
}

import_vm_templates() {
	sudo virsh -c qemu:///system net-define Whonix_external*.xml || handle_error "Failed to define Whonix-External network"
	sudo virsh -c qemu:///system net-define Whonix_internal*.xml || handle_error "Failed to define Whonix-Internal network"
	sudo virsh -c qemu:///system net-autostart Whonix-External || handle_error "Failed to autostart Whonix-External network"
	sudo virsh -c qemu:///system net-start Whonix-External || handle_error "Failed to start Whonix-External network"
	sudo virsh -c qemu:///system net-autostart Whonix-Internal || handle_error "Failed to autostart Whonix-Internal network"
	sudo virsh -c qemu:///system net-start Whonix-Internal || handle_error "Failed to start Whonix-Internal network"
	sudo virsh -c qemu:///system define Whonix-Gateway*.xml || handle_error "Failed to define Whonix-Gateway VM"
	sudo virsh -c qemu:///system define Whonix-Workstation*.xml || handle_error "Failed to define Whonix-Workstation VM"
}

move_images() {
	sudo mv Whonix-Gateway*.qcow2 /var/lib/libvirt/images/Whonix-Gateway.qcow2 || handle_error "Failed to move Whonix-Gateway image"
	sudo mv Whonix-Workstation*.qcow2 /var/lib/libvirt/images/Whonix-Workstation.qcow2 || handle_error "Failed to move Whonix-Workstation image"
}

cleanup() {
	rm -riv Whonix* || handle_error "Failed to clean up Whonix files"
	rm -riv WHONIX* || handle_error "Failed to clean up WHONIX files"
	rm -iv derivative.asc || handle_error "Failed to remove GPG key file"
}

start_vms() {
	sudo virsh start Whonix-Gateway || handle_error "Failed to start Whonix-Gateway VM"
	sudo virsh start Whonix-Workstation || handle_error "Failed to start Whonix-Workstation VM"
}

main() {
	if [ $# -eq 0 ]; then
		check_whonix
		download_files
		verify_image
		configure_networking
		delete_existing_networks
		decompress_image
		accept_license
		import_vm_templates
		move_images
		cleanup
		start_vms
	else
		for arg in "$@"; do
			case $arg in
			check_whonix) check_whonix ;;
			download_files) download_files ;;
			verify_image) verify_image ;;
			configure_networking) configure_networking ;;
			delete_existing_networks) delete_existing_networks ;;
			decompress_image) decompress_image ;;
			accept_license) accept_license ;;
			import_vm_templates) import_vm_templates ;;
			move_images) move_images ;;
			cleanup) cleanup ;;
			start_vms) start_vms ;;
			remove_whonix) remove_whonix ;;
			*) echo "Unknown function: $arg" ;;
			esac
		done
	fi
}

main "$@"
