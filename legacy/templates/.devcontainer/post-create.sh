#!/usr/bin/env bash
set -euo pipefail

# Post-create script for devcontainer
# Runs after the container is created to set up project-specific dependencies

echo "==> Running post-create setup..."

# Install project dependencies if they exist
if [ -f "package.json" ]; then
  echo "Installing Node.js dependencies..."
  if [ -f "pnpm-lock.yaml" ]; then
    pnpm install
  elif [ -f "yarn.lock" ]; then
    yarn install
  else
    npm install
  fi
fi

if [ -f "requirements.txt" ]; then
  echo "Installing Python dependencies..."
  pip install -r requirements.txt
elif [ -f "pyproject.toml" ]; then
  echo "Installing Python project..."
  pip install -e .
fi

if [ -f "go.mod" ]; then
  echo "Downloading Go modules..."
  go mod download
fi

if [ -f "Cargo.toml" ]; then
  echo "Fetching Rust dependencies..."
  cargo fetch
fi

# Set up pre-commit hooks if configured
if [ -f ".pre-commit-config.yaml" ]; then
  echo "Installing pre-commit hooks..."
  pip install --user pre-commit
  pre-commit install
fi

# Create .env from example if it exists
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
  echo "Creating .env from .env.example..."
  cp .env.example .env
fi

# Set up direnv if .envrc exists
if [ -f ".envrc" ]; then
  echo "Allowing direnv..."
  direnv allow .
fi

# Run any project-specific setup
if [ -f "scripts/setup.sh" ]; then
  echo "Running project setup script..."
  bash scripts/setup.sh
elif [ -f "justfile" ] && command -v just >/dev/null; then
  echo "Running just setup..."
  just setup || true
fi

echo "==> Post-create setup complete!"
echo ""
echo "Container is ready! Available commands:"
echo "  just         - Show available tasks (if justfile exists)"
echo "  mise         - Manage runtime versions"
echo "  direnv       - Auto-load environment variables"
echo ""