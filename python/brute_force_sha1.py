import itertools
import hashlib

def brute_force_sha1():
    characters = '0123456789abcdef'
    for combination in itertools.product(characters, repeat=4):
        short_hash = ''.join(combination)
        full_hash = hashlib.sha1(short_hash.encode()).hexdigest()
        print(f"Short hash: {short_hash}, Full SHA-1: {full_hash}")

if __name__ == "__main__":
    brute_force_sha1()
