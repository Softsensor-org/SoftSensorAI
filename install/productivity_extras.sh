#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Productivity Extras Installer - Agent Multiplier Tools
# Installs advanced tooling for backend, frontend, DS/ML, and deployment
# All installations are idempotent (safe to run multiple times)
# ============================================================================

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
has() { command -v "$1" >/dev/null 2>&1; }
log() { printf "\n${BLUE}==> %s${NC}\n" "$*"; }
success() { printf "${GREEN}✓${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}⚠${NC} %s\n" "$*"; }

# Update package list
log "Updating package list"
sudo apt-get update -qq

# ============================================================================
# Core Agent Multipliers
# ============================================================================

log "Installing Core Agent Multipliers"

# mise - unified runtime manager
if ! has mise; then
  log "Installing mise (runtime version manager)"
  curl https://mise.run | sh
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc 2>/dev/null || true
  success "mise installed"
else
  success "mise already installed"
fi

# just - task runner
if ! has just; then
  log "Installing just (command runner)"
  sudo apt-get install -y just 2>/dev/null || {
    arch=$(uname -m)
    if [ "$arch" = "x86_64" ]; then
      curl -fsSL https://github.com/casey/just/releases/latest/download/just-1.16.0-x86_64-unknown-linux-musl.tar.gz | tar xz
      sudo mv just /usr/local/bin
    else
      warn "Manual installation needed for just on $arch"
    fi
  }
  success "just installed"
else
  success "just already installed"
fi

# devcontainer CLI
if ! npm list -g @devcontainers/cli >/dev/null 2>&1; then
  log "Installing devcontainer CLI"
  npm install -g @devcontainers/cli
  success "devcontainer CLI installed"
else
  success "devcontainer CLI already installed"
fi

# ============================================================================
# API & Contracts
# ============================================================================

log "Installing API & Contract Tools"

# OpenAPI toolchain
has redocly || { npm install -g @redocly/cli && success "Redocly CLI installed"; }
has spectral || { npm install -g @stoplight/spectral-cli && success "Spectral CLI installed"; }
has openapi-typescript || { npm install -g openapi-typescript && success "openapi-typescript installed"; }

# GraphQL tools
if ! has rover; then
  log "Installing Rover (Apollo GraphQL)"
  curl -sSL https://rover.apollo.dev/nix/latest | sh
  success "Rover installed"
else
  success "Rover already installed"
fi

has graphql-codegen || { npm install -g @graphql-codegen/cli && success "GraphQL Codegen installed"; }
has newman || { npm install -g newman && success "Newman installed"; }

# ============================================================================
# Databases, SQL & Analytics
# ============================================================================

log "Installing Database & Analytics Tools"

# Ensure pipx is in path
pipx ensurepath >/dev/null 2>&1 || true

# Data tools
has dbt || { pipx install dbt-core && success "dbt-core installed"; }
has sqlfluff || { pipx install sqlfluff && success "sqlfluff installed"; }
has pgcli || { pipx install pgcli && success "pgcli installed"; }
has sqlite-utils || { pipx install sqlite-utils && success "sqlite-utils installed"; }

# TypeScript ORMs
has prisma || { npm install -g prisma && success "Prisma CLI installed"; } || true
has drizzle-kit || { npm install -g drizzle-kit && success "Drizzle Kit installed"; } || true

# ============================================================================
# DS/ML Workflow
# ============================================================================

log "Installing Data Science & ML Tools"

# DVC - Data Version Control
has dvc || { pipx install 'dvc[s3]' && success "DVC installed"; }

# Git LFS
if ! has git-lfs; then
  sudo apt-get install -y git-lfs
  git lfs install
  success "Git LFS installed"
else
  success "Git LFS already installed"
fi

# ML experiment tracking
has wandb || { pipx install wandb && success "Weights & Biases CLI installed"; }
has mlflow || { pipx install mlflow && success "MLflow installed"; }

# Notebook tools
has nbstripout || {
  pipx install nbstripout
  nbstripout --install --global
  success "nbstripout installed"
}

# ============================================================================
# Security & Quality Gates
# ============================================================================

log "Installing Security & Quality Tools"

# Container/dependency scanning
if ! has trivy; then
  log "Installing Trivy"
  sudo apt-get install -y wget apt-transport-https gnupg lsb-release
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
  echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
  sudo apt-get update -qq
  sudo apt-get install -y trivy
  success "Trivy installed"
else
  success "Trivy already installed"
fi

# SAST tools
has semgrep || { pipx install semgrep && success "Semgrep installed"; }

# Secret scanning
if ! has gitleaks; then
  log "Installing Gitleaks"
  arch=$(uname -m)
  if [ "$arch" = "x86_64" ]; then
    gitleaks_arch="x64"
  elif [ "$arch" = "aarch64" ]; then
    gitleaks_arch="arm64"
  else
    gitleaks_arch="$arch"
  fi
  curl -fsSL "https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_${gitleaks_arch}.tar.gz" | tar xz
  sudo mv gitleaks /usr/local/bin
  success "Gitleaks installed"
else
  success "Gitleaks already installed"
fi

# Dockerfile linting
if ! has hadolint; then
  log "Installing Hadolint"
  sudo wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
  sudo chmod +x /usr/local/bin/hadolint
  success "Hadolint installed"
else
  success "Hadolint already installed"
fi

# Python quality tools
has ruff || { pipx install ruff && success "Ruff installed"; }
has black || { pipx install black && success "Black installed"; }
has mypy || { pipx install mypy && success "mypy installed"; }

# Commit quality
has commitlint || { npm install -g @commitlint/cli @commitlint/config-conventional && success "commitlint installed"; }
has cz || { npm install -g commitizen && success "commitizen installed"; }

# ============================================================================
# Containers & Kubernetes Dev-Loop
# ============================================================================

log "Installing Container & Kubernetes Tools"

# Kustomize
if ! has kustomize; then
  log "Installing Kustomize"
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
  sudo mv kustomize /usr/local/bin
  success "Kustomize installed"
else
  success "Kustomize already installed"
fi

# kubectx/kubens
if ! has kubectx; then
  log "Installing kubectx/kubens"
  sudo wget -qO /usr/local/bin/kubectx https://github.com/ahmetb/kubectx/releases/latest/download/kubectx
  sudo wget -qO /usr/local/bin/kubens https://github.com/ahmetb/kubectx/releases/latest/download/kubens
  sudo chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens
  success "kubectx/kubens installed"
else
  success "kubectx/kubens already installed"
fi

# kind - local Kubernetes
if ! has kind; then
  log "Installing kind (Kubernetes in Docker)"
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
  sudo install -m 0755 kind /usr/local/bin/kind
  rm -f ./kind
  success "kind installed"
else
  success "kind already installed"
fi

# Skaffold
if ! has skaffold; then
  log "Installing Skaffold"
  curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
  sudo install -m 0755 skaffold /usr/local/bin/skaffold
  rm -f skaffold
  success "Skaffold installed"
else
  success "Skaffold already installed"
fi

# Tilt
if ! has tilt; then
  log "Installing Tilt"
  curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
  success "Tilt installed"
else
  success "Tilt already installed"
fi

# ============================================================================
# Release, CI & Tunnels
# ============================================================================

log "Installing Release & Tunnel Tools"

# Changesets
has changeset || { npm install -g @changesets/cli && success "Changesets installed"; }

# Cloudflared tunnel
if ! has cloudflared; then
  log "Installing Cloudflared"
  # Add cloudflare gpg key
  sudo mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared focal main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
  sudo apt-get update -qq
  sudo apt-get install -y cloudflared
  success "Cloudflared installed"
else
  success "Cloudflared already installed"
fi

# ngrok (optional - requires manual download)
if ! has ngrok; then
  warn "ngrok not installed - visit https://ngrok.com/download for installation"
fi

# ============================================================================
# QoL for Agent Orchestration
# ============================================================================

log "Installing Quality of Life Tools"

# Benchmarking
has hyperfine || { sudo apt-get install -y hyperfine && success "hyperfine installed"; }

# File watching
has entr || { sudo apt-get install -y entr && success "entr installed"; }
has watchexec || {
  if has cargo; then
    cargo install watchexec-cli
    success "watchexec installed"
  else
    warn "watchexec requires Rust/cargo"
  fi
}

# Project scaffolding
has cookiecutter || { pipx install cookiecutter && success "cookiecutter installed"; }

# ============================================================================
# Summary
# ============================================================================

echo ""
log "Installation Complete!"
echo ""
echo "Installed tool categories:"
echo "  • Core multipliers: mise, just, devcontainer"
echo "  • API tools: OpenAPI/GraphQL toolchain"
echo "  • Database: dbt, sqlfluff, pgcli, ORMs"
echo "  • DS/ML: DVC, W&B, MLflow, nbstripout"
echo "  • Security: trivy, semgrep, gitleaks, hadolint"
echo "  • Python: ruff, black, mypy"
echo "  • K8s: kind, kustomize, skaffold, tilt"
echo "  • Release: changesets, cloudflared"
echo "  • QoL: hyperfine, entr, cookiecutter"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal for PATH updates"
echo "  2. Run: ~/repos/setup-scripts/setup_agents_global.sh"
echo "     (to update Claude permissions for new tools)"
echo "  3. Create a justfile in your projects for common tasks"
echo ""
success "All productivity extras installed!"
