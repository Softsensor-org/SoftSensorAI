#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# macOS installer for key developer and agent tools (Homebrew-based)
set -euo pipefail

echo "==> Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install from https://brew.sh first." >&2
  exit 1
fi

echo "==> Installing core tooling via Homebrew"
brew update
brew install \
  bash coreutils git curl wget unzip \
  ripgrep fd jq yq direnv gh \
  python python@3.12 \
  just

echo "==> Node.js + pnpm"
if ! command -v fnm >/dev/null 2>&1 && ! command -v nvm >/dev/null 2>&1; then
  brew install fnm
fi
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
  fnm install --lts
  fnm use lts-latest
else
  if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm install --lts
fi
corepack enable
corepack prepare pnpm@latest --activate

echo "==> Developer QoL"
brew install pre-commit || true
npm i -g @devcontainers/cli || true

echo "==> Bash version check"
BREW_BASH=$(brew --prefix)/bin/bash
if [ -x "$BREW_BASH" ]; then
  grep -qxF "/usr/local/bin/bash" ~/.bashrc 2>/dev/null || true
  echo "Note: Use $BREW_BASH to run scripts requiring bash>=4 (macOS default is 3.2)."
fi

echo "==> Done. Open a new terminal to reload PATH."
