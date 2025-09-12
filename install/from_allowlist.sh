#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

log() { printf "\n\033[1;36m==> %s\033[0m\n" "$*"; }
warn() { printf "\n\033[1;33m[warn]\033[0m %s\n" "$*"; }
err() { printf "\n\033[1;31m[err]\033[0m %s\n" "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

[ -n "${WSL_DISTRO_NAME:-}" ] || { err "This script is for WSL Ubuntu."; exit 1; }

ARCH_DEB="$(dpkg --print-architecture)"               # amd64 | arm64
ARCH_DL="${ARCH_DEB/amd64/x86_64}"                    # for some tarballs
ARCH_DL="${ARCH_DL/arm64/arm64}"

# ---------- Base APT ----------
log "APT update & base packages"
sudo apt update
sudo apt install -y \
  ca-certificates curl wget gnupg lsb-release software-properties-common \
  build-essential unzip zip tar pkg-config libssl-dev \
  git ripgrep fd-find jq httpie fzf bat git-delta \
  python3 python3-venv python3-pip pipx \
  postgresql-client sqlite3 tesseract-ocr ffmpeg

# nice aliases for Debian names
grep -qxF 'alias fd=fdfind'  ~/.bashrc || echo 'alias fd=fdfind'  >> ~/.bashrc
grep -qxF 'alias bat=batcat' ~/.bashrc || echo 'alias bat=batcat' >> ~/.bashrc

# yq (latest binary)
if ! has yq; then
  log "Installing yq (binary)"
  sudo curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH_DEB}" \
    -o /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq
fi

# ---------- Repos we may need ----------
sudo install -m 0755 -d /etc/apt/keyrings

add_repo_once() { # name key_url list_file line
  local name="$1" key="$2" list="$3" line="$4"
  if [ ! -f "$list" ]; then
    log "Adding APT repo: $name"
    curl -fsSL "$key" | sudo gpg --dearmor -o "/etc/apt/keyrings/${name}.gpg"
    echo "$line" | sudo tee "$list" >/dev/null
    echo "repo:$name added"
    return 0
  fi
  return 1
}

NEED_UPDATE=0

# GitHub CLI
if ! has gh; then
  if add_repo_once githubcli \
      https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      /etc/apt/sources.list.d/github-cli.list \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main"; then
    NEED_UPDATE=1
  fi
fi

# Docker (CLI only)
if ! has docker; then
  if add_repo_once docker \
      https://download.docker.com/linux/ubuntu/gpg \
      /etc/apt/sources.list.d/docker.list \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo $VERSION_CODENAME) stable"; then
    NEED_UPDATE=1
  fi
fi

# Kubernetes kubectl (new pkgs.k8s.io)
if ! has kubectl; then
  if add_repo_once kubernetes \
      https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
      /etc/apt/sources.list.d/kubernetes.list \
      "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /"; then
    NEED_UPDATE=1
  fi
fi

# HashiCorp (terraform)
if ! has terraform; then
  if add_repo_once hashicorp \
      https://apt.releases.hashicorp.com/gpg \
      /etc/apt/sources.list.d/hashicorp.list \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main"; then
    NEED_UPDATE=1
  fi
fi

# Helm
if ! has helm; then
  if add_repo_once helm \
      https://baltocdn.com/helm/signing.asc \
      /etc/apt/sources.list.d/helm-stable-debian.list \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main"; then
    NEED_UPDATE=1
  fi
fi

# k6
if ! has k6; then
  if add_repo_once k6 \
      https://dl.k6.io/key.gpg \
      /etc/apt/sources.list.d/k6.list \
      "deb [signed-by=/etc/apt/keyrings/k6.gpg] https://dl.k6.io/deb/ stable main"; then
    NEED_UPDATE=1
  fi
fi

# 1Password CLI (op)
if ! has op; then
  if add_repo_once 1password \
      https://downloads.1password.com/linux/keys/1password.asc \
      /etc/apt/sources.list.d/1password.list \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/1password.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main"; then
    NEED_UPDATE=1
  fi
fi

[ "$NEED_UPDATE" -eq 1 ] && { log "APT update (new repos)"; sudo apt update; }

# ---------- Install APT-based tools ----------
has gh        || { log "Installing gh";        sudo apt install -y gh; }
has docker    || { log "Installing docker-ce-cli"; sudo apt install -y docker-ce-cli; }
has kubectl   || { log "Installing kubectl";   sudo apt install -y kubectl; }
has helm      || { log "Installing helm";      sudo apt install -y helm; }
has terraform || { log "Installing terraform"; sudo apt install -y terraform; }
has k6        || { log "Installing k6";        sudo apt install -y k6; }
has sops      || { log "Installing sops";      sudo apt install -y sops; }
has op        || { log "Installing 1Password CLI (op)"; sudo apt install -y 1password-cli || warn "1Password CLI repo/arch not available"; }

# ---------- Node & npm-based tools ----------
if ! has node; then
  log "Installing Node (nvm → LTS)"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm install --lts
else
  # shellcheck disable=SC1091
  [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh" || true
fi

log "Enabling corepack (pnpm)"
corepack enable || true
corepack prepare pnpm@latest --activate || npm i -g pnpm

has tsx        || { log "Installing tsx";        npm i -g tsx; }
has playwright || { log "Installing playwright"; npm i -g playwright; }
# (optional) install browsers on demand:
# sudo npx playwright install --with-deps

# ---------- Python user-space tools ----------
pipx ensurepath || true
has pre-commit || { log "Installing pre-commit (pipx)"; pipx install pre-commit; }
has checkov    || { log "Installing checkov (pipx)";    pipx install checkov; }
has openai     || { log "Installing openai CLI (pipx)"; pipx install openai; }

# ---------- GitHub Actions runner (act) ----------
if ! has act; then
  log "Installing act"
  tmp="$(mktemp -d)"; pushd "$tmp" >/dev/null
  fname="act_Linux_${ARCH_DL}.tar.gz"
  curl -fsSLO "https://github.com/nektos/act/releases/latest/download/${fname}"
  tar -xzf "$fname"
  sudo install -m 0755 act /usr/local/bin/act
  popd >/dev/null
fi

# ---------- aws-vault ----------
if ! has aws-vault; then
  log "Installing aws-vault"
  url="https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-${ARCH_DEB}"
  sudo curl -fsSL "$url" -o /usr/local/bin/aws-vault
  sudo chmod +x /usr/local/bin/aws-vault
fi

# ---------- k9s ----------
if ! has k9s; then
  log "Installing k9s"
  tmp="$(mktemp -d)"; pushd "$tmp" >/dev/null
  tgz="k9s_Linux_${ARCH_DL}.tar.gz"
  curl -fsSLO "https://github.com/derailed/k9s/releases/latest/download/${tgz}"
  tar -xzf "$tgz"
  sudo install -m 0755 k9s /usr/local/bin/k9s
  popd >/dev/null
fi

# ---------- stern ----------
if ! has stern; then
  log "Installing stern"
  tmp="$(mktemp -d)"; pushd "$tmp" >/dev/null
  tgz="stern_${ARCH_DL}.tar.gz"
  curl -fsSLO "https://github.com/stern/stern/releases/latest/download/${tgz}"
  tar -xzf "$tgz"
  sudo install -m 0755 stern /usr/local/bin/stern
  popd >/dev/null
fi

# ---------- terragrunt ----------
if ! has terragrunt; then
  log "Installing terragrunt"
  sudo curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_${ARCH_DEB}" \
    -o /usr/local/bin/terragrunt
  sudo chmod +x /usr/local/bin/terragrunt
fi

# ---------- duckdb CLI ----------
if ! has duckdb; then
  log "Installing duckdb CLI"
  tmp="$(mktemp -d)"; pushd "$tmp" >/dev/null
  zipname="duckdb_cli-linux-${ARCH_DEB}.zip"
  curl -fsSLO "https://github.com/duckdb/duckdb/releases/latest/download/${zipname}"
  unzip -q "$zipname"
  sudo install -m 0755 duckdb /usr/local/bin/duckdb
  popd >/dev/null
fi

# ---------- Quality-of-life: ensure symlinks for fd/bat ----------
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat

log "All set."

echo
echo "Next steps / checks:"
echo "  rg --version && fd --version && jq --version && yq --version"
echo "  gh --version && pre-commit --version && aws-vault --version && sops --version && op --version || true"
echo "  docker --version && kubectl version --client --output=yaml && helm version"
echo "  k9s version || true; stern --version; terraform version; terragrunt --version; checkov --version"
echo "  act --version; k6 version; duckdb --version; psql --version; sqlite3 --version"
echo "  openai --help; tesseract --version; ffmpeg -version | head -n1"
echo "  pnpm -v; tsx -v; playwright -V"
