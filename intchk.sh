#!/bin/bash

# Unified file/directory integrity checker using cryptographic hashes.
# This script works on a single file, a whole directory, or verifies a single file's hash.
#
# Usage:
#   For a single file:     ./intchk.sh baseline my_file.txt
#   For a directory:       ./intchk.sh -d baseline my_directory/
#   For hash verification: ./intchk.sh verify-hash my_file.txt <hash_value>
#
# Optional Flags:
#   -d, --directory: Perform the check on a whole directory.
#   -a, --algorithm <algo>: Specify the hashing algorithm (e.g., md5, sha1, sha256).
#
# Examples:
#   Verify a file's hash with a given value:
#   ./intchk.sh verify-hash my_file.zip d41d8cd98f00b204e9800998ecf8427e
#
#   Verify with SHA512 algorithm:
#   ./intchk.sh -a sha512 verify-hash my_file.zip <sha512_hash_value>

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS] [ACTION] <path> [hash_value]"
    echo ""
    echo "Options:"
    echo "  -d, --directory        Perform the check on a whole directory instead of a single file."
    echo "  -a, --algorithm <algo> Specify the hashing algorithm (e.g., md5, sha1, sha256, sha512)."
    echo "                         Default is sha256."
    echo "  -h, --help             Display this help message and exit."
    echo ""
    echo "Actions:"
    echo "  baseline               Generates a baseline hash for the specified path."
    echo "  verify                 Compares the current hash with a previously created baseline."
    echo "  verify-hash            Generates a hash of a file and compares it to a provided hash value."
    echo ""
    echo "Examples:"
    echo "  Single file:    ./intchk.sh baseline my_file.txt"
    echo "  Directory:      ./intchk.sh -d verify my_directory/"
    echo "  Verify a hash:  ./intchk.sh verify-hash my_file.zip <provided_hash>"
    echo "  Verify with SHA1: ./intchk.sh -a sha1 verify-hash my_file.zip <provided_sha1_hash>"
    exit 1
}

# --- Argument Parsing ---
IS_DIRECTORY=false
ALGORITHM="sha256"
declare -a ARGS=()

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--directory) IS_DIRECTORY=true; shift ;;
        -a|--algorithm) ALGORITHM="$2"; shift; shift ;;
        -h|--help) usage ;;
        *) ARGS+=("$1"); shift ;;
    esac
done

set -- "${ARGS[@]}"

# Check for correct number of remaining arguments based on action
ACTION="$1"
if [ "$ACTION" == "verify-hash" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Error: 'verify-hash' action requires a file path and a hash value."
        usage
    fi
else
    if [ "$#" -ne 2 ]; then
        echo "Error: Incorrect number of arguments for action '$ACTION'."
        usage
    fi
fi

TARGET_PATH="$2"

# Function to generate a baseline for a single file
generate_file_baseline() {
    HASH_FILE="${TARGET_PATH}.sha256"
    echo "Generating baseline hash for file '$TARGET_PATH'..."
    if [ ! -f "$TARGET_PATH" ]; then
        echo "Error: File '$TARGET_PATH' does not exist."
        exit 1
    fi
    sha256sum "$TARGET_PATH" > "$HASH_FILE"
    echo "Baseline created successfully: '$HASH_FILE'"
}

# Function to verify integrity for a single file
verify_file_integrity() {
    HASH_FILE="${TARGET_PATH}.sha256"
    echo "Verifying integrity of file '$TARGET_PATH'..."
    if [ ! -f "$HASH_FILE" ]; then
        echo "Error: Baseline file '$HASH_FILE' not found. Please create one first."
        exit 1
    fi
    if sha256sum -c "$HASH_FILE" >/dev/null 2>&1; then
        echo "Integrity check: OK"
    else
        echo "Integrity check: MODIFIED"
    fi
}

# Function to generate a baseline for a directory
generate_dir_baseline() {
    HASH_FILE="${TARGET_PATH%/}/integrity_hashes.sha256"
    echo "Generating baseline hashes for directory '$TARGET_PATH'..."
    if [ ! -d "$TARGET_PATH" ]; then
        echo "Error: Directory '$TARGET_PATH' does not exist or is not a directory."
        exit 1
    fi
    find "$TARGET_PATH" -type f -print0 | xargs -0 sha256sum > "$HASH_FILE" 2>/dev/null
    if [ ! -s "$HASH_FILE" ]; then
        echo "Error: Failed to create or populate '$HASH_FILE'. Check directory permissions."
        exit 1
    fi
    echo "Baseline created successfully: '$HASH_FILE'"
}

# Function to verify integrity for a directory
verify_dir_integrity() {
    HASH_FILE="${TARGET_PATH%/}/integrity_hashes.sha256"
    echo "Verifying integrity of directory '$TARGET_PATH'..."
    if [ ! -f "$HASH_FILE" ]; then
        echo "Error: Baseline file '$HASH_FILE' not found. Please create one first."
        exit 1
    fi
    if sha256sum -c "$HASH_FILE" >/dev/null 2>&1; then
        echo "All files OK."
    else
        echo "Some files have been modified or are missing."
    fi
}

# New function to verify a hash against a provided value
verify_provided_hash() {
    local PROVIDED_HASH="$3"
    local HASH_TOOL="${ALGORITHM}sum"

    echo "Verifying hash of '$TARGET_PATH' with '$ALGORITHM'..."
    if ! command -v "$HASH_TOOL" &>/dev/null; then
        echo "Error: '$HASH_TOOL' command not found. Please install it."
        exit 1
    fi

    local COMPUTED_HASH=$("$HASH_TOOL" "$TARGET_PATH" | awk '{print $1}')
    if [[ "$COMPUTED_HASH" == "$PROVIDED_HASH" ]]; then
        echo "Hash verification: OK. The file is authentic."
    else
        echo "Hash verification: FAILED. The file may be corrupted or tampered with."
    fi
}

# --- Main Logic ---
case "$ACTION" in
    baseline)
        if "$IS_DIRECTORY"; then
            generate_dir_baseline
        else
            generate_file_baseline
        fi
        ;;
    verify)
        if "$IS_DIRECTORY"; then
            verify_dir_integrity
        else
            verify_file_integrity
        fi
        ;;
    verify-hash)
        verify_provided_hash "$@"
        ;;
    *)
        usage
        ;;
esac