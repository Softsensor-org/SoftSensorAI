#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Multi-user SoftSensorAI installation for shared servers
# Run as root/sudo for system-wide installation
set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/sh/common.sh"

# ============================================================================
# Multi-User Installation Script
# ============================================================================
# This script installs SoftSensorAI system-wide for all users on a shared server
# - System components in /opt/softsensorai (read-only for users)
# - User configs in ~/.softsensorai (per-user customization)
# - Shared tools in /usr/local/bin (or /opt/softsensorai/bin with PATH)
# ============================================================================

VERSION="${SOFTSENSORAI_VERSION:-latest}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/opt/softsensorai}"
USER_PREFIX="${USER_PREFIX:-\$HOME/.softsensorai}"

# Multi-user specific logging functions
log_info() { info "$*"; }
log_success() { success "$*"; }
log_warn() { warn "$*"; }
log_error() { error "$*"; }

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root for system-wide installation"
        log_info "Try: sudo $0"
        exit 1
    fi
}

# Detect OS and package manager
detect_system() {
    OS_TYPE="unknown"
    PKG_MGR="$(get_package_manager)"

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_TYPE="$ID"
    fi

    log_info "Detected: OS=$OS_TYPE, Package Manager=$PKG_MGR"
}

# Install system dependencies
install_dependencies() {
    log_info "Installing system dependencies..."

    local DEPS=(git jq curl wget bash)
    local DEV_DEPS=(ripgrep fd-find direnv)

    require git

    case "$PKG_MGR" in
        apt)
            apt-get update
            apt-get install -y "${DEPS[@]}"
            # Special handling for tools with different package names
            apt-get install -y ripgrep || {
                curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb
                dpkg -i ripgrep_14.1.0-1_amd64.deb
                rm ripgrep_14.1.0-1_amd64.deb
            }
            apt-get install -y fd-find && ln -sf "$(which fdfind)" /usr/local/bin/fd
            apt-get install -y direnv
            ;;
        dnf|yum)
            $PKG_MGR install -y "${DEPS[@]}" ripgrep fd-find direnv
            ;;
        pacman)
            pacman -Sy --noconfirm "${DEPS[@]}" ripgrep fd direnv
            ;;
        apk)
            apk add --no-cache "${DEPS[@]}" ripgrep fd direnv
            ;;
        *)
            log_warn "Unknown package manager. Please install manually: ${DEPS[*]} ${DEV_DEPS[*]}"
            ;;
    esac

    log_success "Dependencies installed"
}

# Create directory structure
create_directories() {
    log_info "Creating system directories..."

    # System directories (root-owned, read-only for users)
    mkdir -p "$INSTALL_PREFIX"/{bin,lib,share,etc}
    mkdir -p "$INSTALL_PREFIX"/lib/{core,templates,prompts}
    mkdir -p "$INSTALL_PREFIX"/share/{patterns,commands,personas}

    # Set permissions (read/execute for all, write for root only)
    chmod 755 "$INSTALL_PREFIX"
    chmod -R 755 "$INSTALL_PREFIX"/*

    log_success "System directories created"
}

# Install SoftSensorAI core
install_core() {
    log_info "Installing SoftSensorAI core..."

    # Clone or update repository
    local TEMP_DIR="/tmp/softsensorai-install-$$"
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi

    git clone https://github.com/Softsensor-org/SoftSensorAI.git "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Copy core components to system location
    cp -r bin/* "$INSTALL_PREFIX/bin/"
    cp -r scripts/* "$INSTALL_PREFIX/lib/core/"
    cp -r .claude/commands/* "$INSTALL_PREFIX/share/commands/" 2>/dev/null || true
    cp -r patterns/* "$INSTALL_PREFIX/share/patterns/" 2>/dev/null || true

    # Make binaries executable
    chmod +x "$INSTALL_PREFIX"/bin/*

    # Create system-wide configuration
    cat > "$INSTALL_PREFIX/etc/softsensorai.conf" <<'EOF'
# SoftSensorAI System Configuration
# This file is managed by the system administrator

# Installation paths
SOFTSENSORAI_ROOT="/opt/softsensorai"
SOFTSENSORAI_USER_DIR="$HOME/.softsensorai"

# Shared resources
SOFTSENSORAI_SHARED_PATTERNS="/opt/softsensorai/share/patterns"
SOFTSENSORAI_SHARED_COMMANDS="/opt/softsensorai/share/commands"
SOFTSENSORAI_SHARED_PERSONAS="/opt/softsensorai/share/personas"

# Multi-user mode
SOFTSENSORAI_MULTI_USER=true
SOFTSENSORAI_ALLOW_USER_OVERRIDE=true

# Security settings
SOFTSENSORAI_SANDBOX_ENABLED=true
SOFTSENSORAI_AUDIT_ENABLED=true
SOFTSENSORAI_LOG_DIR="/var/log/softsensorai"

# Resource limits (per user)
SOFTSENSORAI_MAX_ARTIFACTS_MB=1000
SOFTSENSORAI_MAX_CACHE_MB=500
SOFTSENSORAI_MAX_CONCURRENT_AGENTS=3
EOF

    # Clean up temp directory
    cd /
    rm -rf "$TEMP_DIR"

    log_success "SoftSensorAI core installed"
}

# Create wrapper script that handles user separation
create_wrapper() {
    log_info "Creating multi-user wrapper..."

    cat > "$INSTALL_PREFIX/bin/ssai" <<'WRAPPER'
#!/usr/bin/env bash
# SoftSensorAI multi-user wrapper
set -euo pipefail

# Load system configuration
source /opt/softsensorai/etc/softsensorai.conf

# Ensure user directory exists
if [[ ! -d "$SOFTSENSORAI_USER_DIR" ]]; then
    /opt/softsensorai/lib/core/init_user.sh
fi

# Set up user environment
export SOFTSENSORAI_ROOT="${SOFTSENSORAI_ROOT:-/opt/softsensorai}"
export SOFTSENSORAI_USER_DIR="${SOFTSENSORAI_USER_DIR:-$HOME/.softsensorai}"
export SOFTSENSORAI_ARTIFACTS="$SOFTSENSORAI_USER_DIR/artifacts"
export SOFTSENSORAI_CACHE="$SOFTSENSORAI_USER_DIR/cache"
export SOFTSENSORAI_CONFIG="$SOFTSENSORAI_USER_DIR/config"

# Load user-specific settings if they exist
if [[ -f "$SOFTSENSORAI_USER_DIR/config/settings.json" ]]; then
    export SOFTSENSORAI_USER_SETTINGS="$SOFTSENSORAI_USER_DIR/config/settings.json"
fi

# Load user's API keys (encrypted)
if [[ -f "$SOFTSENSORAI_USER_DIR/config/api_keys.env.enc" ]]; then
    # Decrypt and source (requires user password or key)
    /opt/softsensorai/lib/core/decrypt_keys.sh "$SOFTSENSORAI_USER_DIR/config/api_keys.env.enc"
fi

# Execute the actual SoftSensorAI command
exec /opt/softsensorai/lib/core/ssai_main.sh "$@"
WRAPPER

    chmod +x "$INSTALL_PREFIX/bin/ssai"

    # Create symlink in /usr/local/bin for PATH access
    ln -sf "$INSTALL_PREFIX/bin/ssai" /usr/local/bin/ssai

    log_success "Multi-user wrapper created"
}

# Create user initialization script
create_user_init() {
    log_info "Creating user initialization script..."

    cat > "$INSTALL_PREFIX/lib/core/init_user.sh" <<'INIT'
#!/usr/bin/env bash
# Initialize SoftSensorAI for a new user
set -euo pipefail

USER_DIR="${SOFTSENSORAI_USER_DIR:-$HOME/.softsensorai}"

echo "Initializing SoftSensorAI for user: $USER"

# Create user directory structure
mkdir -p "$USER_DIR"/{config,cache,artifacts,workspace}
mkdir -p "$USER_DIR"/config/{personas,commands}

# Copy default user configuration
cat > "$USER_DIR/config/settings.json" <<EOF
{
  "user": "$USER",
  "created": "$(date -Iseconds)",
  "version": "1.0.0",
  "preferences": {
    "skill_level": "l2",
    "project_phase": "mvp",
    "ai_provider": "auto",
    "editor": "${EDITOR:-vim}"
  },
  "limits": {
    "max_artifacts_mb": ${SOFTSENSORAI_MAX_ARTIFACTS_MB:-1000},
    "max_cache_mb": ${SOFTSENSORAI_MAX_CACHE_MB:-500}
  },
  "features": {
    "sandbox_enabled": true,
    "audit_enabled": true,
    "telemetry_enabled": false
  }
}
EOF

# Create API keys template (user needs to fill this)
cat > "$USER_DIR/config/api_keys.env.template" <<'EOF'
# SoftSensorAI API Keys (Personal)
# Copy to api_keys.env and fill in your keys
# Run: dp secure-keys to encrypt this file

# AI Providers
ANTHROPIC_API_KEY=""
OPENAI_API_KEY=""
GEMINI_API_KEY=""
GROK_API_KEY=""

# Version Control
GITHUB_TOKEN=""
GITLAB_TOKEN=""

# Cloud Providers (optional)
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AZURE_CLIENT_ID=""
AZURE_CLIENT_SECRET=""
GCP_SERVICE_ACCOUNT_KEY=""
EOF

# Set secure permissions
chmod 700 "$USER_DIR"
chmod 700 "$USER_DIR/config"
chmod 600 "$USER_DIR/config/api_keys.env.template"

echo "✅ SoftSensorAI initialized for $USER"
echo ""
echo "Next steps:"
echo "1. cd to your project directory"
echo "2. Run: dp setup"
echo "3. Configure your API keys: cp $USER_DIR/config/api_keys.env.template $USER_DIR/config/api_keys.env"
echo "4. Encrypt keys: dp secure-keys"
INIT

    chmod +x "$INSTALL_PREFIX/lib/core/init_user.sh"

    log_success "User initialization script created"
}

# Create management utilities for admins
create_admin_utils() {
    log_info "Creating admin utilities..."

    # User management script
    cat > "$INSTALL_PREFIX/bin/ssai-admin" <<'ADMIN'
#!/usr/bin/env bash
# SoftSensorAI admin utilities
set -euo pipefail

case "${1:-}" in
    list-users)
        echo "SoftSensorAI Users:"
        for user_dir in /home/*/.softsensorai; do
            if [[ -d "$user_dir" ]]; then
                user=$(basename $(dirname "$user_dir"))
                echo "  - $user"
            fi
        done
        ;;

    stats)
        echo "SoftSensorAI Usage Statistics:"
        echo "========================="
        for user_dir in /home/*/.softsensorai; do
            if [[ -d "$user_dir" ]]; then
                user=$(basename $(dirname "$user_dir"))
                artifacts_size=$(du -sh "$user_dir/artifacts" 2>/dev/null | cut -f1)
                cache_size=$(du -sh "$user_dir/cache" 2>/dev/null | cut -f1)
                echo "$user:"
                echo "  Artifacts: $artifacts_size"
                echo "  Cache: $cache_size"
            fi
        done
        ;;

    clean-cache)
        echo "Cleaning all user caches..."
        for cache_dir in /home/*/.softsensorai/cache; do
            if [[ -d "$cache_dir" ]]; then
                rm -rf "$cache_dir"/*
                echo "  Cleaned: $cache_dir"
            fi
        done
        ;;

    update)
        echo "Updating SoftSensorAI system-wide..."
        cd /tmp
        git clone https://github.com/Softsensor-org/SoftSensorAI.git softsensorai-update
        cd softsensorai-update
        cp -r bin/* /opt/softsensorai/bin/
        cp -r scripts/* /opt/softsensorai/lib/core/
        cd /tmp
        rm -rf softsensorai-update
        echo "✅ SoftSensorAI updated"
        ;;

    *)
        echo "SoftSensorAI Admin Utilities"
        echo "Usage: dp-admin <command>"
        echo ""
        echo "Commands:"
        echo "  list-users    List all SoftSensorAI users"
        echo "  stats         Show usage statistics"
        echo "  clean-cache   Clean all user caches"
        echo "  update        Update SoftSensorAI system-wide"
        ;;
esac
ADMIN

    chmod +x "$INSTALL_PREFIX/bin/ssai-admin"
    ln -sf "$INSTALL_PREFIX/bin/ssai-admin" /usr/local/bin/ssai-admin

    log_success "Admin utilities created"
}

# Set up logging and auditing
setup_logging() {
    log_info "Setting up logging and auditing..."

    # Create log directory
    mkdir -p /var/log/softsensorai
    chmod 1777 /var/log/softsensorai  # Sticky bit so users can write but not delete others' logs

    # Create logrotate configuration
    cat > /etc/logrotate.d/softsensorai <<'EOF'
/var/log/softsensorai/*.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 0666 root root
    sharedscripts
    postrotate
        # Signal any running SoftSensorAI processes to reopen log files
        pkill -USR1 -f softsensorai || true
    endscript
}
EOF

    log_success "Logging configured"
}

# Main installation flow
main() {
    echo "============================================"
    echo "  SoftSensorAI Multi-User Installation"
    echo "============================================"
    echo ""

    check_root
    detect_system
    install_dependencies
    create_directories
    install_core
    create_wrapper
    create_user_init
    create_admin_utils
    setup_logging

    echo ""
    echo "============================================"
    echo "  Installation Complete!"
    echo "============================================"
    echo ""
    echo "System-wide installation: $INSTALL_PREFIX"
    echo "User configs will be in: ~/.softsensorai"
    echo ""
    echo "For administrators:"
    echo "  ssai-admin list-users   # List all users"
    echo "  ssai-admin stats        # Show usage stats"
    echo "  ssai-admin update       # Update SoftSensorAI"
    echo ""
    echo "For users:"
    echo "  ssai setup              # Setup a project"
    echo "  ssai help               # Show help"
    echo ""
    echo "Each user should:"
    echo "1. Run any ssai command to auto-initialize"
    echo "2. Configure their personal API keys"
    echo "3. Run: ssai secure-keys to encrypt them"
    echo ""
    log_success "SoftSensorAI is ready for multi-user use!"
}

# Run main installation
main "$@"
