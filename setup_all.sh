#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Master Setup Script - Detects fresh vs upgrade mode
# Orchestrates the entire setup process for WSL development environment
# ============================================================================

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backups/$(date +%Y%m%d_%H%M%S)"
MODE=""  # Will be set to "fresh" or "upgrade"

# Helper functions
say() { echo -e "${BLUE}==>${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err() { echo -e "${RED}✗${NC} $*"; }

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Automated setup script for WSL development environment with AI agents.
Detects whether this is a fresh install or an upgrade.

Options:
  --fresh       Force fresh installation mode
  --upgrade     Force upgrade mode
  --skip-tools  Skip tool installation
  --skip-agents Skip agent configuration
  --backup-only Only backup existing configs
  --help        Show this help message

Modes:
  Fresh Install: Runs full setup including tools, folders, and global configs
  Upgrade:       Backs up existing configs and updates to latest versions

Examples:
  # Auto-detect mode and run
  $0

  # Force fresh installation
  $0 --fresh

  # Upgrade existing setup
  $0 --upgrade

EOF
  exit 0
}

# Parse arguments
SKIP_TOOLS=0
SKIP_AGENTS=0
BACKUP_ONLY=0
FORCE_MODE=""

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
    --skip-tools)
      SKIP_TOOLS=1
      shift
      ;;
    --skip-agents)
      SKIP_AGENTS=1
      shift
      ;;
    --backup-only)
      BACKUP_ONLY=1
      shift
      ;;
    --help|-h)
      show_help
      ;;
    *)
      err "Unknown option: $1"
      show_help
      ;;
  esac
done

# Detect mode if not forced
detect_mode() {
  if [[ -n "$FORCE_MODE" ]]; then
    MODE="$FORCE_MODE"
    return
  fi

  # Check for existing installations
  local has_global_claude=0
  local has_tools=0
  local has_projects=0

  [[ -f "$HOME/.claude/settings.json" ]] && has_global_claude=1
  command -v rg >/dev/null 2>&1 && command -v fd >/dev/null 2>&1 && has_tools=1
  [[ -d "$HOME/projects" ]] && has_projects=1

  if [[ $has_global_claude -eq 1 ]] || [[ $has_tools -eq 1 ]] || [[ $has_projects -eq 1 ]]; then
    MODE="upgrade"
    say "Detected existing installation. Running in UPGRADE mode."
  else
    MODE="fresh"
    say "No existing installation detected. Running in FRESH INSTALL mode."
  fi
}

# Backup existing configurations
backup_configs() {
  say "Backing up existing configurations..."
  mkdir -p "$BACKUP_DIR"

  # List of config files/dirs to backup
  local configs=(
    "$HOME/.claude"
    "$HOME/.gemini"
    "$HOME/.grok"
    "$HOME/.codex"
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/templates/agent-setup"
  )

  for config in "${configs[@]}"; do
    if [[ -e "$config" ]]; then
      local basename=$(basename "$config")
      cp -r "$config" "$BACKUP_DIR/$basename.bak"
      success "Backed up: $config"
    fi
  done

  say "Backups saved to: $BACKUP_DIR"
}

# Fresh installation
run_fresh_install() {
  say "Starting fresh installation..."
  
  # 1. Install key software
  if [[ $SKIP_TOOLS -eq 0 ]]; then
    say "Installing essential development tools..."
    if [[ -x "$SCRIPT_DIR/install_key_software_wsl.sh" ]]; then
      "$SCRIPT_DIR/install_key_software_wsl.sh"
    else
      warn "install_key_software_wsl.sh not found or not executable"
    fi
  fi

  # 2. Install AI CLIs
  if [[ $SKIP_AGENTS -eq 0 ]]; then
    say "Installing AI CLI tools..."
    if [[ -x "$SCRIPT_DIR/install_ai_clis.sh" ]]; then
      "$SCRIPT_DIR/install_ai_clis.sh"
    else
      warn "install_ai_clis.sh not found or not executable"
    fi
  fi

  # 3. Setup global agent configurations
  if [[ $SKIP_AGENTS -eq 0 ]]; then
    say "Setting up global agent configurations..."
    if [[ -x "$SCRIPT_DIR/setup_agents_global.sh" ]]; then
      "$SCRIPT_DIR/setup_agents_global.sh"
    else
      warn "setup_agents_global.sh not found or not executable"
    fi
  fi

  # 4. Create project directory structure
  say "Creating project directory structure..."
  if [[ -x "$SCRIPT_DIR/make_folders.sh" ]]; then
    "$SCRIPT_DIR/make_folders.sh"
  else
    warn "make_folders.sh not found or not executable"
  fi

  # 5. Copy SSH keys from Windows if needed
  if [[ -d "/mnt/c/Users" ]]; then
    say "Checking for Windows SSH keys..."
    if [[ -x "$SCRIPT_DIR/copy_windows_ssh_to_wsl.sh" ]]; then
      "$SCRIPT_DIR/copy_windows_ssh_to_wsl.sh" || warn "SSH key copy failed or skipped"
    fi
  fi

  success "Fresh installation complete!"
}

# Upgrade existing installation
run_upgrade() {
  say "Starting upgrade..."

  # 1. Backup existing configs
  backup_configs

  # 2. Update tools if needed
  if [[ $SKIP_TOOLS -eq 0 ]]; then
    say "Updating development tools..."
    if [[ -x "$SCRIPT_DIR/install_key_software_wsl.sh" ]]; then
      "$SCRIPT_DIR/install_key_software_wsl.sh"
    fi
  fi

  # 3. Re-run global agent setup (preserves existing with --force flag)
  if [[ $SKIP_AGENTS -eq 0 ]]; then
    say "Updating global agent configurations..."
    if [[ -x "$SCRIPT_DIR/setup_agents_global.sh" ]]; then
      "$SCRIPT_DIR/setup_agents_global.sh"
    fi
  fi

  success "Upgrade complete! Backups saved to: $BACKUP_DIR"
}

# Post-installation steps
show_next_steps() {
  echo ""
  say "Next steps:"
  echo ""
  
  if [[ "$MODE" == "fresh" ]]; then
    echo "1. Configure your API keys:"
    echo "   export ANTHROPIC_API_KEY='your-key'"
    echo "   export GEMINI_API_KEY='your-key'"
    echo "   export XAI_API_KEY='your-key'"
    echo ""
    echo "2. Authenticate with GitHub:"
    echo "   gh auth login"
    echo ""
    echo "3. Clone your first repository:"
    echo "   $SCRIPT_DIR/repo_setup_wizard.sh"
    echo ""
    echo "4. Validate your setup:"
    echo "   $SCRIPT_DIR/validate_agents.sh"
  else
    echo "1. Review backup directory:"
    echo "   ls -la $BACKUP_DIR"
    echo ""
    echo "2. Validate agent configurations:"
    echo "   $SCRIPT_DIR/validate_agents.sh"
    echo ""
    echo "3. Update existing repositories:"
    echo "   cd <repo> && $SCRIPT_DIR/setup_agents_repo.sh --force"
  fi
  
  echo ""
  success "Setup complete! Open a new terminal for all changes to take effect."
}

# Main execution
main() {
  say "WSL Development Environment Setup"
  echo "=================================="
  
  # Detect installation mode
  detect_mode
  
  if [[ $BACKUP_ONLY -eq 1 ]]; then
    backup_configs
    success "Backup complete!"
    exit 0
  fi
  
  # Confirm with user
  echo ""
  echo "Mode: $MODE"
  echo ""
  
  if [[ "$MODE" == "upgrade" ]]; then
    warn "This will backup and update your existing configuration."
  fi
  
  read -p "Continue? (y/N): " -n 1 -r
  echo ""
  
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    say "Setup cancelled."
    exit 1
  fi
  
  # Run appropriate installation
  if [[ "$MODE" == "fresh" ]]; then
    run_fresh_install
  else
    run_upgrade
  fi
  
  # Show next steps
  show_next_steps
}

# Run main function
main