#!/usr/bin/env bash
# Utility functions for download verification with checksums
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
success() { echo -e "${GREEN}✅ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }
error() { echo -e "${RED}❌ $*${NC}"; }

# Download file with checksum verification
# Usage: download_and_verify <url> <output_file> [checksum] [algorithm]
download_and_verify() {
  local url="$1"
  local output_file="$2"
  local checksum="${3:-}"
  local algorithm="${4:-sha256}"

  echo "Downloading: $(basename "$output_file")..."

  # Download the file
  if command -v curl &>/dev/null; then
    curl -sSL "$url" -o "$output_file" || {
      error "Download failed from: $url"
      return 1
    }
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$output_file" || {
      error "Download failed from: $url"
      return 1
    }
  else
    error "Neither curl nor wget is available"
    return 1
  fi

  # If no checksum provided, just warn
  if [ -z "$checksum" ]; then
    warn "No checksum provided for $(basename "$output_file") - skipping verification"
    return 0
  fi

  # Verify checksum
  echo "Verifying checksum..."
  if ! verify_checksum "$output_file" "$checksum" "$algorithm"; then
    error "Checksum verification failed!"
    rm -f "$output_file"
    return 1
  fi

  success "Downloaded and verified: $(basename "$output_file")"
  return 0
}

# Verify file checksum
# Usage: verify_checksum <file> <expected_checksum> [algorithm]
verify_checksum() {
  local file="$1"
  local expected_checksum="$2"
  local algorithm="${3:-sha256}"

  if [ ! -f "$file" ]; then
    error "File not found: $file"
    return 1
  fi

  local actual_checksum=""

  case "$algorithm" in
    sha256)
      if command -v sha256sum &>/dev/null; then
        actual_checksum=$(sha256sum "$file" | cut -d' ' -f1)
      elif command -v shasum &>/dev/null; then
        actual_checksum=$(shasum -a 256 "$file" | cut -d' ' -f1)
      else
        error "No SHA256 tool available"
        return 1
      fi
      ;;
    sha1)
      if command -v sha1sum &>/dev/null; then
        actual_checksum=$(sha1sum "$file" | cut -d' ' -f1)
      elif command -v shasum &>/dev/null; then
        actual_checksum=$(shasum -a 1 "$file" | cut -d' ' -f1)
      else
        error "No SHA1 tool available"
        return 1
      fi
      ;;
    md5)
      if command -v md5sum &>/dev/null; then
        actual_checksum=$(md5sum "$file" | cut -d' ' -f1)
      elif command -v md5 &>/dev/null; then
        actual_checksum=$(md5 -q "$file")
      else
        error "No MD5 tool available"
        return 1
      fi
      ;;
    *)
      error "Unsupported algorithm: $algorithm"
      return 1
      ;;
  esac

  # Compare checksums (case-insensitive)
  if [ "${actual_checksum,,}" = "${expected_checksum,,}" ]; then
    return 0
  else
    error "Checksum mismatch!"
    error "  Expected: $expected_checksum"
    error "  Got:      $actual_checksum"
    return 1
  fi
}

# Download and verify from a manifest file
# Manifest format: <url> <filename> <checksum> [algorithm]
download_from_manifest() {
  local manifest_file="$1"
  local dest_dir="${2:-.}"

  if [ ! -f "$manifest_file" ]; then
    error "Manifest file not found: $manifest_file"
    return 1
  fi

  echo "Downloading files from manifest: $manifest_file"
  local failed=0

  while IFS=' ' read -r url filename checksum algorithm; do
    # Skip comments and empty lines
    [[ "$url" =~ ^# ]] && continue
    [ -z "$url" ] && continue

    # Set default algorithm if not specified
    algorithm="${algorithm:-sha256}"

    local output_path="$dest_dir/$filename"

    if download_and_verify "$url" "$output_path" "$checksum" "$algorithm"; then
      echo "  ✓ $filename"
    else
      echo "  ✗ $filename"
      failed=$((failed + 1))
    fi
  done < "$manifest_file"

  if [ "$failed" -gt 0 ]; then
    error "$failed downloads failed"
    return 1
  fi

  success "All downloads verified successfully"
  return 0
}

# Create a checksum for a file
# Usage: create_checksum <file> [algorithm]
create_checksum() {
  local file="$1"
  local algorithm="${2:-sha256}"

  if [ ! -f "$file" ]; then
    error "File not found: $file"
    return 1
  fi

  case "$algorithm" in
    sha256)
      if command -v sha256sum &>/dev/null; then
        sha256sum "$file" | cut -d' ' -f1
      elif command -v shasum &>/dev/null; then
        shasum -a 256 "$file" | cut -d' ' -f1
      fi
      ;;
    sha1)
      if command -v sha1sum &>/dev/null; then
        sha1sum "$file" | cut -d' ' -f1
      elif command -v shasum &>/dev/null; then
        shasum -a 1 "$file" | cut -d' ' -f1
      fi
      ;;
    md5)
      if command -v md5sum &>/dev/null; then
        md5sum "$file" | cut -d' ' -f1
      elif command -v md5 &>/dev/null; then
        md5 -q "$file"
      fi
      ;;
    *)
      error "Unsupported algorithm: $algorithm"
      return 1
      ;;
  esac
}

# Export functions if being sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  export -f download_and_verify
  export -f verify_checksum
  export -f download_from_manifest
  export -f create_checksum
fi
