#!/usr/bin/env bash
set -euo pipefail

# Simple folder structure without categories
# Creates: org/repo-name (flat structure)

# ==== CONFIGURATION ====
ORGS=("org1" "org2")     # Your organization names
BASE="$HOME/projects"     # Base directory for all projects
# =======================

# Helper directories (not for repos)
HELPERS=("$HOME/bin" "$HOME/.claude" "$HOME/.codex" "$HOME/workspaces")

mk() { mkdir -p "$1" && echo "✔ $1"; }

echo "==> Creating base directory"
mk "$BASE"

echo "==> Creating helper directories"
for h in "${HELPERS[@]}"; do mk "$h"; done

echo "==> Creating organization directories"
for org in "${ORGS[@]}"; do
  mk "$BASE/$org"
  
  # Create a simple README
  cat > "$BASE/$org/README.md" <<EOF
# $org Repositories

## Structure
\`\`\`
$org/
├── repo-name-1/
├── repo-name-2/
├── customer-project/     # For multi-repo projects
│   ├── project-api/
│   └── project-ui/
└── another-repo/
\`\`\`

## Quick Setup

Single repository:
\`\`\`bash
devpilot setup git@github.com:$org/repo-name.git
\`\`\`

Multiple repositories (project):
\`\`\`bash
devpilot setup
> git@github.com:$org/project-api.git
> git@github.com:$org/project-ui.git
> [enter]
\`\`\`

## List All Repos
\`\`\`bash
ls -la $BASE/$org/
\`\`\`
EOF
  echo "✔ Created $BASE/$org/README.md"
done

echo "==> Creating VS Code workspaces"
for org in "${ORGS[@]}"; do
  WS="$HOME/workspaces/${org}.code-workspace"
  if [ ! -f "$WS" ]; then
    cat > "$WS" <<EOF
{
  "folders": [{ "path": "$BASE/$org", "name": "$org" }],
  "settings": {
    "window.title": "$org / \${rootName} / \${activeEditorShort}",
    "files.exclude": {
      "**/node_modules": true,
      "**/.venv": true,
      "**/__pycache__": true,
      "**/.git": false
    }
  }
}
EOF
    echo "✔ $WS"
  fi
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "📂 Structure:"
echo "   $BASE/"
for org in "${ORGS[@]}"; do
  echo "   ├── $org/"
  echo "   │   ├── repo-1/"
  echo "   │   ├── repo-2/"
  echo "   │   └── ..."
done
echo ""
echo "🚀 Quick start:"
echo "   devpilot setup               # Interactive"
echo "   devpilot setup <github-url>  # Direct clone"
echo ""
echo "💻 Open workspace:"
for org in "${ORGS[@]}"; do
  echo "   code $HOME/workspaces/${org}.code-workspace"
done