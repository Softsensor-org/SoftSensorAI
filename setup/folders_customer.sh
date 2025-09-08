#!/usr/bin/env bash
set -euo pipefail

# Customer-based folder structure
# Creates: org/customer/project/category/repo

# ==== CONFIGURATION ====
ORGS=("org1" "org2")     # Your organization names
BASE="$HOME/projects"     # Base directory for all projects
# =======================

# Base layout for non-project folders
BASES=("$BASE" "$HOME/workspaces" "$HOME/templates/agent-setup" "$HOME/setup" "$HOME/venvs" "$HOME/bin" "$HOME/data" "$HOME/scratch" "$HOME/.claude" "$HOME/.codex" "$HOME/.ssh")

# Project categories (within each project)
CATEGORIES=("backend" "frontend" "mobile" "infra" "ml" "ops" "data" "docs" "sandbox")

mk() { mkdir -p "$1" && echo "✔︎ $1"; }

echo "==> Creating base directories"
for b in "${BASES[@]}"; do mk "$b"; done
chmod 700 "$HOME/.ssh"

echo "==> Creating organization structure"
for org in "${ORGS[@]}"; do
  mk "$BASE/$org"
  
  # Create a sample structure to demonstrate
  # In real use, customer/project folders are created by customer_project_wizard.sh
  cat > "$BASE/$org/README.md" <<EOF
# $org Projects

## Structure
\`\`\`
$org/
├── customer1/
│   ├── project1/
│   │   ├── backend/
│   │   ├── frontend/
│   │   └── ...
│   └── project2/
└── customer2/
    └── project1/
\`\`\`

## Quick Setup

Use the customer project wizard to set up new projects:
\`\`\`bash
~/repos/setup-scripts-fresh/setup/customer_project_wizard.sh \\
  --org $org \\
  --customer "customer_name" \\
  --project "project_name" \\
  --repos "repo1_url repo2_url"
\`\`\`

## Existing Projects
Run \`find $BASE/$org -name PROJECT.json\` to list all projects.
EOF
  echo "✔︎ Created $BASE/$org/README.md"
done

echo "==> Creating organization workspaces"
for org in "${ORGS[@]}"; do
  WS="$HOME/workspaces/${org}.code-workspace"
  if [ ! -f "$WS" ]; then
    cat > "$WS" <<EOF
{
  "folders": [{ "path": "$BASE/$org", "name": "$org" }],
  "settings": {
    "window.title": "$org — \${activeEditorShort}",
    "npm.packageManager": "pnpm",
    "git.enableCommitSigning": true,
    "files.exclude": {
      "**/node_modules": true,
      "**/.venv": true,
      "**/__pycache__": true
    }
  }
}
EOF
    echo "✔︎ $WS"
  fi
done

echo "==> Seeding agent templates"
[ -f "$HOME/templates/agent-setup/CLAUDE.md" ] || cat > "$HOME/templates/agent-setup/CLAUDE.md" <<'EOF'
# Project Guardrails for Claude Code
- Small diffs; branch per task; reference Jira key.
- Secrets: never read/write `.env` or `secrets/**`; redact tokens.
- Output: plan → diff → tests → results.
- Structure: org/customer/project/category/repo
EOF

[ -f "$HOME/templates/agent-setup/AGENTS.md" ] || cat > "$HOME/templates/agent-setup/AGENTS.md" <<'EOF'
# Project Agent Directives
- Read-only first; then workspace-write with tests passing.
- Conventional commits; open PRs with checklist.
- Follow org/customer/project structure.
EOF

echo "==> Creating helper script for customer projects"
HELPER="$HOME/bin/new-customer-project"
cat > "$HELPER" <<'EOF'
#!/usr/bin/env bash
# Quick launcher for customer project wizard
exec "$HOME/repos/setup-scripts-fresh/setup/customer_project_wizard.sh" "$@"
EOF
chmod +x "$HELPER"
echo "✔︎ Created helper: new-customer-project"

echo "==> Done!"
echo ""
echo "📂 Folder Structure:"
echo "   $BASE/"
echo "   ├── org1/"
echo "   │   └── customer/"
echo "   │       └── project/"
echo "   │           ├── backend/"
echo "   │           ├── frontend/"
echo "   │           └── ..."
echo "   └── org2/"
echo ""
echo "🚀 Quick Start:"
echo "   new-customer-project --org org1 --customer acme --project webapp"
echo ""
echo "📖 Or use the interactive wizard:"
echo "   $HOME/repos/setup-scripts-fresh/setup/customer_project_wizard.sh"
echo ""
echo "💻 Open workspace:"
for org in "${ORGS[@]}"; do
  echo "   code $HOME/workspaces/${org}.code-workspace"
done