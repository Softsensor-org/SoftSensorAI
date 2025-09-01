#!/usr/bin/env bash
set -euo pipefail

ok() { printf "\033[0;32m[OK]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
bad() { printf "\033[0;31m[FAIL]\033[0m %s\n" "$*"; }

has() { command -v "$1" >/dev/null 2>&1; }

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
  if has "$t"; then ok "$t: $(command -v $t)"; else bad "$t not found"; fi
done

# Node + pnpm
if has node; then ok "node: $(node -v)"; else bad "node not found"; fi
if has pnpm; then ok "pnpm: $(pnpm -v)"; else warn "pnpm not found (corepack enable && corepack prepare pnpm@latest --activate)"; fi

# Python
if has python3; then ok "python3: $(python3 --version)"; else warn "python3 not found"; fi

# Docker
if has docker; then ok "docker: $(docker --version | head -n1)"; else warn "docker not found (needed for sandbox/image scans)"; fi

# CLIs
for t in gh claude codex gemini grok; do
  if has "$t"; then ok "$t: installed"; else warn "$t not found"; fi
done

# SSH
if [ -d "$HOME/.ssh" ] && ls "$HOME/.ssh"/id_* >/dev/null 2>&1; then
  ok "SSH keys present"
else
  warn "No SSH keys in ~/.ssh (use copy_windows_ssh_to_wsl.sh or ssh-keygen)"
fi

echo "\nTips:"
echo " - Run './install_key_software_linux.sh' or 'install_key_software_macos.sh' to install missing tools"
echo " - For pnpm: 'corepack enable && corepack prepare pnpm@latest --activate'"
echo " - After setting up a repo: 'scripts/apply_profile.sh --skill beginner --phase mvp'"

exit 0
