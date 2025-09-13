#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

ok() { printf "\033[0;32m[OK]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
bad() { printf "\033[0;31m[FAIL]\033[0m %s\n" "$*"; }

has() { command -v "$1" >/dev/null 2>&1; }

# Track missing tools for actionable output
MISSING_TOOLS=()

echo "==> Doctor: environment checks"

# OS / Shell
case "$(uname -s)" in
  Linux)
    if [ -n "${WSL_DISTRO_NAME:-}" ] || ([ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null); then
      ok "OS: Linux (WSL - ${WSL_DISTRO_NAME:-Ubuntu})"
      echo "  🪟 WSL Performance Tip: Store repos in /home/$USER/ (not /mnt/c/)"
      echo "     Access from Windows: \\\\wsl$\\${WSL_DISTRO_NAME:-Ubuntu}\\home\\$USER"
    else
      ok "OS: Linux"
    fi
    ;;
  Darwin) ok "OS: macOS" ;;
  FreeBSD) ok "OS: FreeBSD" ;;
  OpenBSD) ok "OS: OpenBSD" ;;
  NetBSD) ok "OS: NetBSD" ;;
  SunOS) ok "OS: Solaris/illumos" ;;
  CYGWIN*|MINGW*|MSYS*)
    warn "OS: Windows (via $(uname -s)) - Limited support"
    echo "  ⚠️  Consider using WSL2 for better performance and compatibility"
    echo "     Install: wsl --install -d Ubuntu"
    ;;
  *) warn "OS: $(uname -s) (untested)" ;;
esac

# Core tools
for t in git jq rg fd direnv yq comby; do
  if has "$t"; then
    ok "$t: $(command -v $t)"
  else
    if [[ "$t" == "yq" ]] || [[ "$t" == "comby" ]]; then
      warn "$t not found (recommended for agent tasks)"
    else
      bad "$t not found"
    fi
    MISSING_TOOLS+=("$t")
  fi
done

# Node + pnpm
if has node; then
  ok "node: $(node -v)"
else
  bad "node not found"
  MISSING_TOOLS+=("node")
fi
if has pnpm; then
  ok "pnpm: $(pnpm -v)"
else
  warn "pnpm not found"
  echo "  -> Install: corepack enable && corepack prepare pnpm@latest --activate"
fi

# Python
if has python3; then
  ok "python3: $(python3 --version)"
else
  warn "python3 not found"
  MISSING_TOOLS+=("python3")
fi

# Docker
if has docker; then
  ok "docker: $(docker --version | head -n1)"
else
  warn "docker not found (needed for sandbox/image scans)"
  echo "  -> Install: https://docs.docker.com/get-docker/"
fi

# AI CLIs
for t in claude codex gemini grok; do
  if has "$t"; then
    ok "$t: installed"
  else
    warn "$t not found (optional AI CLI)"
    case "$t" in
      claude) echo "  -> Install: pip install claude-cli or https://claude.ai/cli" ;;
      codex) echo "  -> Install: npm install -g @openai/codex-cli" ;;
      gemini) echo "  -> Install: pip install google-generativeai-cli" ;;
      grok) echo "  -> Install: pip install grok-cli" ;;
    esac
  fi
done

# GitHub CLI
if has gh; then
  ok "gh: installed"
else
  warn "gh not found (GitHub CLI)"
  echo "  -> Install: https://cli.github.com/"
fi

# SSH
if [ -d "$HOME/.ssh" ] && find "$HOME/.ssh" -name 'id_*' -type f 2>/dev/null | grep -q .; then
  ok "SSH keys present"
else
  warn "No SSH keys in ~/.ssh (use copy_windows_ssh_to_wsl.sh or ssh-keygen)"
fi

# Print actionable installation commands if tools are missing
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
  printf "\n==> Quick install commands:\n"

  # Check OS for appropriate commands
  if [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS
    if ! has brew; then
      echo "First install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi
    for tool in "${MISSING_TOOLS[@]}"; do
      case "$tool" in
        git) echo "brew install git" ;;
        jq) echo "brew install jq" ;;
        rg) echo "brew install ripgrep" ;;
        fd) echo "brew install fd" ;;
        direnv) echo "brew install direnv" ;;
        yq) echo "brew install yq" ;;
        comby) echo "brew install comby" ;;
        node) echo "brew install node" ;;
        python3) echo "brew install python@3" ;;
      esac
    done
  elif [[ "$(uname -s)" == "Linux" ]] || [[ "$(uname -s)" == *"BSD"* ]]; then
    # Linux/BSD/WSL
    # Detect package manager
    if has apt-get; then
      # Debian/Ubuntu
      for tool in "${MISSING_TOOLS[@]}"; do
        case "$tool" in
          git) echo "sudo apt-get install -y git" ;;
          jq) echo "sudo apt-get install -y jq" ;;
          rg) echo "curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb && sudo ssaikg -i ripgrep_14.1.0-1_amd64.deb" ;;
          fd) echo "sudo apt-get install -y fd-find && sudo ln -s \$(which fdfind) /usr/local/bin/fd" ;;
          direnv) echo "sudo apt-get install -y direnv" ;;
          yq) echo "sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq" ;;
          comby) echo "bash <(curl -sL get.comby.dev)" ;;
          node) echo "curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs" ;;
          python3) echo "sudo apt-get install -y python3 python3-pip python3-venv" ;;
        esac
      done
    elif has dnf; then
      # Fedora/RHEL
      for tool in "${MISSING_TOOLS[@]}"; do
        case "$tool" in
          git) echo "sudo dnf install -y git" ;;
          jq) echo "sudo dnf install -y jq" ;;
          rg) echo "sudo dnf install -y ripgrep" ;;
          fd) echo "sudo dnf install -y fd-find" ;;
          direnv) echo "sudo dnf install -y direnv" ;;
          node) echo "sudo dnf install -y nodejs" ;;
          python3) echo "sudo dnf install -y python3 python3-pip" ;;
        esac
      done
    elif has pacman; then
      # Arch Linux
      for tool in "${MISSING_TOOLS[@]}"; do
        case "$tool" in
          git) echo "sudo pacman -S --noconfirm git" ;;
          jq) echo "sudo pacman -S --noconfirm jq" ;;
          rg) echo "sudo pacman -S --noconfirm ripgrep" ;;
          fd) echo "sudo pacman -S --noconfirm fd" ;;
          direnv) echo "sudo pacman -S --noconfirm direnv" ;;
          node) echo "sudo pacman -S --noconfirm nodejs npm" ;;
          python3) echo "sudo pacman -S --noconfirm python python-pip" ;;
        esac
      done
    elif has pkg; then
      # FreeBSD/pkg
      for tool in "${MISSING_TOOLS[@]}"; do
        case "$tool" in
          git) echo "sudo pkg install -y git" ;;
          jq) echo "sudo pkg install -y jq" ;;
          rg) echo "sudo pkg install -y ripgrep" ;;
          fd) echo "sudo pkg install -y fd-find" ;;
          direnv) echo "sudo pkg install -y direnv" ;;
          node) echo "sudo pkg install -y node" ;;
          python3) echo "sudo pkg install -y python3" ;;
        esac
      done
    else
      echo "Package manager not detected. Please install tools manually."
    fi
  else
    # Unknown OS
    echo "Unknown OS: $(uname -s). Please install tools manually."
  fi

  echo ""
  echo "Or run the automated installer:"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "  $PROJECT_ROOT/install/key_software_macos.sh"
  else
    echo "  $PROJECT_ROOT/install/key_software_linux.sh"
  fi
fi

printf "\n==> Next steps:\n"
if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
  echo " ✅ All core tools installed!"
else
  echo " ⚠️  Missing ${#MISSING_TOOLS[@]} tools. Run: ssai doctor --install"
fi
echo " - Setup a project: ssai setup [URL]"
echo " - Initialize: ssai init"
echo " - Browse commands: ssai palette (alias: ssaip)"
echo " - Quick help: ssai help"

# Shell alias reminder
if ! alias ssaip 2>/dev/null | grep -q 'ssai palette'; then
  echo ""
  echo "💡 Pro tip: Add this to ~/.bashrc for quick access:"
  echo "   alias ssaip='ssai palette'"
fi

exit 0
