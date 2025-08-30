#!/usr/bin/env bash
set -euo pipefail

log() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

log "Detecting WSL"
if [ -z "${WSL_DISTRO_NAME:-}" ]; then
  echo "This script is intended for WSL. Abort."; exit 1
fi

log "APT update & core packages"
sudo apt update
sudo apt install -y \
  build-essential curl wget unzip zip ca-certificates gnupg lsb-release software-properties-common \
  git pkg-config libssl-dev \
  openssh-client direnv keychain \
  ripgrep fd-find jq fzf bat httpie git-delta \
  python3 python3-venv python3-pip pipx

# Nice aliases for Debian/Ubuntu names
grep -qxF 'alias fd=fdfind'  ~/.bashrc || echo 'alias fd=fdfind'  >> ~/.bashrc
grep -qxF 'alias bat=batcat' ~/.bashrc || echo 'alias bat=batcat' >> ~/.bashrc

log "Install yq (latest binary)"
if ! has yq; then
  sudo curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" \
    -o /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq
fi

log "GitHub CLI (gh)"
if ! has gh; then
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt update && sudo apt install -y gh
fi

log "Azure CLI (az)"
if ! has az; then
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

log "AWS CLI v2 (official bundle)"
aws_ok=false
if has aws; then
  if aws --version 2>/dev/null | grep -q '^aws-cli/2'; then aws_ok=true; fi
fi
if [ "$aws_ok" != true ]; then
  tmp="$(mktemp -d)"; pushd "$tmp" >/dev/null
  arch="$(uname -m)"
  if [ "$arch" = "x86_64" ]; then url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  elif [ "$arch" = "aarch64" ]; then url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
  else echo "Unsupported arch: $arch"; exit 1; fi
  curl -fsSLO "$url"
  unzip -q awscli-exe-linux-*.zip
  sudo ./aws/install --update
  popd >/dev/null
fi

log "Node (nvm → LTS) + pnpm"
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
# shellcheck disable=SC1091
. "$HOME/.nvm/nvm.sh"
nvm install --lts
corepack enable
corepack prepare pnpm@latest --activate

log "Python user tooling"
pipx ensurepath || true
if ! has uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

log "Claude Code & Codex CLIs"
npm -g ls @anthropic-ai/claude-code >/dev/null 2>&1 || npm install -g @anthropic-ai/claude-code
npm -g ls @openai/codex >/dev/null 2>&1 || npm install -g @openai/codex || echo "Note: Codex CLI install failed; you can retry later."

log "direnv hook"
grep -qxF 'eval "$(direnv hook bash)"' ~/.bashrc || echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

log "SSH agent convenience (keychain)"
grep -qxF 'eval $(keychain --quiet --agents ssh --eval ~/.ssh/id_ed25519)' ~/.bashrc \
  || echo 'eval $(keychain --quiet --agents ssh --eval ~/.ssh/id_ed25519)' >> ~/.bashrc

log "Done. Open a NEW terminal so PATH updates take effect."

echo
echo "Quick checks to run next:"
echo "  gh --version    && gh auth login"
echo "  az version | head -n1 && az login"
echo "  aws --version   && aws configure sso   # or export keys"
echo "  node -v && pnpm -v && python3 --version && pipx --version"
echo "  claude --help   && codex --help"
echo
echo "Docker note: install Docker Desktop on Windows and enable WSL integration, then test with 'docker version' in WSL."
