#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/sh/common.sh"

# ============================================================================
# Productivity Extras Installer - Agent Multiplier Tools
# Installs advanced tooling for backend, frontend, DS/ML, and deployment
# All installations are idempotent (safe to run multiple times)
# ============================================================================

# Update package list
log "Updating package list"
if has apt-get; then
    sudo apt-get update -qq
fi

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
if ! has redocly; then
    npm install -g @redocly/cli
    success "Redocly CLI installed"
else
    success "Redocly CLI already installed"
fi
if ! has spectral; then
    npm install -g @stoplight/spectral-cli
    success "Spectral CLI installed"
else
    success "Spectral CLI already installed"
fi
if ! has openapi-typescript; then
    npm install -g openapi-typescript
    success "openapi-typescript installed"
else
    success "openapi-typescript already installed"
fi

# GraphQL tools
if ! has rover; then
  log "Installing Rover (Apollo GraphQL)"
  curl -sSL https://rover.apollo.dev/nix/latest | sh
  success "Rover installed"
else
  success "Rover already installed"
fi

if ! has graphql-codegen; then
    npm install -g @graphql-codegen/cli
    success "GraphQL Codegen installed"
else
    success "GraphQL Codegen already installed"
fi
if ! has newman; then
    npm install -g newman
    success "Newman installed"
else
    success "Newman already installed"
fi

# ============================================================================
# Databases, SQL & Analytics
# ============================================================================

log "Installing Database & Analytics Tools"

# Ensure pipx is in path
pipx ensurepath >/dev/null 2>&1 || true

# Data tools
if ! has dbt; then
    pipx install dbt-core
    success "dbt-core installed"
else
    success "dbt-core already installed"
fi
if ! has sqlfluff; then
    pipx install sqlfluff
    success "sqlfluff installed"
else
    success "sqlfluff already installed"
fi
if ! has pgcli; then
    pipx install pgcli
    success "pgcli installed"
else
    success "pgcli already installed"
fi
if ! has sqlite-utils; then
    pipx install sqlite-utils
    success "sqlite-utils installed"
else
    success "sqlite-utils already installed"
fi

# TypeScript ORMs
if ! has prisma; then
    npm install -g prisma && success "Prisma CLI installed" || warn "Failed to install Prisma CLI"
else
    success "Prisma CLI already installed"
fi
if ! has drizzle-kit; then
    npm install -g drizzle-kit && success "Drizzle Kit installed" || warn "Failed to install Drizzle Kit"
else
    success "Drizzle Kit already installed"
fi

# ============================================================================
# DS/ML Workflow
# ============================================================================

log "Installing Data Science & ML Tools"

# DVC - Data Version Control
if ! has dvc; then
    pipx install 'dvc[s3]'
    success "DVC installed"
else
    success "DVC already installed"
fi

# Git LFS
if ! has git-lfs; then
  sudo apt-get install -y git-lfs
  git lfs install
  success "Git LFS installed"
else
  success "Git LFS already installed"
fi

# ML experiment tracking
if ! has wandb; then
    pipx install wandb
    success "Weights & Biases CLI installed"
else
    success "Weights & Biases CLI already installed"
fi
if ! has mlflow; then
    pipx install mlflow
    success "MLflow installed"
else
    success "MLflow already installed"
fi

# Notebook tools
if ! has nbstripout; then
    pipx install nbstripout
    nbstripout --install --global
    success "nbstripout installed"
else
    success "nbstripout already installed"
fi

# ============================================================================
# Security & Quality Gates
# ============================================================================

log "Installing Security & Quality Tools"

# Container/dependency scanning
if ! has trivy; then
  log "Installing Trivy"
  if has apt-get; then
    sudo apt-get install -y wget apt-transport-https gnupg
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(get_os_codename 2>/dev/null || echo "stable") main" | sudo tee /etc/apt/sources.list.d/trivy.list
    sudo apt-get update -qq
    sudo apt-get install -y trivy
  else
    log "Installing Trivy via binary (apt not available)"
    TRIVY_VERSION=$(curl -s "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v${TRIVY_VERSION}
  fi
  success "Trivy installed"
else
  success "Trivy already installed"
fi

# SAST tools
if ! has semgrep; then
    pipx install semgrep
    success "Semgrep installed"
else
    success "Semgrep already installed"
fi

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
if ! has ruff; then
    pipx install ruff
    success "Ruff installed"
else
    success "Ruff already installed"
fi
if ! has black; then
    pipx install black
    success "Black installed"
else
    success "Black already installed"
fi
if ! has mypy; then
    pipx install mypy
    success "mypy installed"
else
    success "mypy already installed"
fi

# Commit quality
if ! has commitlint; then
    npm install -g @commitlint/cli @commitlint/config-conventional
    success "commitlint installed"
else
    success "commitlint already installed"
fi
if ! has cz; then
    npm install -g commitizen
    success "commitizen installed"
else
    success "commitizen already installed"
fi

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
if ! has changeset; then
    npm install -g @changesets/cli
    success "Changesets installed"
else
    success "Changesets already installed"
fi

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
if ! has hyperfine; then
    if has apt-get; then
        sudo apt-get install -y hyperfine
        success "hyperfine installed"
    else
        warn "hyperfine requires apt package manager"
    fi
else
    success "hyperfine already installed"
fi

# File watching
if ! has entr; then
    if has apt-get; then
        sudo apt-get install -y entr
        success "entr installed"
    else
        warn "entr requires apt package manager"
    fi
else
    success "entr already installed"
fi
if ! has watchexec; then
    if has cargo; then
        cargo install watchexec-cli
        success "watchexec installed"
    else
        warn "watchexec requires Rust/cargo"
    fi
else
    success "watchexec already installed"
fi

# Project scaffolding
if ! has cookiecutter; then
    pipx install cookiecutter
    success "cookiecutter installed"
else
    success "cookiecutter already installed"
fi

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
