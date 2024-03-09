#!/bin/sh

tar -xvf Whonix*.libvirt.xz
touch WHONIX_BINARY_LICENSE_AGREEMENT_accepted

sudo virsh -c qemu:///system net-define Whonix_external*.xml
sudo virsh -c qemu:///system net-define Whonix_internal*.xml

sudo virsh -c qemu:///system net-autostart Whonix-External
sudo virsh -c qemu:///system net-start Whonix-External
sudo virsh -c qemu:///system net-autostart Whonix-Internal
sudo virsh -c qemu:///system net-start Whonix-Internal

sed -i 's/type='"'"'kvm'"'"'/type='"'"'qemu'"'"'/g' Whonix-Gateway*.xml
sed -i 's/type='"'"'kvm'"'"'/type='"'"'qemu'"'"'/g' Whonix-Workstation*.xml

sudo virsh -c qemu:///system define Whonix-Gateway*.xml
sudo virsh -c qemu:///system define Whonix-Workstation*.xml
