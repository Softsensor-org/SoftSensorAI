#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail
# Require Node >= 20
if ! command -v node >/dev/null; then echo "Node not found. Install Node (nvm LTS) first."; exit 1; fi
node -e 'process.exit(process.versions.node.split(".")[0] >= 20 ? 0 : 1)' || { echo "Need Node >= 20"; exit 1; }

# Gemini CLI (official)
npm -g ls @google/gemini-cli >/dev/null 2>&1 || npm install -g @google/gemini-cli

# Grok CLI (community)
npm -g ls @vibe-kit/grok-cli >/dev/null 2>&1 || npm install -g @vibe-kit/grok-cli

# Minimal config dirs
mkdir -p ~/.gemini ~/.grok ~/.secrets

# Seed optional settings (won't overwrite existing)
[ -f ~/.gemini/settings.json ] || cat > ~/.gemini/settings.json <<'JSON'
{ "defaultModel": "gemini-2.5-pro", "mcpServers": {} }
JSON
[ -f ~/.grok/user-settings.json ] || cat > ~/.grok/user-settings.json <<'JSON'
{ "defaultModel": "grok-4-latest", "baseURL": "https://api.x.ai/v1" }
JSON

echo "Done. Next:"
echo "  1) For Gemini: run 'gemini' and choose OAuth, or 'export GEMINI_API_KEY=...'"
echo "  2) For Grok 4: 'export XAI_API_KEY=grk-...' (or GROK_API_KEY) then 'grok'"
