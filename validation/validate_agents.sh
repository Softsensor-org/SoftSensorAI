#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agent Configuration Validation Script
# Audits all repositories under ~/projects for proper agent setup
# Usage: ./validate_agents.sh [root_directory]
# ============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration and args
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_OUT=0
DO_FIX=0
ROOT=""

usage() {
  cat <<EOF
Usage: $0 [--json] [--fix] [root_directory]

Validates agent configurations across all git repos under the root directory.

Options:
  --json   Output machine-readable JSON only
  --fix    Auto-seed missing files using setup_agents_repo.sh (no overwrite)
  --help   Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_OUT=1; shift ;;
    --fix) DO_FIX=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) ROOT="${ROOT:-$1}"; shift ;;
  esac
done

ROOT="${ROOT:-$HOME/projects}"
FAIL_COUNT=0
REPO_COUNT=0
OK_COUNT=0
MISSING_COUNT=0

if [[ $JSON_OUT -eq 0 ]]; then
  echo "==> Validating agent configurations under: $ROOT"
  echo ""
fi

# Check if root directory exists
if [[ ! -d "$ROOT" ]]; then
  if [[ $JSON_OUT -eq 1 ]]; then
    echo '{"error":"root_not_found"}'
  else
    echo -e "${RED}[ERROR]${NC} Directory not found: $ROOT"
  fi
  exit 1
fi

# Required files for a properly configured repo
REQUIRED_FILES=(
  "CLAUDE.md"
  ".claude/settings.json"
  ".mcp.json"
  "AGENTS.md"
)

# Optional but recommended files
OPTIONAL_FILES=(
  ".envrc"
  ".envrc.local"
  ".claude/commands/explore-plan-code-test.md"
  ".claude/commands/think-deep.md"
  ".claude/commands/long-context-map-reduce.md"
  ".claude/commands/prefill-structure.md"
  ".claude/commands/prefill-diff.md"
  ".claude/commands/prompt-improver.md"
)

# Find all git repositories
if [[ $JSON_OUT -eq 0 ]]; then
  echo "Scanning for git repositories..."
  echo ""
fi

if [[ $JSON_OUT -eq 1 && ! $(command -v jq) ]]; then
  echo '{"error":"jq_required_for_json"}'
  exit 2
fi

REPOS_JSON_ENTRIES=()

while IFS= read -r -d '' git_dir; do
  REPO="${git_dir%/.git}"
  REPO_REL="${REPO#$ROOT/}"
  REPO_COUNT=$((REPO_COUNT + 1))

  REPO_OK=1
  MISSING_FILES=()
  INVALID_JSON=()
  OPTIONAL_MISSING=()

  # Check required files
  for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$REPO/$file" ]]; then
      MISSING_FILES+=("$file")
      REPO_OK=0
    fi
  done

  # Check optional files
  for file in "${OPTIONAL_FILES[@]}"; do
    if [[ ! -f "$REPO/$file" ]]; then
      OPTIONAL_MISSING+=("$file")
    fi
  done

  # Validate JSON files if jq is available
  if command -v jq >/dev/null 2>&1; then
    if [[ -f "$REPO/.claude/settings.json" ]]; then
      if ! jq -e type "$REPO/.claude/settings.json" >/dev/null 2>&1; then
        INVALID_JSON+=(".claude/settings.json")
        REPO_OK=0
      fi
    fi

    if [[ -f "$REPO/.mcp.json" ]]; then
      if ! jq -e type "$REPO/.mcp.json" >/dev/null 2>&1; then
        INVALID_JSON+=(".mcp.json")
        REPO_OK=0
      fi
    fi

    # Check for .mcp.local.json if it exists
    if [[ -f "$REPO/.mcp.local.json" ]]; then
      if ! jq -e type "$REPO/.mcp.local.json" >/dev/null 2>&1; then
        INVALID_JSON+=(".mcp.local.json")
        REPO_OK=0
      fi
    fi
  fi

  # Auto-fix if requested
  if [[ $DO_FIX -eq 1 && $REPO_OK -ne 1 ]]; then
    (cd "$REPO" && "$SCRIPT_DIR/setup_agents_repo.sh") || true
    # Re-check
    REPO_OK=1; MISSING_FILES=(); OPTIONAL_MISSING=(); INVALID_JSON=()
    for file in "${REQUIRED_FILES[@]}"; do
      [[ -f "$REPO/$file" ]] || { MISSING_FILES+=("$file"); REPO_OK=0; }
    done
    for file in "${OPTIONAL_FILES[@]}"; do
      [[ -f "$REPO/$file" ]] || OPTIONAL_MISSING+=("$file")
    done
  fi

  # Report status
  if [[ $REPO_OK -eq 1 ]]; then
    OK_COUNT=$((OK_COUNT + 1))
    if [[ $JSON_OUT -eq 0 ]]; then
      echo -e "${GREEN}[✓]${NC} $REPO_REL"
      [[ ${#OPTIONAL_MISSING[@]} -gt 0 ]] && echo -e "    ${YELLOW}Optional missing:${NC} ${OPTIONAL_MISSING[*]}"
    fi
  else
    MISSING_COUNT=$((MISSING_COUNT + 1))
    if [[ $JSON_OUT -eq 0 ]]; then
      echo -e "${RED}[✗]${NC} $REPO_REL"
      [[ ${#MISSING_FILES[@]} -gt 0 ]] && echo -e "    ${RED}Missing files:${NC} ${MISSING_FILES[*]}"
    fi
  fi

  if [[ ${#INVALID_JSON[@]} -gt 0 ]]; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
    if [[ $JSON_OUT -eq 0 ]]; then
      echo -e "    ${RED}Invalid JSON:${NC} ${INVALID_JSON[*]}"
    fi
  fi

  if [[ $JSON_OUT -eq 0 && $REPO_OK -ne 1 ]]; then
    [[ ${#OPTIONAL_MISSING[@]} -gt 0 ]] && echo -e "    ${YELLOW}Optional missing:${NC} ${OPTIONAL_MISSING[*]}"
    echo -e "    ${YELLOW}Fix with:${NC} cd \"$REPO\" && $SCRIPT_DIR/setup_agents_repo.sh --force"
  fi

  # Build JSON entry
  if [[ $JSON_OUT -eq 1 ]]; then
    mf_json=$(printf '%s\n' "${MISSING_FILES[@]:-}" | jq -R . | jq -s .)
    of_json=$(printf '%s\n' "${OPTIONAL_MISSING[@]:-}" | jq -R . | jq -s .)
    ij_json=$(printf '%s\n' "${INVALID_JSON[@]:-}" | jq -R . | jq -s .)
    status_val=$([[ $REPO_OK -eq 1 ]] && echo ok || echo needs_config)
    entry=$(jq -n --arg path "$REPO" --arg rel "$REPO_REL" --arg status "$status_val" \
      --argjson missing "$mf_json" --argjson optional_missing "$of_json" --argjson invalid_json "$ij_json" \
      '{path:$path, rel:$rel, status:$status, missing:$missing, optional_missing:$optional_missing, invalid_json:$invalid_json}')
    REPOS_JSON_ENTRIES+=("$entry")
  fi

done < <(find "$ROOT" -type d -name .git -print0 2>/dev/null)

# Summary
if [[ $JSON_OUT -eq 0 ]]; then
  echo ""
  echo "==> Validation Summary"
  echo "───────────────────────"
  echo "Total repositories: $REPO_COUNT"
  echo -e "${GREEN}Properly configured:${NC} $OK_COUNT"
  echo -e "${RED}Need configuration:${NC} $MISSING_COUNT"
  if [[ $FAIL_COUNT -gt 0 ]]; then
    echo -e "${RED}JSON errors:${NC} $FAIL_COUNT"
  fi
  echo ""
fi

# Tool availability check
TOOLS_JSON="{}"
if [[ $JSON_OUT -eq 0 ]]; then
  echo "==> Tool Availability"
  echo "──────────────────────"
fi

tools=(rg fd jq pnpm direnv claude gemini grok codex)
for t in "${tools[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    [[ $JSON_OUT -eq 0 ]] && echo -e "${GREEN}[✓]${NC} $t: $(command -v "$t")"
    if [[ $JSON_OUT -eq 1 ]]; then
      TOOLS_JSON=$(echo "$TOOLS_JSON" | jq --arg k "$t" '. + {($k): true}')
    fi
  else
    [[ $JSON_OUT -eq 0 ]] && echo -e "${YELLOW}[⚠]${NC} $t: not found"
    if [[ $JSON_OUT -eq 1 ]]; then
      TOOLS_JSON=$(echo "$TOOLS_JSON" | jq --arg k "$t" '. + {($k): false}')
    fi
  fi
done

[[ $JSON_OUT -eq 0 ]] && echo ""

# Exit with error if there were failures
if [[ $JSON_OUT -eq 1 ]]; then
  # Emit JSON summary
  repos_json=$(printf '%s\n' "${REPOS_JSON_ENTRIES[@]}" | jq -s '.')
  jq -n --arg root "$ROOT" \
    --argjson summary "$(jq -n --argjson total "$REPO_COUNT" --argjson ok "$OK_COUNT" --argjson need "$MISSING_COUNT" --argjson json_errors "$FAIL_COUNT" '{total:$total, ok:$ok, need_config:$need, json_errors:$json_errors}')" \
    --argjson tools "$TOOLS_JSON" \
    --argjson repos "$repos_json" \
    '{root:$root, summary:$summary, tools:$tools, repos:$repos}'
fi

if [[ $MISSING_COUNT -gt 0 ]] || [[ $FAIL_COUNT -gt 0 ]]; then
  if [[ $JSON_OUT -eq 0 ]]; then
    echo -e "${YELLOW}Tip:${NC} To fix all repositories at once, run:"
    echo "  find $ROOT -type d -name .git -print0 | while IFS= read -r -d '' g; do"
    echo "    r=\"\${g%/.git}\""
    echo "    echo \"Fixing \$r\""
    echo "    (cd \"\$r\" && $SCRIPT_DIR/setup_agents_repo.sh --force)"
    echo "  done"
  fi
  exit 1
else
  if [[ $JSON_OUT -eq 0 ]]; then
    echo -e "${GREEN}All repositories are properly configured!${NC}"
  fi
  exit 0
fi
