#!/usr/bin/env bash
# Generate tickets from codebase analysis
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
MODE="GITHUB_MARKDOWN"
OUTPUT_DIR="tickets"
QUICK_SCAN=0

# Usage
usage() {
  cat <<EOF
Generate Tickets from Code Analysis

Usage: $0 [OPTIONS]

Options:
  --mode MODE        Output format: GITHUB_MARKDOWN, JIRA_CSV, BOTH (default: GITHUB_MARKDOWN)
  --output DIR       Output directory (default: tickets/)
  --quick            Quick 20-minute scan (~15 tickets)
  --runtimes STACK   Runtime stack (e.g., "Node/Python")
  --environment ENV  Target environment (e.g., "Docker+k8s")
  --concerns LIST    Key concerns (e.g., "authz, data privacy, perf")
  --help             Show this help message

Examples:
  # Full analysis with GitHub markdown
  $0 --mode GITHUB_MARKDOWN

  # Quick scan with Jira CSV
  $0 --quick --mode JIRA_CSV --output jira-import/

  # Both formats with specific concerns
  $0 --mode BOTH --concerns "security, performance" --runtimes "Node.js"

Output:
  - tickets/tickets.json     (Raw JSON output from AI)
  - tickets/backlog.csv      (CSV format for import)
  - tickets/backlog.md       (Markdown format)
  - tickets/quick-wins.md    (Low-effort, high-impact items)
  - tickets/pr-plan.md       (Top PRs to open first)

EOF
  exit 0
}

# Parse arguments
RUNTIMES=""
ENVIRONMENT=""
CONCERNS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --quick)
      QUICK_SCAN=1
      shift
      ;;
    --runtimes)
      RUNTIMES="$2"
      shift 2
      ;;
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --concerns)
      CONCERNS="$2"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      usage
      ;;
  esac
done

# Validate mode
if [[ ! "$MODE" =~ ^(GITHUB_MARKDOWN|JIRA_CSV|BOTH)$ ]]; then
  echo -e "${RED}Invalid mode: $MODE${NC}"
  echo "Valid options: GITHUB_MARKDOWN, JIRA_CSV, BOTH"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get repository info
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)" 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TODAY=$(date +%Y-%m-%d)

echo -e "${BLUE}=== Ticket Generation from Code ===${NC}"
echo "Repository: $REPO_NAME"
echo "Branch: $BRANCH"
echo "Commit: $SHA"
echo "Mode: $MODE"
echo "Output: $OUTPUT_DIR/"
if [ "$QUICK_SCAN" -eq 1 ]; then
  echo "Type: Quick scan (20 minutes)"
else
  echo "Type: Full analysis"
fi
echo ""

# Build the prompt
build_prompt() {
  local prompt_file="$OUTPUT_DIR/.prompt.md"

  # Check for template files or create a minimal one
  if [ "$QUICK_SCAN" -eq 1 ]; then
    if [ -f ".claude/commands/tickets-quick-scan.md" ]; then
      echo "Using quick-scan template..."
      cp .claude/commands/tickets-quick-scan.md "$prompt_file"
    else
      echo "Creating minimal quick-scan template..."
      cat > "$prompt_file" <<'EOF'
Analyze this codebase and generate a prioritized ticket backlog.
Output strict JSON with this schema:
{
  "tickets": [
    {
      "id": "PROJ-001",
      "title": "Short descriptive title",
      "type": "bug|feature|chore|docs",
      "priority": "P0|P1|P2|P3",
      "effort": "XS|S|M|L|XL",
      "labels": ["area/security", "type/bug"],
      "assignee": "",
      "dependencies": [],
      "notes": "Brief description",
      "acceptance_criteria": ["Criteria 1", "Criteria 2"]
    }
  ]
}
Focus on: security issues, bugs, performance problems, and missing tests.
EOF
    fi
  else
    if [ -f ".claude/commands/tickets-from-code.md" ]; then
      echo "Using full analysis template..."
      cp .claude/commands/tickets-from-code.md "$prompt_file"
    else
      echo "Creating minimal analysis template..."
      cat > "$prompt_file" <<'EOF'
Analyze the entire codebase and generate a comprehensive ticket backlog.
Output strict JSON with this schema:
{
  "tickets": [
    {
      "id": "PROJ-001",
      "title": "Short descriptive title",
      "type": "bug|feature|chore|docs",
      "priority": "P0|P1|P2|P3",
      "effort": "XS|S|M|L|XL",
      "labels": ["area/security", "type/bug"],
      "assignee": "",
      "dependencies": [],
      "notes": "Detailed description with context",
      "acceptance_criteria": ["Criteria 1", "Criteria 2", "Criteria 3"]
    }
  ]
}
Analyze: security vulnerabilities, bugs, performance issues, tech debt, missing tests, documentation gaps.
EOF
    fi
  fi

  # Replace variables (BSD/macOS compatible)
  sed -i'' -e "s/{{MODE}}/$MODE/g" "$prompt_file"
  sed -i'' -e "s/{{REPO_NAME}}/$REPO_NAME/g" "$prompt_file"
  sed -i'' -e "s/{{BRANCH}}/$BRANCH/g" "$prompt_file"
  sed -i'' -e "s/{{SHA}}/$SHA/g" "$prompt_file"
  sed -i'' -e "s/{{TODAY}}/$TODAY/g" "$prompt_file"

  if [ -n "$RUNTIMES" ]; then
    sed -i'' -e "s/{{Node\/Python\/...}}/$RUNTIMES/g" "$prompt_file"
  fi

  if [ -n "$ENVIRONMENT" ]; then
    sed -i'' -e "s/{{Docker+k8s on cloud}}/$ENVIRONMENT/g" "$prompt_file"
  fi

  if [ -n "$CONCERNS" ]; then
    sed -i'' -e "s/{{e.g., authz, data privacy, perf \/api\/search}}/$CONCERNS/g" "$prompt_file"
  fi

  echo "$prompt_file"
}

# Analyze repository
analyze_repo() {
  echo -e "${BLUE}Analyzing repository structure...${NC}"

  local analysis="$OUTPUT_DIR/.analysis.txt"

  {
    echo "=== Repository Structure ==="
    find . -type f \( -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) | head -20

    echo -e "\n=== Languages Detected ==="
    find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" \) | \
      sed 's/.*\.//' | sort | uniq -c | sort -rn

    echo -e "\n=== CI/CD Configuration ==="
    ls -la .github/workflows/ 2>/dev/null || echo "No GitHub Actions found"
    ls -la .gitlab-ci.yml 2>/dev/null || echo "No GitLab CI found"

    echo -e "\n=== Security Files ==="
    ls -la .env* 2>/dev/null || echo "No .env files"
    find . -type f \( -iname "*secret*" -o -iname "*credential*" \) | head -10

    echo -e "\n=== Test Coverage ==="
    find . -type f \( -name "*.test.*" -o -name "*.spec.*" \) | wc -l

    echo -e "\n=== Dependencies ==="
    [ -f package.json ] && jq '.dependencies | keys | length' package.json
    [ -f requirements.txt ] && wc -l < requirements.txt
    [ -f go.mod ] && grep -c "require" go.mod
  } > "$analysis"

  echo "Analysis saved to: $analysis"
}

# Generate tickets
generate_tickets() {
  local prompt_file="$1"

  echo -e "${BLUE}Generating tickets...${NC}"

  # CLI-first ticket generation with fallback chain
  local out="$OUTPUT_DIR/tickets_raw.txt"
  local json="$OUTPUT_DIR/tickets.json"
  local csv="$OUTPUT_DIR/backlog.csv"
  : > "$out"

  # Try each CLI in order until one works
  try_cli() {
    "$@" > "$out" 2>>"$OUTPUT_DIR/tickets.err" || return 1
    [ -s "$out" ] || return 1
    return 0
  }

  run_ticket_generation() {
    local pf="$1"

    # Try Claude first
    if command -v claude >/dev/null 2>&1; then
      echo "Using Claude CLI..."
      try_cli claude --system-prompt system/active.md --input-file "$pf" && return 0
    fi

    # Try Codex
    if command -v codex >/dev/null 2>&1; then
      echo "Using Codex CLI..."
      try_cli codex exec --system-file system/active.md --input-file "$pf" && return 0
    fi

    # Try Gemini
    if command -v gemini >/dev/null 2>&1; then
      echo "Using Gemini CLI..."
      try_cli gemini generate --model gemini-1.5-pro-latest --system-file system/active.md --prompt-file "$pf" && return 0
    fi

    # Try Grok
    if command -v grok >/dev/null 2>&1; then
      echo "Using Grok CLI..."
      try_cli grok chat --system "$(cat system/active.md 2>/dev/null || echo 'Generate tickets')" --input-file "$pf" && return 0
    fi

    echo -e "${YELLOW}No AI CLI found. Install claude, codex, gemini, or grok.${NC}"
    return 1
  }

  if run_ticket_generation "$prompt_file"; then
    # Extract JSON from output (handles various CLI response formats)
    awk '/^{/,0' "$out" > "$json" 2>/dev/null || true

    # Convert to CSV if valid JSON
    if [ -s "$json" ] && jq -e . "$json" >/dev/null 2>&1; then
      jq -r '.tickets[] | [
        .id,
        .title,
        .type,
        .priority,
        .effort,
        (.labels // [] | join("|")),
        (.assignee // ""),
        (.dependencies // [] | join("|")),
        (.notes // "" | gsub("[\r\n]+"; " ")),
        (.acceptance_criteria // [] | join("; "))
      ] | @csv' "$json" > "$csv" 2>/dev/null || true

      # Generate Markdown versions
      jq -r '
        "# Backlog\n\n" +
        ( .tickets
          | map("* " + .id + " — " + .title + " (" + .priority + "/" + .effort + ")")
          | join("\n")
        )
      ' "$json" > "$OUTPUT_DIR/backlog.md" 2>/dev/null || true

      # Generate quick wins (low effort, high priority)
      jq -r '
        "# Quick Wins\n\n" +
        ( .tickets
          | map(select(.effort == "XS" or .effort == "S"))
          | map(select(.priority == "P0" or .priority == "P1"))
          | map("* " + .id + " — " + .title)
          | join("\n")
        )
      ' "$json" > "$OUTPUT_DIR/quick-wins.md" 2>/dev/null || true

      # Generate PR plan (first 5 high priority items)
      jq -r '
        "# PR Plan\n\n" +
        "Top tickets to implement first:\n\n" +
        ( .tickets
          | sort_by(.priority)
          | .[0:5]
          | map("1. " + .id + " — " + .title + "\n   - Priority: " + .priority + "\n   - Effort: " + .effort)
          | join("\n\n")
        )
      ' "$json" > "$OUTPUT_DIR/pr-plan.md" 2>/dev/null || true

      echo -e "${GREEN}✓ Generated $(jq '.tickets | length' "$json") tickets${NC}"
      echo "  JSON: $json"
      echo "  CSV: $csv"
      echo "  Markdown: $OUTPUT_DIR/backlog.md"
      echo "  Quick wins: $OUTPUT_DIR/quick-wins.md"
      echo "  PR plan: $OUTPUT_DIR/pr-plan.md"
    else
      echo -e "${YELLOW}Output generated but not valid JSON${NC}"
      echo "  Raw output: $out"
    fi
  else
    echo -e "${YELLOW}No AI CLI found. Cannot generate tickets.${NC}"
    echo "Install one of: claude, codex, gemini, or grok"
    exit 1
  fi
}

# Main execution
echo -e "${YELLOW}Step 1: Building prompt...${NC}"
PROMPT_FILE=$(build_prompt)

echo -e "${YELLOW}Step 2: Analyzing repository...${NC}"
analyze_repo

echo -e "${YELLOW}Step 3: Generating tickets...${NC}"
generate_tickets "$PROMPT_FILE"

echo ""
echo -e "${GREEN}=== Ticket Generation Complete ===${NC}"
echo "Output files:"
ls -la "$OUTPUT_DIR"/*.md "$OUTPUT_DIR"/*.csv 2>/dev/null | awk '{print "  " $9}'
echo ""
echo "Next steps:"
echo "  1. Review generated tickets in $OUTPUT_DIR/"
echo "  2. Run quality gates: /ticket-quality-gates"
echo "  3. Import to issue tracker"
echo "  4. Create first PR from pr-plan.md"
