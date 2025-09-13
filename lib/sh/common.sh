#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Common shell utilities - shared across all SoftSensorAI setup scripts
# Usage: source "path/to/lib/sh/common.sh"

# Prevent multiple sourcing
[[ -n "${SOFTSENSORAI_COMMON_LOADED:-}" ]] && return 0
readonly SOFTSENSORAI_COMMON_LOADED=1

# Bash strict mode
set -euo pipefail

# Color codes - readonly to prevent modification
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Logging functions - standardized across all scripts
log() { printf "\n${BLUE}==> %s${NC}\n" "$*"; }
info() { printf "${CYAN}ℹ  ${NC}%s\n" "$*"; }
success() { printf "${GREEN}✓ ${NC}%s\n" "$*"; }
warn() { printf "${YELLOW}⚠  ${NC}%s\n" "$*"; }
error() { printf "${RED}✗ ${NC}%s\n" "$*" >&2; }
debug() { [[ "${DEBUG:-0}" == "1" ]] && printf "${BLUE}🐛 ${NC}%s\n" "$*" >&2 || true; }

# Alternative names for compatibility
say() { log "$@"; }
err() { error "$@"; }

# Command checking
has() { command -v "$1" >/dev/null 2>&1; }
require() {
    if ! has "$1"; then
        error "Required command '$1' not found"
        exit 1
    fi
}

# Script directory resolution
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd
}

# Project root detection
get_project_root() {
    local dir="${1:-$(pwd)}"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/softsensorai" ]] || [[ -f "$dir/setup_all.sh" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    # Fallback for development
    echo "${SOFTSENSORAI_ROOT:-$HOME/repos/setup-scripts-fresh}"
}

# File operations
backup() {
    if [[ -f "$1" ]]; then
        local backup_file="$1.bak.$(date +%Y%m%d%H%M%S)"
        cp -a "$1" "$backup_file"
        debug "Backed up: $1 -> $backup_file"
    fi
}

safe_rm() {
    if [[ -e "$1" ]]; then
        backup "$1"
        rm -rf "$1"
        debug "Safely removed: $1"
    fi
}

# Directory operations
ensure_dir() {
    mkdir -p "$1"
    debug "Ensured directory: $1"
}

# User interaction helpers
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    local response

    if [[ "$default" == "y" ]]; then
        read -p "$prompt (Y/n): " response
        [[ ! "$response" =~ ^[Nn] ]]
    else
        read -p "$prompt (y/N): " response
        [[ "$response" =~ ^[Yy] ]]
    fi
}

# OS detection helpers
is_linux() { [[ "$(uname -s)" == "Linux" ]]; }
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_wsl() { [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; }

# Package manager detection
get_package_manager() {
    if has apt-get; then echo "apt"
    elif has yum; then echo "yum"
    elif has dnf; then echo "dnf"
    elif has brew; then echo "brew"
    elif has pacman; then echo "pacman"
    elif has zypper; then echo "zypper"
    else echo "unknown"; fi
}

# Git operations
is_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

get_git_root() {
    if is_git_repo; then
        git rev-parse --show-toplevel
    else
        error "Not in a git repository"
        return 1
    fi
}

# Configuration helpers
get_user_shell() {
    basename "${SHELL:-/bin/bash}"
}

get_shell_rc() {
    case "$(get_user_shell)" in
        zsh) echo "$HOME/.zshrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then echo "$HOME/.bashrc"
            else echo "$HOME/.bash_profile"; fi
            ;;
        *) echo "$HOME/.profile" ;;
    esac
}

# Error handling
cleanup() {
    local exit_code=$?
    debug "Cleanup function called with exit code: $exit_code"
    # Add any cleanup logic here
    exit $exit_code
}

# Set up exit trap for cleanup
trap cleanup EXIT

# Version comparison helper
version_gt() {
    # Compare versions: version_gt "1.2.3" "1.2.0" returns 0 if first > second
    printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1 | grep -qx "$2"
}

# Utility exports for scripts that need them
export SOFTSENSORAI_COMMON_LOADED
export -f log info success warn error debug say err
export -f has require get_script_dir get_project_root
export -f backup safe_rm ensure_dir confirm
export -f is_linux is_macos is_wsl get_package_manager
export -f is_git_repo get_git_root get_user_shell get_shell_rc
export -f version_gt

# Initialize debug mode from environment
readonly DEBUG="${DEBUG:-0}"