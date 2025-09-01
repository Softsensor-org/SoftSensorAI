#!/usr/bin/env bash
# Pattern Selector - Quick access to design patterns
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="${REGISTRY:-prompts/registry.yaml}"
PATTERNS_DIR=".claude/commands/patterns"
PATTERN="${1:-}"
ACTION="${2:-show}"

# Show usage
usage() {
  cat <<EOF
Pattern Selector - Quick access to design pattern prompts

Usage: $0 [pattern-name] [action]

Actions:
  show    - Display the pattern (default)
  copy    - Copy to clipboard
  list    - List all available patterns
  search  - Search patterns by tag
  chain   - Show a command chain

Examples:
  $0                        # List all patterns
  $0 backend-feature        # Show backend feature pattern
  $0 bug-fix copy          # Copy bug fix pattern to clipboard
  $0 search security       # Find security-related patterns
  $0 chain feature-full    # Show feature implementation chain

Available Patterns:
EOF

  if command -v yq >/dev/null 2>&1; then
    yq eval '.patterns | keys | .[]' "$REGISTRY" 2>/dev/null | sed 's/^/  /'
  else
    grep "^  [a-z-]*:" "$REGISTRY" | sed 's/://' | sort | uniq
  fi
  exit 0
}

# List all patterns with descriptions
list_patterns() {
  echo -e "${BLUE}Available Design Patterns:${NC}\n"

  if command -v yq >/dev/null 2>&1; then
    yq eval '.patterns | to_entries | .[] | "• " + .key + ": " + .value.description' "$REGISTRY"
  else
    # Fallback to basic grep
    echo "Patterns:"
    find "$PATTERNS_DIR" -name "*.md" -print0 2>/dev/null | xargs -0 -n1 basename | sed 's/\.md$//' | sed 's/^/  • /'
  fi

  echo -e "\n${CYAN}Command Chains:${NC}"
  if command -v yq >/dev/null 2>&1; then
    yq eval '.chains | to_entries | .[] | "• " + .key + ": " + .value.description' "$REGISTRY"
  else
    echo "  (Install yq for chain support)"
  fi
}

# Search patterns by tag
search_patterns() {
  local tag="$1"
  echo -e "${BLUE}Patterns tagged with '${tag}':${NC}\n"

  if command -v yq >/dev/null 2>&1; then
    yq eval ".patterns | to_entries | .[] | select(.value.tags[] | contains(\"$tag\")) | .key + \": \" + .value.description" "$REGISTRY"
  else
    grep -l "$tag" "$PATTERNS_DIR"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//'
  fi
}

# Show a specific pattern
show_pattern() {
  local pattern="$1"
  local file="$PATTERNS_DIR/${pattern}.md"

  if [[ -f "$file" ]]; then
    echo -e "${GREEN}Pattern: ${pattern}${NC}\n"
    cat "$file"
  else
    echo -e "${RED}Pattern not found: ${pattern}${NC}"
    echo "Use '$0 list' to see available patterns"
    exit 1
  fi
}

# Copy pattern to clipboard
copy_pattern() {
  local pattern="$1"
  local file="$PATTERNS_DIR/${pattern}.md"

  if [[ ! -f "$file" ]]; then
    echo -e "${RED}Pattern not found: ${pattern}${NC}"
    exit 1
  fi

  # Try different clipboard commands
  if command -v pbcopy >/dev/null 2>&1; then
    cat "$file" | pbcopy
    echo -e "${GREEN}✓ Pattern '${pattern}' copied to clipboard (pbcopy)${NC}"
  elif command -v xclip >/dev/null 2>&1; then
    cat "$file" | xclip -selection clipboard
    echo -e "${GREEN}✓ Pattern '${pattern}' copied to clipboard (xclip)${NC}"
  elif command -v clip.exe >/dev/null 2>&1; then
    cat "$file" | clip.exe
    echo -e "${GREEN}✓ Pattern '${pattern}' copied to clipboard (Windows)${NC}"
  else
    echo -e "${YELLOW}No clipboard utility found. Pattern content:${NC}"
    cat "$file"
  fi
}

# Show command chain
show_chain() {
  local chain="$1"

  if ! command -v yq >/dev/null 2>&1; then
    echo -e "${RED}yq required for chain support${NC}"
    echo "Install with: pip install yq"
    exit 1
  fi

  echo -e "${BLUE}Command Chain: ${chain}${NC}\n"

  # Get chain description
  desc=$(yq eval ".chains.${chain}.description" "$REGISTRY" 2>/dev/null)
  if [[ "$desc" == "null" || -z "$desc" ]]; then
    echo -e "${RED}Chain not found: ${chain}${NC}"
    exit 1
  fi

  echo -e "${CYAN}Description:${NC} $desc\n"
  echo -e "${CYAN}Steps:${NC}"

  # Get and display steps
  yq eval ".chains.${chain}.steps[]" "$REGISTRY" | while read -r step; do
    step_desc=$(yq eval ".patterns.${step}.description" "$REGISTRY" 2>/dev/null)
    echo "  1. ${step}: ${step_desc}"
  done

  echo -e "\n${YELLOW}To execute:${NC}"
  yq eval ".chains.${chain}.steps[]" "$REGISTRY" | while read -r step; do
    echo "  $0 ${step} show"
  done
}

# Quick tool reference
show_tools() {
  echo -e "${BLUE}Quick Tool Commands:${NC}\n"

  if command -v yq >/dev/null 2>&1; then
    yq eval '.tools | to_entries | .[] | "• " + .key + ": " + .value' "$REGISTRY"
  else
    cat <<EOF
• lint-type-test: pnpm lint && pnpm typecheck && pnpm test -i
• full-check: scripts/run_checks.sh
• search: rg -n '<pattern>'
• diff-size: git diff --stat
• sql-lint: sqlfluff lint .
• security-scan: semgrep --config auto; trivy fs .; gitleaks detect
• perf-bench: hyperfine '<cmd>' --warmup 3
• api-lint: redocly lint openapi.yaml; openapi-typescript
EOF
  fi
}

# Main logic
case "${1:-list}" in
  list|ls|-l|--list)
    list_patterns
    ;;
  search|-s|--search)
    search_patterns "${2:-}"
    ;;
  chain|-c|--chain)
    show_chain "${2:-}"
    ;;
  tools|-t|--tools)
    show_tools
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    # Pattern name provided
    case "${ACTION}" in
      copy|-c|--copy)
        copy_pattern "$PATTERN"
        ;;
      show|-s|--show|"")
        show_pattern "$PATTERN"
        ;;
      *)
        echo -e "${RED}Unknown action: ${ACTION}${NC}"
        usage
        ;;
    esac
    ;;
esac
