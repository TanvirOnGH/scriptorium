#!/bin/sh

echo "Listing all SSH keys:"
ls ~/.ssh/id_*

echo ""
echo "Listing all GPG public keys:"
gpg --list-keys

echo ""
echo "Listing all GPG private keys:"
gpg --list-secret-keys

echo ""
echo "Do you want to remove any SSH keys? (y/n)"
read -r ssh_response
if [ "$ssh_response" = "y" ]; then
	echo "Enter the name of the SSH key to remove (e.g., id_rsa):"
	read -r ssh_key
	rm ~/.ssh/"$ssh_key" ~/.ssh/"$ssh_key".pub
	echo "Removed SSH key: $ssh_key"
fi

echo ""
echo "Do you want to remove any GPG keys? (y/n)"
read -r gpg_response
if [ "$gpg_response" = "y" ]; then
	echo "Enter the ID of the GPG key to remove (both public and private):"
	read -r gpg_key_id
	gpg --delete-secret-key "$gpg_key_id"
	gpg --delete-key "$gpg_key_id"
	echo "Removed GPG key: $gpg_key_id"
fi

echo "Key management completed."
