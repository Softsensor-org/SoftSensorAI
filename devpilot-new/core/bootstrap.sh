#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# DevPilot Bootstrap - Modern AI Development Platform Orchestrator
# Detects fresh vs upgrade mode, orchestrates platform installation
# ============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVPILOT_ROOT="$(dirname "$SCRIPT_DIR")"
MIGRATION_ROOT="$(dirname "$DEVPILOT_ROOT")/.migration"

# Source core utilities
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/logger.sh"

# Bootstrap state
BOOTSTRAP_STATE_FILE="$HOME/.devpilot/bootstrap.state"
BACKUP_DIR="$HOME/.devpilot/backups/$(date +%Y%m%d_%H%M%S)"

# Installation mode
MODE=""  # Will be set to "fresh" or "upgrade"
PLATFORM=""  # Will be set to "wsl", "linux", or "macos"

# Command-line options
DRY_RUN=false
SKIP_TOOLS=false
SKIP_AGENTS=false
SKIP_BACKUP=false
FORCE_MODE=""
FORCE_PLATFORM=""
AUTO_YES=false

# ============================================================================
# Help and Usage
# ============================================================================

show_help() {
    cat <<EOF
Usage: devpilot bootstrap [OPTIONS]

Automated setup and configuration for AI-powered development environments.
Auto-detects OS platform and installation mode (fresh vs upgrade).

Options:
    --fresh          Force fresh installation mode
    --upgrade        Force upgrade mode
    --platform       Force platform (wsl|linux|macos)
    --skip-tools     Skip tool installation
    --skip-agents    Skip agent configuration
    --skip-backup    Skip configuration backup
    --dry-run        Preview actions without making changes
    --yes, -y        Auto-accept all prompts
    --help, -h       Show this help message

Modes:
    Fresh Install:   Full setup including tools, folders, and configurations
    Upgrade:         Backs up existing configs and updates to latest versions

Examples:
    # Auto-detect mode and run
    devpilot bootstrap

    # Force fresh installation
    devpilot bootstrap --fresh

    # Upgrade with auto-confirmation
    devpilot bootstrap --upgrade --yes

    # Preview upgrade without changes
    devpilot bootstrap --upgrade --dry-run

EOF
    exit 0
}

# ============================================================================
# Mode Detection
# ============================================================================

detect_mode() {
    if [[ -n "$FORCE_MODE" ]]; then
        MODE="$FORCE_MODE"
        log_info "Using forced mode: $MODE"
        return
    fi

    # Check for existing installations
    local has_devpilot=false
    local has_claude=false
    local has_tools=false

    [[ -d "$HOME/.devpilot" ]] && has_devpilot=true
    [[ -f "$HOME/.claude/settings.json" ]] && has_claude=true
    command -v rg >/dev/null 2>&1 && command -v fd >/dev/null 2>&1 && has_tools=true

    if $has_devpilot || $has_claude || $has_tools; then
        MODE="upgrade"
        log_info "Detected existing installation. Running in UPGRADE mode."
    else
        MODE="fresh"
        log_info "No existing installation detected. Running in FRESH INSTALL mode."
    fi
}

# ============================================================================
# Platform Detection
# ============================================================================

detect_platform() {
    if [[ -n "$FORCE_PLATFORM" ]]; then
        PLATFORM="$FORCE_PLATFORM"
        log_info "Using forced platform: $PLATFORM"
        return
    fi

    # Check for WSL
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        PLATFORM="wsl"
    else
        case "$(uname -s)" in
            Darwin) PLATFORM="macos" ;;
            Linux)  PLATFORM="linux" ;;
            *)      PLATFORM="unknown" ;;
        esac
    fi

    log_info "Detected platform: $PLATFORM"
}

# ============================================================================
# Backup Functions
# ============================================================================

backup_configs() {
    if $SKIP_BACKUP; then
        log_info "Skipping configuration backup (--skip-backup)"
        return
    fi

    log_step "Backing up existing configurations"

    if $DRY_RUN; then
        log_info "[DRY RUN] Would backup configs to: $BACKUP_DIR"
        return
    fi

    mkdir -p "$BACKUP_DIR"

    # List of configs to backup
    local configs=(
        "$HOME/.devpilot"
        "$HOME/.claude"
        "$HOME/.gemini"
        "$HOME/.grok"
        "$HOME/.codex"
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
        "$HOME/templates/agent-setup"
    )

    for config in "${configs[@]}"; do
        if [[ -e "$config" ]]; then
            local basename=$(basename "$config")
            cp -r "$config" "$BACKUP_DIR/$basename.bak" 2>/dev/null || true
            log_success "Backed up: $config"
        fi
    done

    log_info "Backups saved to: $BACKUP_DIR"
}

# ============================================================================
# Tool Installation
# ============================================================================

install_tools() {
    if $SKIP_TOOLS; then
        log_info "Skipping tool installation (--skip-tools)"
        return
    fi

    log_step "Installing essential development tools for $PLATFORM"

    local platform_script="$DEVPILOT_ROOT/onboard/platforms/${PLATFORM}.sh"
    
    if [[ ! -f "$platform_script" ]]; then
        log_error "Platform installer not found: $platform_script"
        return 1
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would run: $platform_script"
        return
    fi

    bash "$platform_script" || {
        log_error "Tool installation failed"
        return 1
    }
}

# ============================================================================
# Folder Structure
# ============================================================================

create_folders() {
    log_step "Creating directory structure"

    if [[ -f "$SCRIPT_DIR/folders.sh" ]]; then
        if $DRY_RUN; then
            log_info "[DRY RUN] Would create folder structure"
            return
        fi
        bash "$SCRIPT_DIR/folders.sh"
    else
        # Fallback to basic structure
        local dirs=(
            "$HOME/.devpilot"
            "$HOME/.devpilot/logs"
            "$HOME/.devpilot/backups"
            "$HOME/.devpilot/state"
            "$HOME/.devpilot/cache"
            "$HOME/projects"
            "$HOME/templates"
            "$HOME/templates/agent-setup"
        )

        for dir in "${dirs[@]}"; do
            if $DRY_RUN; then
                log_info "[DRY RUN] Would create: $dir"
            else
                mkdir -p "$dir"
                log_success "Created: $dir"
            fi
        done
    fi
}

# ============================================================================
# Agent Configuration
# ============================================================================

setup_agents() {
    if $SKIP_AGENTS; then
        log_info "Skipping agent configuration (--skip-agents)"
        return
    fi

    log_step "Setting up AI agent configurations"

    local agent_script="$DEVPILOT_ROOT/pilot/agents/setup.sh"
    
    if [[ ! -f "$agent_script" ]]; then
        log_warn "Agent setup script not found: $agent_script"
        return 1
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would run: $agent_script"
        return
    fi

    bash "$agent_script" || {
        log_error "Agent setup failed"
        return 1
    }
}

# ============================================================================
# WSL-specific Setup (NO POWERSHELL TO AVOID HANGING)
# ============================================================================

setup_wsl_extras() {
    if [[ "$PLATFORM" != "wsl" ]]; then
        return
    fi

    log_step "Configuring WSL-specific features"

    # Try to find Windows username from WSL environment
    local win_user=""
    if [[ -n "${WSL_INTEROP:-}" ]]; then
        # Try to get username from mount points
        for user_dir in /mnt/c/Users/*; do
            if [[ -d "$user_dir" ]] && [[ "$(basename "$user_dir")" != "Public" ]] && [[ "$(basename "$user_dir")" != "Default" ]]; then
                win_user="$(basename "$user_dir")"
                break
            fi
        done
    fi

    # Copy SSH keys from Windows if available
    if [[ -n "$win_user" ]]; then
        local win_ssh="/mnt/c/Users/$win_user/.ssh"
        
        if [[ -d "$win_ssh" ]] && [[ ! -d "$HOME/.ssh" ]]; then
            if $DRY_RUN; then
                log_info "[DRY RUN] Would copy SSH keys from Windows"
            else
                cp -r "$win_ssh" "$HOME/.ssh"
                chmod 700 "$HOME/.ssh"
                chmod 600 "$HOME/.ssh/"* 2>/dev/null || true
                log_success "Copied SSH keys from Windows"
            fi
        fi
    fi

    # Configure WSL settings
    if ! $DRY_RUN; then
        # Enable systemd if available
        if command -v systemctl >/dev/null 2>&1; then
            log_info "Systemd is available in WSL"
        fi
    fi
}

# ============================================================================
# Bootstrap State Management
# ============================================================================

save_bootstrap_state() {
    if $DRY_RUN; then
        return
    fi

    mkdir -p "$(dirname "$BOOTSTRAP_STATE_FILE")"
    
    cat > "$BOOTSTRAP_STATE_FILE" <<EOF
{
    "version": "2.0.0",
    "mode": "$MODE",
    "platform": "$PLATFORM",
    "timestamp": "$(date -Iseconds)",
    "backup_dir": "$BACKUP_DIR",
    "components": {
        "tools": $(! $SKIP_TOOLS && echo "true" || echo "false"),
        "agents": $(! $SKIP_AGENTS && echo "true" || echo "false"),
        "backup": $(! $SKIP_BACKUP && echo "true" || echo "false")
    }
}
EOF
    
    log_success "Saved bootstrap state to: $BOOTSTRAP_STATE_FILE"
}

# ============================================================================
# Installation Flows
# ============================================================================

run_fresh_install() {
    log_header "Starting Fresh Installation"

    # Create folder structure first
    create_folders || return 1

    # Install platform-specific tools
    install_tools || return 1

    # Setup AI agents
    setup_agents || return 1

    # WSL-specific setup
    setup_wsl_extras

    # Save state
    save_bootstrap_state

    log_success "Fresh installation complete!"
}

run_upgrade() {
    log_header "Starting Upgrade"

    # Backup existing configurations
    backup_configs || return 1

    # Update tools if needed
    install_tools || return 1

    # Update agent configurations
    setup_agents || return 1

    # WSL-specific updates
    setup_wsl_extras

    # Save state
    save_bootstrap_state

    log_success "Upgrade complete!"
}

# ============================================================================
# Next Steps Display
# ============================================================================

show_next_steps() {
    echo ""
    log_header "Next Steps"
    echo ""

    if [[ "$MODE" == "fresh" ]]; then
        cat <<EOF
1. Configure your API keys:
   export ANTHROPIC_API_KEY='your-key'
   export GEMINI_API_KEY='your-key'
   export XAI_API_KEY='your-key'

2. Authenticate with GitHub:
   gh auth login

3. Initialize your first repository:
   devpilot project wizard

4. Validate your setup:
   devpilot insights audit

EOF
    else
        cat <<EOF
1. Review backup directory:
   ls -la $BACKUP_DIR

2. Validate configurations:
   devpilot insights audit

3. Update existing repositories:
   cd <repo> && devpilot pilot setup --force

EOF
    fi

    log_success "Bootstrap complete! Open a new terminal for all changes to take effect."
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fresh)
                FORCE_MODE="fresh"
                shift
                ;;
            --upgrade)
                FORCE_MODE="upgrade"
                shift
                ;;
            --platform)
                FORCE_PLATFORM="${2:-}"
                case "$FORCE_PLATFORM" in
                    wsl|linux|macos) ;;
                    *) log_error "Invalid platform: $FORCE_PLATFORM"; exit 1 ;;
                esac
                shift 2
                ;;
            --skip-tools)
                SKIP_TOOLS=true
                shift
                ;;
            --skip-agents)
                SKIP_AGENTS=true
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --yes|-y)
                AUTO_YES=true
                shift
                ;;
            --help|-h)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                ;;
        esac
    done

    # Show header
    log_header "DevPilot Bootstrap System"
    echo ""

    # Detect mode and platform
    detect_mode
    detect_platform

    # Display configuration
    echo "Mode:     $MODE"
    echo "Platform: $PLATFORM"
    echo "Dry Run:  $DRY_RUN"
    echo ""

    # Confirm with user unless auto-yes
    if ! $AUTO_YES && ! $DRY_RUN; then
        if [[ "$MODE" == "upgrade" ]]; then
            log_warn "This will backup and update your existing configuration."
        fi
        
        read -p "Continue? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Bootstrap cancelled."
            exit 0
        fi
    fi

    # Run appropriate installation flow
    if [[ "$MODE" == "fresh" ]]; then
        run_fresh_install || {
            log_error "Fresh installation failed"
            exit 1
        }
    else
        run_upgrade || {
            log_error "Upgrade failed"
            exit 1
        }
    fi

    # Show next steps
    if ! $DRY_RUN; then
        show_next_steps
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi