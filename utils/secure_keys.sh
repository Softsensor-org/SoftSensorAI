#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Encrypt/decrypt user API keys for secure storage
set -euo pipefail

USER_DIR="${DEVPILOT_USER_DIR:-$HOME/.devpilot}"
KEY_FILE="$USER_DIR/config/api_keys.env"
ENC_FILE="$USER_DIR/config/api_keys.env.enc"
KEY_ID_FILE="$USER_DIR/config/.keyid"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Encryption method selection
select_encryption_method() {
    echo "Select encryption method:"
    echo "  1) GPG (recommended if available)"
    echo "  2) OpenSSL (widely available)"
    echo "  3) Age (modern, simple)"
    read -p "Choice [1-3]: " method_choice

    case "$method_choice" in
        1) METHOD="gpg" ;;
        2) METHOD="openssl" ;;
        3) METHOD="age" ;;
        *) METHOD="openssl" ;;
    esac

    echo "$METHOD" > "$USER_DIR/config/.encryption_method"
}

# Get or set encryption method
get_method() {
    if [[ -f "$USER_DIR/config/.encryption_method" ]]; then
        cat "$USER_DIR/config/.encryption_method"
    else
        select_encryption_method
        cat "$USER_DIR/config/.encryption_method"
    fi
}

# Encrypt with GPG
encrypt_gpg() {
    local input="$1"
    local output="$2"

    # Check if user has GPG key
    if ! gpg --list-secret-keys "$USER@*" >/dev/null 2>&1; then
        echo -e "${YELLOW}[WARN]${NC} No GPG key found for $USER"
        echo "Creating GPG key..."
        gpg --batch --generate-key <<EOF
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: $USER
Name-Email: $USER@$(hostname)
Expire-Date: 1y
%no-protection
%commit
EOF
    fi

    # Get key ID
    KEY_ID=$(gpg --list-secret-keys --keyid-format=long "$USER@*" | grep sec | head -1 | awk '{print $2}' | cut -d'/' -f2)
    echo "$KEY_ID" > "$KEY_ID_FILE"

    # Encrypt file
    gpg --encrypt --recipient "$KEY_ID" --armor --output "$output" "$input"
    echo -e "${GREEN}[✓]${NC} Encrypted with GPG (Key: $KEY_ID)"
}

# Decrypt with GPG
decrypt_gpg() {
    local input="$1"
    local output="$2"

    gpg --decrypt --output "$output" "$input"
    echo -e "${GREEN}[✓]${NC} Decrypted with GPG"
}

# Encrypt with OpenSSL
encrypt_openssl() {
    local input="$1"
    local output="$2"

    # Use password-based encryption
    echo -e "${YELLOW}[!]${NC} Enter a password to encrypt your API keys"
    echo "    (You'll need this password to decrypt later)"

    openssl enc -aes-256-cbc -salt -pbkdf2 -in "$input" -out "$output"

    echo -e "${GREEN}[✓]${NC} Encrypted with OpenSSL AES-256"
}

# Decrypt with OpenSSL
decrypt_openssl() {
    local input="$1"
    local output="$2"

    echo "Enter decryption password:"
    openssl enc -aes-256-cbc -d -pbkdf2 -in "$input" -out "$output"

    echo -e "${GREEN}[✓]${NC} Decrypted with OpenSSL"
}

# Encrypt with Age
encrypt_age() {
    local input="$1"
    local output="$2"

    # Check if age is installed
    if ! command -v age >/dev/null; then
        echo -e "${RED}[ERROR]${NC} age is not installed"
        echo "Install with: apt-get install age  # or download from filippo.io/age"
        exit 1
    fi

    # Generate key if doesn't exist
    if [[ ! -f "$USER_DIR/config/.age_key" ]]; then
        age-keygen -o "$USER_DIR/config/.age_key" 2>/dev/null
        chmod 600 "$USER_DIR/config/.age_key"
    fi

    # Get public key
    PUBLIC_KEY=$(age-keygen -y "$USER_DIR/config/.age_key" 2>/dev/null)

    # Encrypt
    age -r "$PUBLIC_KEY" -o "$output" "$input"

    echo -e "${GREEN}[✓]${NC} Encrypted with Age"
}

# Decrypt with Age
decrypt_age() {
    local input="$1"
    local output="$2"

    age -d -i "$USER_DIR/config/.age_key" -o "$output" "$input"

    echo -e "${GREEN}[✓]${NC} Decrypted with Age"
}

# Main encrypt function
encrypt_keys() {
    if [[ ! -f "$KEY_FILE" ]]; then
        echo -e "${RED}[ERROR]${NC} API keys file not found: $KEY_FILE"
        exit 1
    fi

    # Check if already encrypted
    if [[ -f "$ENC_FILE" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Encrypted keys already exist"
        read -p "Re-encrypt? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi

        # Backup existing encrypted file
        cp "$ENC_FILE" "$ENC_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Get encryption method
    METHOD=$(get_method)

    # Encrypt based on method
    case "$METHOD" in
        gpg)     encrypt_gpg "$KEY_FILE" "$ENC_FILE" ;;
        openssl) encrypt_openssl "$KEY_FILE" "$ENC_FILE" ;;
        age)     encrypt_age "$KEY_FILE" "$ENC_FILE" ;;
    esac

    # Secure the encrypted file
    chmod 600 "$ENC_FILE"

    # Optionally remove plaintext file
    echo ""
    echo -e "${YELLOW}[!]${NC} Your API keys are now encrypted"
    read -p "Delete plaintext API keys file? (recommended) (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        shred -u "$KEY_FILE" 2>/dev/null || rm -f "$KEY_FILE"
        echo -e "${GREEN}[✓]${NC} Plaintext keys securely deleted"
    else
        chmod 600 "$KEY_FILE"
        echo -e "${YELLOW}[WARN]${NC} Plaintext keys kept. Please secure manually."
    fi
}

# Main decrypt function
decrypt_keys() {
    if [[ ! -f "$ENC_FILE" ]]; then
        echo -e "${RED}[ERROR]${NC} Encrypted keys not found: $ENC_FILE"
        exit 1
    fi

    # Check if plaintext already exists
    if [[ -f "$KEY_FILE" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Plaintext keys already exist"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    # Get encryption method
    METHOD=$(cat "$USER_DIR/config/.encryption_method" 2>/dev/null || echo "openssl")

    # Create temp file
    TEMP_FILE=$(mktemp)
    trap 'rm -f '"$TEMP_FILE"'' EXIT

    # Decrypt based on method
    case "$METHOD" in
        gpg)     decrypt_gpg "$ENC_FILE" "$TEMP_FILE" ;;
        openssl) decrypt_openssl "$ENC_FILE" "$TEMP_FILE" ;;
        age)     decrypt_age "$ENC_FILE" "$TEMP_FILE" ;;
    esac

    # Move to final location
    mv "$TEMP_FILE" "$KEY_FILE"
    chmod 600 "$KEY_FILE"

    echo -e "${GREEN}[✓]${NC} Keys decrypted to: $KEY_FILE"
    echo -e "${YELLOW}[!]${NC} Remember to re-encrypt after use"
}

# Show status
show_status() {
    echo "DevPilot Key Security Status"
    echo "============================"
    echo "User directory: $USER_DIR"
    echo ""

    if [[ -f "$KEY_FILE" ]]; then
        echo -e "${YELLOW}⚠${NC}  Plaintext keys: EXISTS (NOT SECURE)"
        echo "   $KEY_FILE"
        echo "   Run: dp secure-keys encrypt"
    else
        echo -e "${GREEN}✓${NC}  Plaintext keys: Not found (good)"
    fi

    if [[ -f "$ENC_FILE" ]]; then
        echo -e "${GREEN}✓${NC}  Encrypted keys: EXISTS"
        echo "   $ENC_FILE"
        METHOD=$(cat "$USER_DIR/config/.encryption_method" 2>/dev/null || echo "unknown")
        echo "   Method: $METHOD"
        echo "   Modified: $(stat -c %y "$ENC_FILE" 2>/dev/null | cut -d' ' -f1)"
    else
        echo -e "${YELLOW}⚠${NC}  Encrypted keys: Not found"
        echo "   Run: dp secure-keys encrypt"
    fi
}

# Main command handler
case "${1:-status}" in
    encrypt)
        encrypt_keys
        ;;
    decrypt)
        decrypt_keys
        ;;
    status)
        show_status
        ;;
    rotate)
        # Rotate keys (decrypt, then re-encrypt with new password/key)
        echo "Rotating encryption keys..."
        decrypt_keys
        rm -f "$USER_DIR/config/.encryption_method"
        encrypt_keys
        ;;
    *)
        echo "DevPilot Secure Keys Utility"
        echo "Usage: dp secure-keys <command>"
        echo ""
        echo "Commands:"
        echo "  encrypt  - Encrypt your API keys"
        echo "  decrypt  - Decrypt your API keys"
        echo "  status   - Show security status (default)"
        echo "  rotate   - Rotate encryption keys"
        echo ""
        echo "Your keys are stored in:"
        echo "  Plaintext: $KEY_FILE"
        echo "  Encrypted: $ENC_FILE"
        ;;
esac
