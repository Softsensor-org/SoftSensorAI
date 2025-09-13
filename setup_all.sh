#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

# ============================================================================
# SoftSensorAI Setup Script
# Quick installation of AI-powered development environment
# ============================================================================

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
say() { echo -e "${BLUE}==>${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err() { echo -e "${RED}✗${NC} $*"; }

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Quick setup for AI-powered development environment.
Auto-detects OS (WSL, Linux, macOS).

Options:
  --skip-tools  Skip tool installation
  --skip-agents Skip agent configuration
  --help        Show this help message

Examples:
  # Run complete setup
  $0

  # Skip tool installation (already installed)
  $0 --skip-tools

EOF
  exit 0
}

# Parse arguments
SKIP_TOOLS=0
SKIP_AGENTS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-tools)
      SKIP_TOOLS=1
      shift
      ;;
    --skip-agents)
      SKIP_AGENTS=1
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

# Detect platform
detect_platform() {
  local platform=""

  # WSL if env var set or /proc/version mentions Microsoft
  if [[ -n "${WSL_DISTRO_NAME:-}" ]] || ([ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null); then
    platform="wsl"
  else
    case "$(uname -s)" in
      Darwin) platform="macos" ;;
      Linux)  platform="linux" ;;
      FreeBSD|OpenBSD|NetBSD) platform="bsd" ;;
      CYGWIN*|MINGW*|MSYS*) platform="windows" ;;
      SunOS) platform="solaris" ;;
      *)      platform="unknown" ;;
    esac
  fi

  echo "$platform"
}

# Detect GPU capabilities
detect_gpu() {
  local gpu_info="None"
  local gpu_type=""

  # Check for NVIDIA GPU
  if command -v nvidia-smi &>/dev/null; then
    if nvidia-smi &>/dev/null; then
      gpu_type="NVIDIA"
      local gpu_model
      gpu_model=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
      gpu_info="${gpu_type}: ${gpu_model}"

      # Check CUDA version
      if command -v nvcc &>/dev/null; then
        local cuda_version
        cuda_version=$(nvcc --version | grep "release" | sed 's/.*release //' | sed 's/,.*//')
        gpu_info="${gpu_info} (CUDA ${cuda_version})"
      fi
    fi
  fi

  # Check for AMD GPU
  if [ -z "$gpu_type" ] && command -v rocm-smi &>/dev/null; then
    gpu_type="AMD"
    gpu_info="${gpu_type} GPU (ROCm)"
  fi

  # Check for Apple Silicon
  if [ -z "$gpu_type" ] && [[ "$(uname -s)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
    gpu_type="Apple"
    gpu_info="Apple Silicon GPU"
  fi

  echo "$gpu_info"
}

# Install tools for detected platform
install_tools() {
  local platform="$1"

  case "$platform" in
    wsl|linux|bsd|solaris)
      say "Installing Unix/Linux development tools..."
      if [[ -f "$SCRIPT_DIR/install/key_software_linux.sh" ]]; then
        bash "$SCRIPT_DIR/install/key_software_linux.sh"
      else
        warn "install/key_software_linux.sh not found"
      fi
      ;;
    macos)
      say "Installing macOS development tools..."
      if [[ -f "$SCRIPT_DIR/install/key_software_macos.sh" ]]; then
        bash "$SCRIPT_DIR/install/key_software_macos.sh"
      else
        warn "install/key_software_macos.sh not found"
      fi
      ;;
    windows)
      warn "Native Windows detected (Cygwin/MinGW/MSYS). Limited support available."
      warn "Consider using WSL2 for full functionality."
      say "Attempting basic tool installation..."
      if [[ -f "$SCRIPT_DIR/install/key_software_linux.sh" ]]; then
        bash "$SCRIPT_DIR/install/key_software_linux.sh"
      else
        warn "install/key_software_linux.sh not found"
      fi
      ;;
    *)
      warn "Unknown platform: $platform. Attempting generic Unix installation."
      if [[ -f "$SCRIPT_DIR/install/key_software_linux.sh" ]]; then
        bash "$SCRIPT_DIR/install/key_software_linux.sh"
      else
        warn "install/key_software_linux.sh not found"
      fi
      ;;
  esac
}

# Main installation
run_installation() {
  local platform="$1"

  say "Starting SoftSensorAI installation..."

  # 1. Install key software
  if [[ $SKIP_TOOLS -eq 0 ]]; then
    install_tools "$platform"
  else
    say "Skipping tool installation (--skip-tools)"
  fi

  # 2. Install AI CLIs
  if [[ $SKIP_AGENTS -eq 0 ]]; then
    say "Installing AI CLI tools..."
    if [[ -f "$SCRIPT_DIR/install/ai_clis.sh" ]]; then
      bash "$SCRIPT_DIR/install/ai_clis.sh"
    else
      warn "install/ai_clis.sh not found"
    fi
  else
    say "Skipping AI CLI installation (--skip-agents)"
  fi

  # 3. Setup global agent configurations
  if [[ $SKIP_AGENTS -eq 0 ]]; then
    say "Setting up AI agent configurations..."
    if [[ -f "$SCRIPT_DIR/setup/agents_global.sh" ]]; then
      bash "$SCRIPT_DIR/setup/agents_global.sh"
    else
      warn "setup/agents_global.sh not found"
    fi
  else
    say "Skipping agent configuration (--skip-agents)"
  fi

  # 4. Create project directory structure
  say "Creating project directory structure..."
  if [[ -f "$SCRIPT_DIR/setup/folders.sh" ]]; then
    bash "$SCRIPT_DIR/setup/folders.sh"
  else
    warn "setup/folders.sh not found"
  fi

  # 5. Copy SSH keys from Windows if WSL
  if [[ "$platform" == "wsl" ]] && [[ -d "/mnt/c/Users" ]]; then
    say "Checking for Windows SSH keys..."
    if [[ -f "$SCRIPT_DIR/utils/copy_windows_ssh_to_wsl.sh" ]]; then
      bash "$SCRIPT_DIR/utils/copy_windows_ssh_to_wsl.sh" || warn "SSH key copy failed or skipped"
    fi
  fi

  success "Installation complete!"
}

# Show next steps
show_next_steps() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  success "SoftSensorAI is ready!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Next steps:"
  echo ""
  echo "1. Set up your first project:"
  echo "   ${GREEN}ssai setup${NC}          # Interactive setup (single or multi-repo)"
  echo "   ${GREEN}ssai setup git@github.com:org/repo${NC} # Direct with URL"
  echo ""
  echo "2. Add API keys (optional):"
  echo "   Add to ~/.bashrc or ~/.zshrc:"
  echo "   export ANTHROPIC_API_KEY='your-key'"
  echo "   export OPENAI_API_KEY='your-key'"
  echo "   export GEMINI_API_KEY='your-key'"
  echo "   export XAI_API_KEY='your-key'"
  echo ""
  echo "3. Authenticate with GitHub:"
  echo "   ${GREEN}gh auth login${NC}"
  echo ""
  echo "4. Validate your setup:"
  echo "   ${GREEN}./validation/validate_agents.sh${NC}"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Open a new terminal for all changes to take effect."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Main execution
main() {
  echo ""
  echo "╔════════════════════════════════════════════╗"
  echo "║     SoftSensorAI Setup - AI Development    ║"
  echo "╚════════════════════════════════════════════╝"
  echo ""

  # Detect platform
  local platform
  platform=$(detect_platform)
  say "Detected platform: ${platform}"

  # Detect GPU
  local gpu_info
  gpu_info=$(detect_gpu)
  say "Detected GPU: ${gpu_info}"

  # If GPU is available, suggest AI frameworks installation
  if [[ "$gpu_info" != "None" ]]; then
    echo ""
    echo -e "${GREEN}GPU detected! Consider installing AI frameworks after setup:${NC}"
    echo "  Run: ./scripts/setup_ai_frameworks.sh"
  fi

  # Confirm with user
  echo ""
  read -p "Continue with installation? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    say "Installation cancelled."
    exit 0
  fi

  # Run installation
  run_installation "$platform"

  # Show next steps
  show_next_steps
}

# Run main function
main
