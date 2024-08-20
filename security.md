# Security Policy

## Hash Algorithms

This repository does not use or prefer insecure hash algorithms like MD5 or SHA1 because:

- **MD5**: The MD5 hash algorithm is considered insecure and should not be used for cryptographic purposes. It is susceptible to collision attacks, where malicious actors can craft inputs that produce the same hash value. This can lead to unauthorized access, data breaches, or other vulnerabilities.

- **SHA1**: SHA1 is not collision resistant and is therefore not suitable as a cryptographic signature.

### Recommendation

Use SHA256 or SHA3 instead.

Avoid using the MD5 hash algorithm for cryptographic purposes. Instead, use more secure alternatives like SHA-256 or SHA-512. If you must use MD5, ensure that it's not used for security-critical operations and that it's not relied upon for authentication or authorization.
