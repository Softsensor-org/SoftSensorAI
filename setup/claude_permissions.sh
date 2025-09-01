#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Claude Permissions Seeder
# Quickly adds all productivity tool permissions to Claude settings
# ============================================================================

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { printf "\n${BLUE}==> %s${NC}\n" "$*"; }
success() { printf "${GREEN}✓${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
err() { printf "${RED}✗${NC} %s\n" "$*"; }

# Check if Claude settings exist
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
  warn "Claude settings not found at $CLAUDE_SETTINGS"
  echo "Run setup_agents_global.sh first to create initial settings"
  exit 1
fi

log "Updating Claude permissions"

# Backup existing settings
cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.bak"
success "Backed up existing settings to $CLAUDE_SETTINGS.bak"

# Create temporary file with updated permissions
cat > "$CLAUDE_SETTINGS.tmp" <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit", "MultiEdit", "Read", "Grep", "Glob", "LS",
      "Bash(rg:*)", "Bash(fd:*)", "Bash(jq:*)", "Bash(yq:*)", "Bash(http:*)",
      "Bash(gh:*)", "Bash(aws:*)", "Bash(az:*)", "Bash(docker:*)",
      "Bash(kubectl:*)", "Bash(helm:*)", "Bash(terraform:*)",
      "Bash(node:*)", "Bash(npm:*)", "Bash(pnpm:*)", "Bash(npx:*)",
      "Bash(pytest:*)", "Bash(python3:*)", "Bash(pip:*)", "Bash(pipx:*)",
      "Bash(gemini:*)", "Bash(grok:*)", "Bash(codex:*)", "Bash(openai:*)",
      "Bash(just:*)", "Bash(mise:*)", "Bash(devcontainer:*)",
      "Bash(newman:*)", "Bash(redocly:*)", "Bash(spectral:*)", "Bash(openapi-typescript:*)",
      "Bash(rover:*)", "Bash(graphql-codegen:*)",
      "Bash(dbt:*)", "Bash(sqlfluff:*)", "Bash(pgcli:*)", "Bash(sqlite-utils:*)",
      "Bash(prisma:*)", "Bash(drizzle-kit:*)",
      "Bash(dvc:*)", "Bash(wandb:*)", "Bash(mlflow:*)", "Bash(nbstripout:*)",
      "Bash(jupyter:*)", "Bash(ipython:*)",
      "Bash(trivy:*)", "Bash(semgrep:*)", "Bash(gitleaks:*)", "Bash(hadolint:*)",
      "Bash(bandit:*)", "Bash(safety:*)",
      "Bash(ruff:*)", "Bash(black:*)", "Bash(mypy:*)", "Bash(pylint:*)", "Bash(flake8:*)",
      "Bash(prettier:*)", "Bash(eslint:*)", "Bash(tsc:*)",
      "Bash(commitlint:*)", "Bash(cz:*)", "Bash(pre-commit:*)",
      "Bash(kustomize:*)", "Bash(kubectx:*)", "Bash(kubens:*)", "Bash(kind:*)",
      "Bash(skaffold:*)", "Bash(tilt:*)", "Bash(k9s:*)",
      "Bash(changeset:*)", "Bash(cloudflared:*)", "Bash(ngrok:*)",
      "Bash(hyperfine:*)", "Bash(entr:*)", "Bash(watchexec:*)", "Bash(cookiecutter:*)",
      "Bash(cargo:*)", "Bash(go:*)", "Bash(gradle:*)", "Bash(mvn:*)",
      "Bash(make:*)", "Bash(cmake:*)", "Bash(bazel:*)",
      "Bash(poetry:*)", "Bash(pdm:*)", "Bash(hatch:*)", "Bash(uv:*)",
      "Bash(yarn:*)", "Bash(bun:*)", "Bash(deno:*)",
      "Bash(direnv:*)", "Bash(git:*)", "Bash(git-lfs:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(git push --force:*)",
      "Bash(docker push:*)",
      "Bash(terraform apply:*)",
      "Bash(terraform destroy:*)",
      "Bash(aws s3 rm:*)",
      "Bash(aws ec2 terminate-instances:*)",
      "Bash(az group delete:*)",
      "Bash(kubectl delete:*)",
      "Bash(helm uninstall:*)",
      "WebFetch",
      "Write"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(**/.ssh/id_*)",
      "Read(**/*_key)",
      "Read(**/*_secret)",
      "Bash(rm -rf /)",
      "Bash(:(){ :|:& };:)"
    ],
    "defaultMode": "acceptEdits"
  },
  "enableAllProjectMcpServers": true
}
JSON

# Validate JSON
if command -v jq >/dev/null 2>&1; then
  if jq empty "$CLAUDE_SETTINGS.tmp" 2>/dev/null; then
    success "New settings are valid JSON"
  else
    err "Invalid JSON in new settings"
    rm "$CLAUDE_SETTINGS.tmp"
    exit 1
  fi
else
  warn "jq not installed, skipping JSON validation"
fi

# Replace settings
mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
success "Claude permissions updated"

# Summary
log "Permission Summary"
echo ""
echo "Added permissions for:"
echo "  • Core tools (rg, fd, jq, git, make)"
echo "  • Runtime managers (mise, direnv, poetry, pdm)"
echo "  • Package managers (npm, pnpm, yarn, pip, cargo, go)"
echo "  • API tools (OpenAPI, GraphQL, Newman)"
echo "  • Database tools (dbt, sqlfluff, pgcli, ORMs)"
echo "  • ML/DS tools (DVC, W&B, MLflow, Jupyter)"
echo "  • Security scanners (trivy, semgrep, gitleaks)"
echo "  • Linters/formatters (ruff, black, prettier, eslint)"
echo "  • K8s tools (kubectl, helm, kind, skaffold, tilt)"
echo "  • CI/CD tools (gh, docker, terraform, changesets)"
echo ""
echo "Restricted permissions for:"
echo "  • Destructive operations (require confirmation)"
echo "  • Secret/credential files (denied)"
echo ""
success "Claude is now configured to use all productivity tools!"
echo ""
echo "Note: Restart Claude CLI for changes to take effect"
