#!/usr/bin/env bash
# Simple SoftSensorAI Setup - Multi-user or Single-user installation
set -euo pipefail

# Load shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/sh/common.sh"

# Global variables
MULTI_USER=false
INSTALL_PREFIX=""
BIN_DIR=""
CONFIG_DIR=""

setup_paths() {
    if [[ "$MULTI_USER" == "true" ]]; then
        INSTALL_PREFIX="/opt/softsensorai"
        BIN_DIR="/usr/local/bin"
        CONFIG_DIR="/etc/softsensorai"
        say "Multi-user installation: system-wide setup"
    else
        INSTALL_PREFIX="$HOME/.softsensorai"
        BIN_DIR="$HOME/.local/bin"
        CONFIG_DIR="$HOME/.config/softsensorai"
        say "Single-user installation: user-specific setup"
    fi
}

main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  SoftSensorAI Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Ask about installation type
    echo "Choose installation type:"
    echo "1) Single-user - Install for current user only (recommended)"
    echo "2) Multi-user  - Install system-wide for all users (requires sudo)"
    echo ""
    read -p "Choose (1-2) [1]: " choice

    case "${choice:-1}" in
        1) MULTI_USER=false ;;
        2) MULTI_USER=true ;;
        *) MULTI_USER=false ;;
    esac

    setup_paths
    echo ""

    # Check if sudo is needed and available for multi-user install
    if [[ "$MULTI_USER" == "true" ]]; then
        if ! has sudo; then
            err "Multi-user installation requires sudo, but sudo is not available"
            exit 1
        fi

        # Test sudo access
        if ! sudo -n true 2>/dev/null; then
            warn "Multi-user installation requires sudo privileges"
            echo "You may be prompted for your password..."
            if ! sudo true; then
                err "Cannot obtain sudo privileges"
                exit 1
            fi
        fi
    fi

    # 1. Install basic tools
    install_tools

    # 2. Install AI CLIs (optional)
    echo ""
    read -p "Install AI CLI tools (claude, codex, gemini, grok)? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_ai_tools
        setup_ai_configs
        success "AI configurations created"
    fi

    # 3. Install SoftSensorAI binaries
    install_binaries

    # 4. Show completion message
    show_completion_message
}

# Add placeholder functions to prevent errors
install_tools() {
    warn "install_tools function not implemented in this file"
}

install_ai_tools() {
    warn "install_ai_tools function not implemented in this file"
}

setup_ai_configs() {
    warn "setup_ai_configs function not implemented in this file"
}

install_binaries() {
    warn "install_binaries function not implemented in this file"
}

show_completion_message() {
    warn "show_completion_message function not implemented in this file"
}

main