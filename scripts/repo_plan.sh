#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

# Standalone repository setup planner - shows what would be created without making changes
# Usage: scripts/repo_plan.sh [BASE] [ORG] [CATEGORY] [NAME] [URL] [BRANCH]

BASE="${1:-$HOME/projects}"
ORG="${2:-org1}"
CAT="${3:-backend}"
NAME="${4:-example}"
URL="${5:-git@github.com:ORG/REPO.git}"
BRANCH="${6:-default}"

echo "================= REPO PLAN (DRY) ================"
echo "Base folder    : ${BASE}"
echo "Repo URL       : ${URL}"
echo "Branch         : ${BRANCH}"
echo "Org/Category   : ${ORG} / ${CAT}"
echo "Repo name      : ${NAME}"
echo "Target path    : $(echo "${BASE}/${ORG}/${CAT}/${NAME}" | sed "s|^${HOME}|~|")"
echo
echo "It would perform:"
cat <<EOF
- Ensure base/org/category directories exist
- Clone repository (branch: ${BRANCH})
- Seed guardrails: CLAUDE.md, .claude/settings.json, .mcp.json, commands
- Install commit-message sanitizer hook
- Add scripts: repo_analysis.sh, run_checks.sh, open_pr.sh
- Bootstrap deps (pnpm/npm, Python .venv) if files are present
EOF
echo
echo "It would write/modify:"
cat <<'EOF'
- CLAUDE.md
- .claude/settings.json
- .mcp.json
- .claude/commands/*
- AGENTS.md
- .envrc (if enabled)
- .gitignore (appends)
- .githooks/commit-msg (+ hooksPath)
- scripts/*
EOF
echo "=================================================="
echo
echo "To actually run this setup:"
echo "  ./setup/repo_wizard.sh --base '${BASE}' --org '${ORG}' --category '${CAT}' --url '${URL}' --name '${NAME}'"
[[ "${BRANCH}" != "default" ]] && echo "    --branch '${BRANCH}'"
echo
echo "Or for quick preview:"
echo "  ./setup/repo_wizard.sh --plan-only --org '${ORG}' --category '${CAT}' --url '${URL}' --name '${NAME}'"
