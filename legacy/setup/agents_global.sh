#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# DevPilot Global Agent Setup Script
# Sets up configurations for all AI CLI agents (Claude, Gemini, Grok, Codex)
# Part of DevPilot: Learning-aware AI development platform
# Run this once during initial system setup
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "==> Setting up global agent configurations"

# Create all necessary directories
mkdir -p \
  ~/.claude \
  ~/.gemini \
  ~/.grok \
  ~/.codex \
  ~/templates/agent-setup

# ---------- Claude Global Configuration ----------
echo "  • Configuring Claude CLI (minimal global permissions)"
cat > ~/.claude/settings.json <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit", "MultiEdit", "Read", "Grep", "Glob", "LS",
      "Bash(rg:*)", "Bash(fd:*)", "Bash(jq:*)", "Bash(yq:*)"
    ],
    "ask": [
      "WebFetch",
      "Bash(gh:*)",
      "Bash(git push:*)",
      "Bash(docker:*)",
      "Bash(kubectl:*)",
      "Bash(terraform:*)",
      "Bash(aws:*)",
      "Bash(az:*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "defaultMode": "acceptEdits"
  },
  "enableAllProjectMcpServers": true
}
JSON

# ---------- Gemini CLI Global Configuration ----------
echo "  • Configuring Gemini CLI"
cat > ~/.gemini/settings.json <<'JSON'
{
  "defaultModel": "gemini-2.5-pro",
  "mcpServers": {},
  "telemetry": false
}
JSON

# ---------- Grok CLI Global Configuration ----------
echo "  • Configuring Grok CLI"
cat > ~/.grok/user-settings.json <<'JSON'
{
  "defaultModel": "grok-4-latest",
  "baseURL": "https://api.x.ai/v1"
}
JSON

# ---------- Codex Global Configuration ----------
echo "  • Configuring Codex CLI (YAML)"
mkdir -p ~/.codex
if [ ! -f ~/.codex/config.yaml ]; then
  cat > ~/.codex/config.yaml <<'YAML'
# OpenAI Codex CLI Configuration
model: o4-mini
approvalMode: auto-edit
notify: true

# Sandbox settings
# sandbox: docker
YAML
  echo "    ✓ Wrote ~/.codex/config.yaml"
else
  echo "    • Keeping existing ~/.codex/config.yaml"
fi
if [ -f ~/.codex/config.toml ]; then
  echo "    ⚠ Found legacy ~/.codex/config.toml (YAML is preferred)."
fi

# ---------- Template Files for Repository Setup ----------
echo "  • Creating repository template files"

# Template for CLAUDE.md (repo-specific guardrails)
cat > ~/templates/agent-setup/CLAUDE.md <<'MD'
# Claude Code — Repo Guardrails
- Work in small atomic diffs; always show a unified diff.
- Tests are the contract: list checks first, run, then fix.
- Package manager: **pnpm**. Don't touch lockfiles without asking.
- Secrets hygiene: never read/write `.env*` or `secrets/**`; redact tokens.
- Cloud ops: discovery first (list/describe); ask before deploy/destroy.
- Commits: reference Jira key when given, e.g., `ENG-123: concise summary`.
MD

# Template for AGENTS.md (general agent directives)
cat > ~/templates/agent-setup/AGENTS.md <<'MD'
# Codex / CLI Agent Directives
- Start read-only (plan & inspect), then switch to workspace-write with tests passing.
- Prefer `codex exec "lint, typecheck, unit tests; fix failures"` for non-interactive runs.
- Use conventional commits; open PRs with a checklist and link the ticket.
- Add/adjust tests when changing behavior; keep coverage steady.
- Respect per-repo `.envrc` (direnv) for org-specific tokens/owners.
MD

# Template for .claude/settings.json (repo-specific)
cat > ~/templates/agent-setup/claude-settings.json <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit", "MultiEdit", "Read", "Grep", "Glob", "LS",
      "Bash(rg:*)", "Bash(fd:*)", "Bash(jq:*)", "Bash(yq:*)", "Bash(http:*)",
      "Bash(gh:*)", "Bash(aws:*)", "Bash(az:*)", "Bash(docker:*)",
      "Bash(kubectl:*)", "Bash(helm:*)", "Bash(terraform:*)",
      "Bash(node:*)", "Bash(npm:*)", "Bash(pnpm:*)", "Bash(npx:*)",
      "Bash(pytest:*)", "Bash(python3:*)",
      "Bash(gemini:*)", "Bash(grok:*)", "Bash(codex:*)", "Bash(openai:*)",
      "Bash(codex exec:*)", "Bash(scripts/codex_sandbox.sh:*)",
      "Bash(just:*)", "Bash(mise:*)", "Bash(devcontainer:*)",
      "Bash(newman:*)", "Bash(redocly:*)", "Bash(spectral:*)", "Bash(openapi-typescript:*)",
      "Bash(rover:*)", "Bash(graphql-codegen:*)",
      "Bash(dbt:*)", "Bash(sqlfluff:*)", "Bash(pgcli:*)", "Bash(sqlite-utils:*)",
      "Bash(prisma:*)", "Bash(drizzle-kit:*)",
      "Bash(dvc:*)", "Bash(wandb:*)", "Bash(mlflow:*)", "Bash(nbstripout:*)",
      "Bash(trivy:*)", "Bash(semgrep:*)", "Bash(gitleaks:*)", "Bash(hadolint:*)",
      "Bash(ruff:*)", "Bash(black:*)", "Bash(mypy:*)",
      "Bash(commitlint:*)", "Bash(cz:*)",
      "Bash(kustomize:*)", "Bash(kubectx:*)", "Bash(kubens:*)", "Bash(kind:*)",
      "Bash(skaffold:*)", "Bash(tilt:*)",
      "Bash(changeset:*)", "Bash(cloudflared:*)", "Bash(ngrok:*)",
      "Bash(hyperfine:*)", "Bash(entr:*)", "Bash(watchexec:*)", "Bash(cookiecutter:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(docker push:*)",
      "Bash(terraform apply:*)",
      "Bash(aws s3 rm:*)",
      "Bash(az group delete:*)",
      "WebFetch"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "defaultMode": "acceptEdits"
  }
}
JSON

# Template for .mcp.json (repo-specific MCP servers)
cat > ~/templates/agent-setup/mcp.json <<'JSON'
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "atlassian": {
      "type": "sse",
      "url": "https://mcp.atlassian.com/v1/sse"
    }
  }
}
JSON

echo ""
echo "==> Global agent setup complete!"
echo ""
echo "Configured locations:"
echo "  • ~/.claude/settings.json       - Claude global settings"
echo "  • ~/.gemini/settings.json       - Gemini global settings"
echo "  • ~/.grok/user-settings.json    - Grok global settings"
echo "  • ~/.codex/config.toml          - Codex global settings"
echo "  • ~/templates/agent-setup/      - Templates for repo setup"
echo ""
echo "To set up agents in a specific repository, run:"
echo "  $SCRIPT_DIR/setup_agents_repo.sh"
