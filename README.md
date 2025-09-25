# 🛡️ Unified File and Directory Integrity Checker

![Bash](https://img.shields.io/badge/shell-bash-green)
![Status](https://img.shields.io/badge/status-stable-success)

A versatile **command-line tool** for performing cryptographic integrity checks on files and directories. Implemented as a single **Bash script**, it provides a simple yet powerful solution for detecting unauthorized changes, verifying downloaded files, and ensuring data security.

---

## 📚 Table of Contents

- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Baseline Generation](#1-baseline-generation-baseline)
  - [Integrity Verification](#2-integrity-verification-verify)
  - [Hash Verification](#3-hash-verification-verify-hash)
- [Help Section](#help-section)
- [Examples](#examples)
- [Contributing](#contributing)
- [Contact](#contact)

---

## 📖 Project Overview <a id="project-overview"></a>

This script is designed to be **user-friendly and secure**:

- Detects unauthorized changes to files/directories
- Verifies downloaded files against trusted hash values
- Supports multiple hashing algorithms
- Provides a single, unified interface with intuitive flags and arguments

---

## ✅ Key Features <a id="key-features"></a>

- **Unified Functionality**: One script for both file and directory integrity checks.  
- **Multiple Modes**:
  - **Baseline Generation** – create a baseline of cryptographic hashes.  
  - **Integrity Verification** – compare current file states against the baseline.  
  - **Hash Verification** – check a downloaded file against a known hash.  
- **Cryptographic Security**: Defaults to `SHA256`, with optional support for `MD5` and `SHA1`.  
- **Intuitive Interface**: Simple command-line arguments (`-d`, `-a`) for straightforward operation.  

---

## 🚀 Getting Started <a id="getting-started"></a>

### 🔧 Prerequisites <a id="prerequisites"></a>

A Linux/Unix environment with the following tools installed:

- `bash`
- `sha256sum`, `sha1sum`, `md5sum`
- `find`, `grep`, `awk`, `comm`

### 📦 Installation <a id="installation"></a>

Save the script as `intchk.sh`:

```bash
chmod +x intchk.sh
```

---

## 💻 Usage <a id="usage"></a>

The general syntax:

```bash
./intchk.sh [OPTIONS] [ACTION] <path> [hash_value]
```

### 1. Baseline Generation (`baseline`) <a id="1-baseline-generation-baseline"></a>

Generate a hash file for future verification.

**For a single file:**

```bash
./intchk.sh baseline my_file.txt
```

👉 Creates `my_file.txt.sha256`.

**For a directory (recursive):**

```bash
./intchk.sh -d baseline my_directory/
```

👉 Creates `integrity_hashes.sha256` inside `my_directory/`.

---

### 2. Integrity Verification (`verify`) <a id="2-integrity-verification-verify"></a>

Check files against a previously generated baseline.

**For a single file:**

```bash
./intchk.sh verify my_file.txt
```

Output:

```txt
Integrity check: OK
# or
Integrity check: MODIFIED
```

**For a directory:**

```bash
./intchk.sh -d verify my_directory/
```

Output:

```txt
All files OK.
# or
Some files have been modified or are missing.
```

---

### 3. Hash Verification (`verify-hash`) <a id="3-hash-verification-verify-hash"></a>

Verify a file against a known hash value.  
Default algorithm: **SHA256**.

**Example:**

```bash
./intchk.sh verify-hash downloaded_file.zip <provided_sha256_hash>
```

Using a different algorithm (e.g., MD5):

```bash
./intchk.sh -a md5 verify-hash downloaded_file.zip <provided_md5_hash>
```

---

## 🆘 Help Section <a id="help-section"></a>

For a quick reference of all options:

```bash
./intchk.sh -h
```

---

## 📂 Examples <a id="examples"></a>

### Generate baseline for project folder

```bash
./intchk.sh -d baseline ./project
```

Creates `./project/integrity_hashes.sha256`.

---

### Verify folder integrity later

```bash
./intchk.sh -d verify ./project
```

Example output:

```txt
File modified: ./project/config.json
File deleted: ./project/old.log
Integrity check summary: Some files have been modified or are missing.
```

---

### Verify a downloaded ISO file

```bash
./intchk.sh verify-hash ubuntu.iso e5b72f8f09fbd3e8a1ad9fa4cd4f49bbac3b...
```

Output:

```txt
Integrity check: OK
```

---

## 🤝 Contributing <a id="contributing"></a>

Contributions are welcome!  
Fork the repo, create a feature branch, and open a Pull Request.

---



## 📬 Contact <a id="contact"></a>

Maintainer: [Suraj Apar](https://github.com/surajapar)  
For issues, please open an [issue on GitHub](https://github.com/surajapar).


