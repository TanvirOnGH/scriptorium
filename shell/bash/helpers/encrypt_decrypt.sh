#!/bin/sh

encrypt_file() {
    local file_to_encrypt="$1"
    local encrypted_file="$file_to_encrypt.gpg"

    if [ ! -f "$file_to_encrypt" ]; then
        echo "Error: File '$file_to_encrypt' not found."
        exit 1
    fi

    echo -n "Enter passphrase for encryption: "
    read -s passphrase
    echo

    if ! gpg --batch --yes --passphrase "$passphrase" -c "$file_to_encrypt"; then
        echo "Error: Encryption failed."
        exit 1
    fi

    echo "File encrypted successfully: $encrypted_file"
}

decrypt_file() {
    local encrypted_file="$1"

    if [ ! -f "$encrypted_file" ]; then
        echo "Error: Encrypted file '$encrypted_file' not found."
        exit 1
    fi

    echo -n "Enter passphrase for decryption: "
    read -s passphrase
    echo

    if ! gpg --batch --yes --passphrase "$passphrase" -o "${encrypted_file%.gpg}" -d "$encrypted_file"; then
        echo "Error: Decryption failed."
        exit 1
    fi

    echo "File decrypted successfully: ${encrypted_file%.gpg}"
}

if ! command -v gpg >/dev/null; then
    echo "Error: GPG (GNU Privacy Guard) is not installed. Please install it first."
    exit 1
fi

if [ $# -ne 2 ]; then
    echo "Usage: $0 [-e|--encrypt|encrypt] <file> | [-d|--decrypt|decrypt] <file.gpg>"
    exit 1
fi

command="$1"
file="$2"

case "$command" in
-e | --encrypt | encrypt)
    encrypt_file "$file"
    ;;
-d | --decrypt | decrypt)
    decrypt_file "$file"
    ;;
*)
    echo "Error: Invalid command: $command"
    exit 1
    ;;
esac
