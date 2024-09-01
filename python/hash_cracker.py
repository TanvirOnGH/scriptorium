#!/usr/bin/env python3

import hashlib
import itertools
import argparse

# Supported hash functions and their corresponding hashlib functions
HASH_FUNCTIONS = {
    "lm": "lm_hash",
    "ntlm": "ntlm_hash",
    "md2": "md2_hash",
    "md4": "md4",
    "md5": "md5",
    "md5-half": "md5_half",
    "sha1": "sha1",
    "sha224": "sha224",
    "sha256": "sha256",
    "sha384": "sha384",
    "sha512": "sha512",
    "ripemd160": "ripemd160",
    "whirlpool": "whirlpool",
    "mysql4.1": "mysql4_1",
    "qubesv3.1": "qubesv3_1",
}


def crack_hashes(hashes, algorithm, wordlist):
    """Crack given hashes using the provided wordlist and hashing algorithm."""
    cracked = {}
    try:
        for word in wordlist:
            word = word.strip()
            generated_hash = getattr(hashlib, algorithm)(word.encode()).hexdigest()

            if generated_hash in hashes:
                cracked[generated_hash] = word
                print(f"Cracked: {generated_hash} => {word}")
    except KeyboardInterrupt:
        print("\n[-] Exiting...")
    return cracked


def main():
    parser = argparse.ArgumentParser(description="Free Password Hash Cracker")

    parser.add_argument(
        "-i", "--input", type=str, required=True, help="Input file with hashes to crack"
    )
    parser.add_argument(
        "-w", "--wordlist", type=str, required=True, help="Wordlist to use for cracking"
    )

    args = parser.parse_args()

    # Load the hash input file and wordlist
    with open(args.input, "r") as f:
        hashes = set([line.strip() for line in f])

    with open(args.wordlist, "r") as f:
        wordlist = f.readlines()

    cracked = crack_hashes(hashes, "md5", wordlist)


if __name__ == "__main__":
    main()
