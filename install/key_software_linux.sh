#!/usr/bin/env bash
# Cross-distro installer for key developer and agent tools (Linux)
set -euo pipefail

echo "==> Detecting system type"

# Initialize variables
ID=""
ID_LIKE=""

# Detect OS type
if [ -r /etc/os-release ]; then
  . /etc/os-release
elif [ "$(uname -s)" = "FreeBSD" ]; then
  ID="freebsd"
elif [ "$(uname -s)" = "OpenBSD" ]; then
  ID="openbsd"
elif [ "$(uname -s)" = "NetBSD" ]; then
  ID="netbsd"
elif [ "$(uname -s)" = "SunOS" ]; then
  ID="solaris"
elif [[ "$(uname -s)" == CYGWIN* ]] || [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]]; then
  ID="windows"
else
  echo "Warning: Could not detect OS type, attempting generic Unix installation" >&2
  ID="unknown"
fi

ID_LIKE_LOWER=$(echo "${ID_LIKE:-$ID}" | tr '[:upper:]' '[:lower:]')
ID_LOWER=$(echo "${ID}" | tr '[:upper:]' '[:lower:]')

have() { command -v "$1" >/dev/null 2>&1; }

pkg_install() {
  if echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'debian|ubuntu'; then
    sudo apt update
    sudo apt install -y "$@"
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'fedora|rhel|centos|rocky|alma'; then
    sudo dnf install -y "$@" || sudo yum install -y "$@"
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'arch|manjaro'; then
    sudo pacman -Syu --noconfirm "$@"
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'alpine'; then
    sudo apk add "$@"
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'freebsd'; then
    sudo pkg install -y "$@"
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'openbsd|netbsd'; then
    sudo pkg_add "$@"
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'solaris'; then
    sudo pkg install "$@"
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'windows'; then
    echo "Native Windows detected. Please use WSL2 or install tools via scoop/chocolatey." >&2
    return 1
  else
    echo "Unsupported system: $ID_LOWER ($ID_LIKE_LOWER). Please install dependencies manually." >&2
    echo "Attempting to continue with available tools..." >&2
    return 1
  fi
}

echo "==> Installing base packages"
BASE_PKGS=(git curl wget unzip zip ca-certificates)
pkg_install "${BASE_PKGS[@]}"

echo "==> Developer tools"
if echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'debian|ubuntu'; then
  pkg_install build-essential pkg-config libssl-dev
  pkg_install ripgrep fd-find jq direnv python3 python3-venv python3-pip pipx
  # yq via binary if not in repo
  if ! have yq; then
    sudo curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" -o /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq
  fi
  # GitHub CLI
  if ! have gh; then
    type -p apt-key >/dev/null || sudo apt-get update
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt update && sudo apt install -y gh
  fi
else
  # Fedora/Arch package names
  if echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'fedora|rhel|centos'; then
    pkg_install gcc make jq direnv ripgrep fd-find python3 python3-venv python3-pip
    pkg_install gh || true
    # yq
    pkg_install yq || { sudo curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" -o /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq; }
  elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'arch|manjaro'; then
    pkg_install base-devel jq direnv ripgrep fd python python-pip
    pkg_install github-cli || true
    pkg_install yq || true
  fi
fi

echo "==> Node.js (nvm LTS) + pnpm"
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
# shellcheck disable=SC1091
. "$HOME/.nvm/nvm.sh"
nvm install --lts
corepack enable
corepack prepare pnpm@latest --activate

echo "==> Optional developer tools"
# just (binary installer cross-distro)
if ! have just; then
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$HOME/.local/bin"
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# devcontainer CLI
if ! npm list -g @devcontainers/cli >/dev/null 2>&1; then
  npm install -g @devcontainers/cli || true
fi

# Azure CLI
echo "==> Azure CLI"
if echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'debian|ubuntu'; then
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash || true
elif echo "$ID_LIKE_LOWER $ID_LOWER" | grep -Eq 'fedora|rhel|centos'; then
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || true
  sudo dnf install -y ca-certificates curl dnf-plugins-core || true
  sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/azure-cli || true
  sudo dnf install -y azure-cli || true
else
  echo "(azure-cli) Skipping: install manually for distro $ID_LOWER"
fi

# AWS CLI v2
echo "==> AWS CLI v2"
aws_ok=false
if have aws && aws --version 2>/dev/null | grep -q '^aws-cli/2'; then aws_ok=true; fi
if [ "$aws_ok" != true ]; then
  tmp="$(mktemp -d)"; pushd "$tmp" >/dev/null
  arch="$(uname -m)"; case "$arch" in x86_64) url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip";; aarch64|arm64) url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip";; *) echo "Unsupported arch: $arch"; url="";; esac
  if [ -n "$url" ]; then
    curl -fsSLO "$url"
    unzip -q awscli-exe-linux-*.zip
    sudo ./aws/install --update || true
  fi
  popd >/dev/null
fi

echo "==> Done. Open a new shell to pick up PATH changes."
