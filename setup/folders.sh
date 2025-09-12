#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

# ==== EDIT THESE NAMES (optional) ====
ORGS=("org1" "org2")     # your GitHub org folder names
PERSONAL="personal"      # your personal projects folder name
# =====================================

# Base layout
BASES=("$HOME/projects" "$HOME/workspaces" "$HOME/templates/agent-setup" "$HOME/setup" "$HOME/venvs" "$HOME/bin" "$HOME/data" "$HOME/scratch" "$HOME/.claude" "$HOME/.codex" "$HOME/.ssh")
SUBDIRS=("backend" "frontend" "mobile" "infra" "ml" "ops" "data" "docs" "sandbox" "playground")

mk() { mkdir -p "$1" && echo "✔︎ $1"; }

echo "==> Creating base directories"
for b in "${BASES[@]}"; do mk "$b"; done
chmod 700 "$HOME/.ssh"

echo "==> Creating personal workspace"
for s in "${SUBDIRS[@]}"; do mk "$HOME/projects/$PERSONAL/$s"; done
[ -f "$HOME/projects/$PERSONAL/README.md" ] || echo "# $PERSONAL projects" > "$HOME/projects/$PERSONAL/README.md"

echo "==> Creating org workspaces"
for org in "${ORGS[@]}"; do
  for s in "${SUBDIRS[@]}"; do mk "$HOME/projects/$org/$s"; done
  [ -f "$HOME/projects/$org/README.md" ] || echo "# $org projects" > "$HOME/projects/$org/README.md"
done

echo "==> Seeding VS Code workspace files"
for org in "$PERSONAL" "${ORGS[@]}"; do
  WS="$HOME/workspaces/${org}.code-workspace"
  if [ ! -f "$WS" ]; then
    cat > "$WS" <<EOF
{
  "folders": [{ "path": "/home/$USER/projects/$org" }],
  "settings": {
    "window.title": "${org.toUpperCase:-$org} — \${activeEditorShort}",
    "npm.packageManager": "pnpm",
    "git.enableCommitSigning": true
  }
}
EOF
    echo "✔︎ $WS"
  fi
done

echo "==> Seeding agent templates (empty placeholders)"
[ -f "$HOME/templates/agent-setup/CLAUDE.md" ] || cat > "$HOME/templates/agent-setup/CLAUDE.md" <<'EOF'
# Project Guardrails for Claude Code
- Small diffs; branch per task; reference Jira key.
- Secrets: never read/write `.env` or `secrets/**`; redact tokens.
- Output: plan → diff → tests → results.
EOF

[ -f "$HOME/templates/agent-setup/AGENTS.md" ] || cat > "$HOME/templates/agent-setup/AGENTS.md" <<'EOF'
# Project Agent Directives for Codex
- Read-only first; then workspace-write with tests passing.
- Conventional commits; open PRs with checklist.
EOF

echo "==> Done."

echo
echo "Open a workspace:"
echo "  code $HOME/workspaces/${PERSONAL}.code-workspace"
echo "  code $HOME/workspaces/${ORGS[0]}.code-workspace"
echo
echo "Folder preview (top levels):"
find "$HOME/projects" -maxdepth 3 -type d | sed "s|$HOME|~|"
