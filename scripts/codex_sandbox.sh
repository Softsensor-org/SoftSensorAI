#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Sandboxed Codex execution for Linux/WSL - keeps runs contained to repo
set -euo pipefail

# Pass through whichever API keys are set
envs=()
[ -n "${OPENAI_API_KEY:-}" ] && envs+=(-e OPENAI_API_KEY)
[ -n "${XAI_API_KEY:-}" ] && envs+=(-e XAI_API_KEY -e "XAI_BASE_URL=${XAI_BASE_URL:-https://api.x.ai/v1}")
[ -n "${GROQ_API_KEY:-}" ] && envs+=(-e GROQ_API_KEY)
[ -n "${GEMINI_API_KEY:-}" ] && envs+=(-e GEMINI_API_KEY)
[ -n "${ANTHROPIC_API_KEY:-}" ] && envs+=(-e ANTHROPIC_API_KEY)
[ -n "${MISTRAL_API_KEY:-}" ] && envs+=(-e MISTRAL_API_KEY)
[ -n "${DEEPSEEK_API_KEY:-}" ] && envs+=(-e DEEPSEEK_API_KEY)

# Check if at least one API key is set
if [ ${#envs[@]} -eq 0 ]; then
  echo "Error: No API keys found. Set one of:"
  echo "  OPENAI_API_KEY, XAI_API_KEY, GROQ_API_KEY, GEMINI_API_KEY, etc."
  exit 1
fi

# Run Codex in sandboxed Docker container
docker run --rm -it \
  -v "$PWD:/workspace" -w /workspace \
  "${envs[@]}" \
  --network none \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  node:20-bookworm bash -lc '
    # Install Codex if not present
    npm -g i @openai/codex >/dev/null 2>&1 || true

    # Load persona configurations if available
    if [ -f ".codex/settings.json" ]; then
      export CODEX_CONFIG=".codex/settings.json"
    fi
    if [ -f ".claude/personas/active.json" ]; then
      export CODEX_PERSONAS=".claude/personas/active.json"
    fi

    # Run with all arguments passed through
    codex "$@"' -- "$@"
