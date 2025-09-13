#!/usr/bin/env bash
# SoftSensorAI Setup - Choose installation mode
set -euo pipefail

# Load shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/sh/common.sh"

main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  SoftSensorAI Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Choose installation type:"
    echo ""
    echo "1) Single-user  - Install for current user only"
    echo "   • Tools installed to ~/.local/bin"
    echo "   • Config in ~/.softsensorai"
    echo "   • Simple setup, good for personal use"
    echo ""
    echo "2) Multi-user   - Install system-wide for all users"
    echo "   • Requires sudo privileges"
    echo "   • System tools in /opt/softsensorai"
    echo "   • Each user gets personal config"
    echo "   • Good for shared servers/teams"
    echo ""
    read -p "Choose (1-2) [1]: " choice

    case "${choice:-1}" in
        1)
            say "Single-user installation selected"
            single_user_install
            ;;
        2)
            say "Multi-user installation selected"
            multi_user_install
            ;;
        *)
            say "Invalid choice, defaulting to single-user"
            single_user_install
            ;;
    esac
}

single_user_install() {
    echo ""
    say "Running single-user installation..."

    # Use the existing simplified setup we created
    if [[ -f "$SCRIPT_DIR/setup_all.sh" ]]; then
        bash "$SCRIPT_DIR/setup_all.sh"
    else
        warn "setup_all.sh not found, cannot proceed with single-user install"
        exit 1
    fi

    echo ""
    success "Single-user installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Add to PATH: export PATH=\"$SCRIPT_DIR/bin:\$PATH\""
    echo "2. Add to ~/.bashrc: echo 'export PATH=\"$SCRIPT_DIR/bin:\$PATH\"' >> ~/.bashrc"
    echo "3. For any project: ssai setup"
}

multi_user_install() {
    echo ""

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        say "Running as root - proceeding with system-wide installation..."

        if [[ -f "$SCRIPT_DIR/install/multi_user_setup.sh" ]]; then
            bash "$SCRIPT_DIR/install/multi_user_setup.sh"
        else
            warn "Multi-user installer not found at $SCRIPT_DIR/install/multi_user_setup.sh"
            exit 1
        fi

    else
        warn "Multi-user installation requires sudo privileges"
        echo ""
        echo "Please run one of the following:"
        echo ""
        echo "Option A - Run this script with sudo:"
        echo "  sudo $0"
        echo ""
        echo "Option B - Run multi-user installer directly:"
        echo "  sudo $SCRIPT_DIR/install/multi_user_setup.sh"
        echo ""
        echo "After system installation, users can run:"
        echo "  $SCRIPT_DIR/install/user_setup.sh"
        exit 1
    fi

    success "Multi-user installation complete!"
    echo ""
    echo "System installation finished. Users can now run:"
    echo "  $SCRIPT_DIR/install/user_setup.sh"
    echo ""
    echo "Or simply: ssai (should be available system-wide)"
}

main "$@"