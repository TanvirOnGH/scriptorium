#!/bin/sh

# Get the list of keygrips for all secret keys
keygrips=$(gpg --list-secret-keys --with-keygrip | grep Keygrip | awk '{print $3}')

# List the files in private-keys-v1.d
files=$(ls ~/.gnupg/private-keys-v1.d/)

echo "Keygrips of existing private keys:"
echo "$keygrips"
echo ""
echo "Files in private-keys-v1.d:"
echo "$files"
echo ""

echo "Potential obsolete files in private-keys-v1.d:"
for file in $files; do
    if ! echo "$keygrips" | grep -q "$file"; then
        echo "$file"
    fi
done

echo ""
echo "Review the above list carefully before removing any files."
