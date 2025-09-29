#!/bin/bash

# Unified file/directory integrity checker using cryptographic hashes.
# Supports multiple algorithms (md5, sha1, sha256, sha512).
#
# Usage:
#   For a single file:     ./intchk.sh baseline my_file.txt
#   For a directory:       ./intchk.sh -d baseline my_directory/
#   For hash verification: ./intchk.sh verify-hash my_file.txt <hash_value>
#
# Options:
#   -d, --directory        Perform the check on a whole directory.
#   -a, --algorithm <algo> Specify the hashing algorithm (default: sha256).
#   -h, --help             Show help.
#
# Examples:
#   ./intchk.sh baseline myfile.txt
#   ./intchk.sh -d verify mydir/
#   ./intchk.sh -a sha1 verify-hash myfile.zip <sha1_hash>

# --- Usage function ---
usage() {
    echo "Usage: $0 [OPTIONS] [ACTION] <path> [hash_value]"
    echo ""
    echo "Options:"
    echo "  -d, --directory        Perform the check on a whole directory."
    echo "  -a, --algorithm <algo> Specify the hashing algorithm (md5, sha1, sha256, sha512)."
    echo "                         Default is sha256."
    echo "  -h, --help             Display this help message."
    echo ""
    echo "Actions:"
    echo "  baseline               Generate a baseline hash for the specified path."
    echo "  verify                 Compare current hash with a baseline."
    echo "  verify-hash            Compare file hash with a provided value."
    echo ""
    echo "Examples:"
    echo "  ./intchk.sh baseline myfile.txt"
    echo "  ./intchk.sh -d verify mydir/"
    echo "  ./intchk.sh -a sha512 verify-hash myfile.zip <sha512_hash>"
    exit 1
}

# --- Argument parsing ---
IS_DIRECTORY=false
ALGORITHM="sha256"
declare -a ARGS=()

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--directory) IS_DIRECTORY=true; shift ;;
        -a|--algorithm) ALGORITHM="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) ARGS+=("$1"); shift ;;
    esac
done

set -- "${ARGS[@]}"

# Validate action/args
ACTION="$1"
if [ "$ACTION" == "verify-hash" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Error: 'verify-hash' requires a file path and a hash value."
        usage
    fi
else
    if [ "$#" -ne 2 ]; then
        echo "Error: Incorrect number of arguments for action '$ACTION'."
        usage
    fi
fi

TARGET_PATH="$2"
HASH_TOOL="${ALGORITHM}sum"

# Check if algorithm tool exists
if ! command -v "$HASH_TOOL" &>/dev/null; then
    echo "Error: Hash tool '$HASH_TOOL' not found. Please install it or use another algorithm."
    exit 1
fi

# --- Functions ---

# Single file baseline
generate_file_baseline() {
    HASH_FILE="${TARGET_PATH}.${ALGORITHM}"
    echo "Generating baseline hash for '$TARGET_PATH' using $ALGORITHM..."
    if [ ! -f "$TARGET_PATH" ]; then
        echo "Error: File '$TARGET_PATH' not found."
        exit 1
    fi
    $HASH_TOOL "$TARGET_PATH" > "$HASH_FILE"
    echo "Baseline created: $HASH_FILE"
}

# Verify single file
verify_file_integrity() {
    HASH_FILE="${TARGET_PATH}.${ALGORITHM}"
    echo "Verifying integrity of '$TARGET_PATH'..."
    if [ ! -f "$HASH_FILE" ]; then
        echo "Error: Baseline '$HASH_FILE' not found. Run baseline first."
        exit 1
    fi
    if $HASH_TOOL -c "$HASH_FILE" >/dev/null 2>&1; then
        echo "Integrity check: OK"
    else
        echo "Integrity check: MODIFIED"
    fi
}

# Directory baseline
generate_dir_baseline() {
    HASH_FILE="${TARGET_PATH%/}/integrity_hashes.${ALGORITHM}"
    echo "Generating baseline for directory '$TARGET_PATH'..."
    if [ ! -d "$TARGET_PATH" ]; then
        echo "Error: Directory '$TARGET_PATH' not found."
        exit 1
    fi
    # Exclude the baseline file itself and store relative paths
    (cd "$TARGET_PATH" && \
     find . -type f ! -name "integrity_hashes.${ALGORITHM}" -printf '%P\0' | \
     xargs -0 $HASH_TOOL) > "$HASH_FILE"
    if [ ! -s "$HASH_FILE" ]; then
        echo "Error: Failed to write baseline. Check permissions."
        exit 1
    fi
    echo "Baseline created: $HASH_FILE"
}

# Verify directory
verify_dir_integrity() {
    HASH_FILE="${TARGET_PATH%/}/integrity_hashes.${ALGORITHM}"
    echo "Verifying directory '$TARGET_PATH'..."
    if [ ! -f "$HASH_FILE" ]; then
        echo "Error: Baseline '$HASH_FILE' not found. Run baseline first."
        exit 1
    fi
    # Run verification inside the target dir
    (cd "$TARGET_PATH" && $HASH_TOOL -c "$(basename "$HASH_FILE")") >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "All files OK."
    else
        echo "Some files modified or missing."
    fi
}

# Verify against provided hash
verify_provided_hash() {
    local PROVIDED_HASH="$3"
    echo "Verifying hash of '$TARGET_PATH' with $ALGORITHM..."
    if [ ! -f "$TARGET_PATH" ]; then
        echo "Error: File '$TARGET_PATH' not found."
        exit 1
    fi
    local COMPUTED_HASH=$($HASH_TOOL "$TARGET_PATH" | awk '{print $1}')
    if [[ "$COMPUTED_HASH" == "$PROVIDED_HASH" ]]; then
        echo "Hash verification: OK (authentic)"
    else
        echo "Hash verification: FAILED (tampered or corrupted)"
    fi
}

# --- Main ---
case "$ACTION" in
    baseline)
        if $IS_DIRECTORY; then
            generate_dir_baseline
        else
            generate_file_baseline
        fi
        ;;
    verify)
        if $IS_DIRECTORY; then
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
