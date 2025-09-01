#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Stack-based installer wrapper
# Provides flag-based installation of tool categories
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

# Parse flags
INSTALL_API=0
INSTALL_ML=0
INSTALL_SEC=0
INSTALL_K8S=0
INSTALL_ALL=0

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Install productivity tools by stack category.

Options:
  --with-api     Install API development tools (OpenAPI, GraphQL, Newman)
  --with-ml      Install ML/DS tools (DVC, W&B, MLflow, nbstripout)
  --with-sec     Install security tools (trivy, semgrep, gitleaks, hadolint)
  --with-k8s     Install Kubernetes tools (kind, kustomize, skaffold, tilt)
  --all          Install all stacks
  --help         Show this help message

Examples:
  # Install API and ML tools
  $0 --with-api --with-ml

  # Install everything
  $0 --all

EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-api)
      INSTALL_API=1
      shift
      ;;
    --with-ml)
      INSTALL_ML=1
      shift
      ;;
    --with-sec)
      INSTALL_SEC=1
      shift
      ;;
    --with-k8s)
      INSTALL_K8S=1
      shift
      ;;
    --all)
      INSTALL_ALL=1
      shift
      ;;
    --help|-h)
      show_help
      ;;
    *)
      warn "Unknown option: $1"
      show_help
      ;;
  esac
done

# If --all, enable all stacks
if [[ $INSTALL_ALL -eq 1 ]]; then
  INSTALL_API=1
  INSTALL_ML=1
  INSTALL_SEC=1
  INSTALL_K8S=1
fi

# If no flags, show help
if [[ $INSTALL_API -eq 0 ]] && [[ $INSTALL_ML -eq 0 ]] && [[ $INSTALL_SEC -eq 0 ]] && [[ $INSTALL_K8S -eq 0 ]]; then
  warn "No stacks selected"
  show_help
fi

# Update package list
log "Updating package list"
sudo apt-get update -qq

# Ensure pipx is in path
pipx ensurepath >/dev/null 2>&1 || true

# ============================================================================
# API Stack
# ============================================================================

if [[ $INSTALL_API -eq 1 ]]; then
  log "Installing API Development Stack"
  
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
  
  # Database tools
  has pgcli || { pipx install pgcli && success "pgcli installed"; }
  has sqlite-utils || { pipx install sqlite-utils && success "sqlite-utils installed"; }
  has dbt || { pipx install dbt-core && success "dbt-core installed"; }
  has sqlfluff || { pipx install sqlfluff && success "sqlfluff installed"; }
  
  success "API stack installed"
fi

# ============================================================================
# ML/DS Stack
# ============================================================================

if [[ $INSTALL_ML -eq 1 ]]; then
  log "Installing ML/DS Stack"
  
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
  
  # Jupyter extensions
  has jupyter || { pipx install jupyter && success "Jupyter installed"; }
  
  success "ML/DS stack installed"
fi

# ============================================================================
# Security Stack
# ============================================================================

if [[ $INSTALL_SEC -eq 1 ]]; then
  log "Installing Security Stack"
  
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
  
  # Python security tools
  has bandit || { pipx install bandit && success "Bandit installed"; }
  has safety || { pipx install safety && success "Safety installed"; }
  
  success "Security stack installed"
fi

# ============================================================================
# Kubernetes Stack
# ============================================================================

if [[ $INSTALL_K8S -eq 1 ]]; then
  log "Installing Kubernetes Stack"
  
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
  
  # k9s - Kubernetes CLI UI
  if ! has k9s; then
    log "Installing k9s"
    curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | tar xz
    sudo mv k9s /usr/local/bin
    success "k9s installed"
  else
    success "k9s already installed"
  fi
  
  success "Kubernetes stack installed"
fi

# Summary
echo ""
log "Installation Complete!"
echo ""
echo "Installed stacks:"
[[ $INSTALL_API -eq 1 ]] && echo "  • API Development"
[[ $INSTALL_ML -eq 1 ]] && echo "  • ML/DS"
[[ $INSTALL_SEC -eq 1 ]] && echo "  • Security"
[[ $INSTALL_K8S -eq 1 ]] && echo "  • Kubernetes"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal for PATH updates"
echo "  2. Run: ~/repos/setup-scripts/seed_claude_permissions.sh"
echo "     (to update Claude permissions for new tools)"
echo ""
success "Stack installation complete!"
