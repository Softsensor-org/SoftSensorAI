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

# Configuration
ROOT="${1:-$HOME/projects}"
FAIL_COUNT=0
REPO_COUNT=0
OK_COUNT=0
MISSING_COUNT=0

echo "==> Validating agent configurations under: $ROOT"
echo ""

# Check if root directory exists
if [[ ! -d "$ROOT" ]]; then
  echo -e "${RED}[ERROR]${NC} Directory not found: $ROOT"
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
  ".claude/commands/fix-ci-failures.md"
)

# Find all git repositories
echo "Scanning for git repositories..."
echo ""

while IFS= read -r -d '' git_dir; do
  REPO="${git_dir%/.git}"
  REPO_NAME=$(basename "$REPO")
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
  
  # Report status
  if [[ $REPO_OK -eq 1 ]]; then
    echo -e "${GREEN}[✓]${NC} $REPO_REL"
    OK_COUNT=$((OK_COUNT + 1))
    
    # Show optional missing files if any
    if [[ ${#OPTIONAL_MISSING[@]} -gt 0 ]]; then
      echo -e "    ${YELLOW}Optional missing:${NC} ${OPTIONAL_MISSING[*]}"
    fi
  else
    echo -e "${RED}[✗]${NC} $REPO_REL"
    MISSING_COUNT=$((MISSING_COUNT + 1))
    
    # Show what's missing
    if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
      echo -e "    ${RED}Missing files:${NC} ${MISSING_FILES[*]}"
    fi
    
    # Show invalid JSON files
    if [[ ${#INVALID_JSON[@]} -gt 0 ]]; then
      echo -e "    ${RED}Invalid JSON:${NC} ${INVALID_JSON[*]}"
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # Show optional missing files
    if [[ ${#OPTIONAL_MISSING[@]} -gt 0 ]]; then
      echo -e "    ${YELLOW}Optional missing:${NC} ${OPTIONAL_MISSING[*]}"
    fi
    
    # Suggest fix
    echo -e "    ${YELLOW}Fix with:${NC} cd \"$REPO\" && ~/setup/setup_agents_repo.sh"
  fi
  
done < <(find "$ROOT" -type d -name .git -print0 2>/dev/null)

# Summary
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

# Tool availability check
echo "==> Tool Availability"
echo "──────────────────────"

check_tool() {
  local tool="$1"
  local name="${2:-$tool}"
  if command -v "$tool" >/dev/null 2>&1; then
    echo -e "${GREEN}[✓]${NC} $name: $(command -v "$tool")"
  else
    echo -e "${YELLOW}[⚠]${NC} $name: not found"
  fi
}

check_tool "rg" "ripgrep"
check_tool "fd" "fd-find"
check_tool "jq" "jq"
check_tool "pnpm" "pnpm"
check_tool "direnv" "direnv"
check_tool "claude" "Claude CLI"
check_tool "gemini" "Gemini CLI"
check_tool "grok" "Grok CLI"
check_tool "codex" "Codex CLI"

echo ""

# Exit with error if there were failures
if [[ $MISSING_COUNT -gt 0 ]] || [[ $FAIL_COUNT -gt 0 ]]; then
  echo -e "${YELLOW}Tip:${NC} To fix all repositories at once, run:"
  echo "  find $ROOT -type d -name .git -print0 | while IFS= read -r -d '' g; do"
  echo "    r=\"\${g%/.git}\""
  echo "    echo \"Fixing \$r\""
  echo "    (cd \"\$r\" && ~/setup/setup_agents_repo.sh --force)"
  echo "  done"
  exit 1
else
  echo -e "${GREEN}All repositories are properly configured!${NC}"
  exit 0
fi