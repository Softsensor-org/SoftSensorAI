#!/usr/bin/env bash
# Example script showing how to use checksum verification for downloads
set -euo pipefail

# Source the checksum verification utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/checksum_verify.sh"

# Example: Download and verify mise installer
install_mise_verified() {
  echo "Installing mise with checksum verification..."

  local mise_url="https://mise.run/install.sh"
  local mise_file="/tmp/mise-install.sh"

  # Note: This is an example checksum - in production, get the real checksum from the official source
  # You can find checksums on the project's releases page or documentation
  local mise_checksum="GET_ACTUAL_CHECKSUM_FROM_MISE_RELEASES"

  # Download and verify
  if download_and_verify "$mise_url" "$mise_file" "$mise_checksum" "sha256"; then
    # Make executable and run
    chmod +x "$mise_file"
    bash "$mise_file"
    rm -f "$mise_file"
  else
    error "Failed to download or verify mise installer"
    return 1
  fi
}

# Example: Download gitleaks with verification
install_gitleaks_verified() {
  echo "Installing gitleaks with checksum verification..."

  local arch
  case "$(uname -m)" in
    x86_64) arch="x64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) error "Unsupported architecture"; return 1 ;;
  esac

  # Get latest version info (in production, pin to specific version)
  local version="9.18.1"  # Example version - update as needed
  local gitleaks_url="https://github.com/gitleaks/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_${arch}.tar.gz"
  local gitleaks_file="/tmp/gitleaks.tar.gz"

  # Checksums for gitleaks 9.18.1 (example - get real ones from releases page)
  local checksums_x64="abc123def456..."  # Replace with actual
  local checksums_arm64="789ghi012jkl..."  # Replace with actual

  local checksum=""
  if [ "$arch" = "x64" ]; then
    checksum="$checksums_x64"
  else
    checksum="$checksums_arm64"
  fi

  # Download and verify
  if download_and_verify "$gitleaks_url" "$gitleaks_file" "$checksum" "sha256"; then
    # Extract
    tar -xzf "$gitleaks_file" -C /tmp
    sudo mv /tmp/gitleaks /usr/local/bin/
    rm -f "$gitleaks_file"
    success "Gitleaks installed successfully"
  else
    error "Failed to download or verify gitleaks"
    return 1
  fi
}

# Example: Download multiple files from manifest
download_tools_from_manifest() {
  echo "Downloading tools from manifest..."

  # Create a temporary manifest
  cat > /tmp/tools_manifest.txt << 'EOF'
# Tool download manifest with checksums
# Format: URL FILENAME CHECKSUM [ALGORITHM]

# Example tools (replace with real URLs and checksums)
https://example.com/tool1.tar.gz tool1.tar.gz abc123... sha256
https://example.com/tool2.zip tool2.zip def456... sha256
EOF

  # Download all files with verification
  download_from_manifest "/tmp/tools_manifest.txt" "/tmp/downloads"

  # Clean up
  rm -f /tmp/tools_manifest.txt
}

# Main menu
main() {
  echo "╔══════════════════════════════════════════════╗"
  echo "║  Download with Checksum Verification Demo   ║"
  echo "╚══════════════════════════════════════════════╝"
  echo
  echo "This demonstrates how to use checksum verification"
  echo "for secure downloads in your scripts."
  echo
  echo "Examples:"
  echo "  1. Download single file with verification"
  echo "  2. Download from manifest file"
  echo "  3. Create checksum for a file"
  echo
  echo "To use in your scripts:"
  echo '  source "utils/checksum_verify.sh"'
  echo '  download_and_verify "$url" "$file" "$checksum"'
  echo

  # Example: Create a checksum for this script
  echo "Checksum of this script:"
  create_checksum "${BASH_SOURCE[0]}" "sha256"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
