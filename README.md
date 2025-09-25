Unified File and Directory Integrity Checker
Project Overview
This is a versatile command-line tool for performing cryptographic integrity checks on files and directories. Implemented as a single Bash script, it provides a simple yet powerful solution for detecting unauthorized changes, verifying downloaded files, and ensuring data security. The tool is designed to be user-friendly, with clear command-line arguments and support for multiple hashing algorithms.

Key Features
Unified Functionality: Handles both single files and entire directories from one script.

Multiple Modes:

Baseline Generation: Creates a baseline of cryptographic hashes for a file or a directory.

Integrity Verification: Compares current file states against a saved baseline to detect changes.

Hash Verification: Verifies a downloaded file's integrity against a hash value provided by the source.

Cryptographic Security: Uses the secure SHA256 algorithm by default, with support for other algorithms like MD5 and SHA1.

Intuitive Interface: Utilizes simple command-line flags and arguments (-d, -a) for straightforward operation.

Getting Started
Prerequisites
To run this script, you need a Linux environment with the following core utilities installed:

Bash

sha256sum, sha1sum, md5sum

find, grep, awk, comm

Installation
Save the script: Save the provided Bash script as intchk.sh.

Make it executable:

chmod +x intchk.sh

Usage
The script uses the following format: intchk.sh [OPTIONS] [ACTION] <path> [hash_value]

1. Baseline Generation (baseline)
Creates a hash file for a file or a directory.

For a single file:

./intchk.sh baseline my_file.txt

This will create a my_file.txt.sha256 file.

For a directory: Use the -d or --directory flag.

./intchk.sh -d baseline my_directory/

This will create an integrity_hashes.sha256 file inside my_directory/.

2. Integrity Verification (verify)
Checks files against a previously generated baseline.

For a single file:

./intchk.sh verify my_file.txt

Output: Integrity check: OK or Integrity check: MODIFIED.

For a directory:

./intchk.sh -d verify my_directory/

Output: All files OK. or Some files have been modified or are missing.

3. Hash Verification (verify-hash)
Verifies a file against a hash value you provide. You can specify the algorithm with the -a flag.

Using default SHA256:

./intchk.sh verify-hash downloaded_file.zip <provided_sha256_hash>

Using a different algorithm (e.g., MD5):

./intchk.sh -a md5 verify-hash downloaded_file.zip <provided_md5_hash>

Help Section
For a quick reference on all commands and options, run the help flag:

./intchk.sh -h
