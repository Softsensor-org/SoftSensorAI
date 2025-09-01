#!/usr/bin/env bash
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
  Linux) ok "OS: Linux" ;;
  Darwin) ok "OS: macOS" ;;
  *) warn "OS: $(uname -s) (untested)" ;;
esac
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
  ok "WSL detected"
fi

# Core tools
for t in git jq rg fd direnv; do
  if has "$t"; then
    ok "$t: $(command -v $t)"
  else
    bad "$t not found"
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
if [ -d "$HOME/.ssh" ] && ls "$HOME/.ssh"/id_* >/dev/null 2>&1; then
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
        node) echo "brew install node" ;;
        python3) echo "brew install python@3" ;;
      esac
    done
  else
    # Linux/WSL
    for tool in "${MISSING_TOOLS[@]}"; do
      case "$tool" in
        git) echo "sudo apt-get install -y git" ;;
        jq) echo "sudo apt-get install -y jq" ;;
        rg) echo "curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb && sudo dpkg -i ripgrep_14.1.0-1_amd64.deb" ;;
        fd) echo "sudo apt-get install -y fd-find && sudo ln -s \$(which fdfind) /usr/local/bin/fd" ;;
        direnv) echo "sudo apt-get install -y direnv" ;;
        node) echo "curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs" ;;
        python3) echo "sudo apt-get install -y python3 python3-pip python3-venv" ;;
      esac
    done
  fi

  echo ""
  echo "Or run the automated installer:"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "  ./install_key_software_macos.sh"
  else
    echo "  ./install_key_software_linux.sh"
  fi
fi

printf "\n==> Next steps:\n"
if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
  echo " ✓ All core tools installed!"
fi
echo " - Clone a repo and run: ./setup/existing_repo_setup.sh"
echo " - Or create new: ./setup/repo_wizard.sh"
echo " - After setup: scripts/apply_profile.sh --skill l1 --phase mvp"

exit 0
