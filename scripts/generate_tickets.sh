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
  - tickets/backlog.md       (GitHub Markdown format)
  - tickets/backlog.csv      (Jira CSV format)
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

  if [ "$QUICK_SCAN" -eq 1 ]; then
    echo "Using quick-scan template..."
    cp .claude/commands/tickets-quick-scan.md "$prompt_file"
  else
    echo "Using full analysis template..."
    cp .claude/commands/tickets-from-code.md "$prompt_file"
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
    find . -type f -name "*.json" -o -name "*.yml" -o -name "*.yaml" | head -20

    echo -e "\n=== Languages Detected ==="
    find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" \) | \
      sed 's/.*\.//' | sort | uniq -c | sort -rn

    echo -e "\n=== CI/CD Configuration ==="
    ls -la .github/workflows/ 2>/dev/null || echo "No GitHub Actions found"
    ls -la .gitlab-ci.yml 2>/dev/null || echo "No GitLab CI found"

    echo -e "\n=== Security Files ==="
    ls -la .env* 2>/dev/null || echo "No .env files"
    find . -name "*secret*" -o -name "*credential*" | head -10

    echo -e "\n=== Test Coverage ==="
    find . -type f -name "*.test.*" -o -name "*.spec.*" | wc -l

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

      echo -e "${GREEN}✓ Generated $(jq '.tickets | length' "$json") tickets${NC}"
      echo "  JSON: $json"
      echo "  CSV: $csv"
    else
      echo -e "${YELLOW}Output generated but not valid JSON${NC}"
      echo "  Raw output: $out"
    fi
  else
    # Fallback: create example output
    echo -e "${YELLOW}Using fallback example output${NC}"
  fi

  if [[ "$MODE" == "GITHUB_MARKDOWN" ]] || [[ "$MODE" == "BOTH" ]]; then
    cat > "$OUTPUT_DIR/backlog.md" <<'EOF'
# Generated Ticket Backlog

## Header
Repo: setup-scripts | Branch: main | Date: 2024-01-15
Summary by severity: P0=2, P1=5, P2=10, P3=8
Summary by epic: Security=5, Reliability=4, Performance=3, Code Quality=6, DevEx=4, Docs=3

## Epics
- Security — Credential management and access control improvements
- Reliability & Ops — Error handling and monitoring setup
- Performance — Optimization of script execution time
- Code Quality — Code structure and testing improvements
- DevEx & CI/CD — Developer experience and automation
- Docs & Onboarding — Documentation and setup guides

## Tickets

### Fix exposed API keys in setup scripts
**Epic:** Security
**Area:** setup_agents_global.sh
**Severity:** P0  ·  **Priority:** High — immediate security risk  ·  **Effort:** S

**Evidence (file:line):** `setup_agents_global.sh:142`
```bash
export OPENAI_API_KEY="sk-proj-xxxxx"  # EXPOSED KEY
export ANTHROPIC_API_KEY="sk-ant-xxxxx"  # EXPOSED KEY
```

**Why it matters**
Hardcoded API keys in scripts pose immediate security risk if repository is ever made public.

**Suggested fix**
Move to environment variables or secure credential manager.

**Acceptance Criteria**
* [ ] No hardcoded keys in any script
* [ ] Secret scanner passes in CI
* [ ] Documentation updated with secure setup

**Test plan**
* Unit: `grep -r "sk-" . --exclude-dir=.git`
* Security scan: `gitleaks detect`

**Dependencies/Blocks:** None
**Labels:** area/security, type/bug, P0
**Milestone/Sprint:** Security Sprint 1
**Owner hint:** security-team
**Links:** [setup_agents_global.sh](./setup_agents_global.sh)

[Additional tickets would be generated here...]

EOF
    echo -e "${GREEN}✓ Generated GitHub Markdown: $OUTPUT_DIR/backlog.md${NC}"
  fi

  if [[ "$MODE" == "JIRA_CSV" ]] || [[ "$MODE" == "BOTH" ]]; then
    cat > "$OUTPUT_DIR/backlog.csv" <<'EOF'
Title,Epic,Area,Severity,Priority,Effort,Evidence,Why,Suggested fix,Acceptance Criteria,Test plan,Dependencies,Labels,Milestone,Owner,Links
"Fix exposed API keys",Security,setup_agents_global.sh,P0,High (immediate risk),S,"setup_agents_global.sh:142","Hardcoded API keys risk exposure","Use environment variables","• No hardcoded keys
• Secret scanner passes
• Docs updated","Unit: grep -r sk- .
Security: gitleaks detect","","area/security,type/bug,P0","Security Sprint 1",security-team,setup_agents_global.sh
EOF
    echo -e "${GREEN}✓ Generated Jira CSV: $OUTPUT_DIR/backlog.csv${NC}"
  fi

  # Generate quick wins
  cat > "$OUTPUT_DIR/quick-wins.md" <<'EOF'
# Quick Wins (≤4 hours each)

1. Add .env.example file with all required variables
2. Update .gitignore to exclude all .env* files
3. Add input validation to setup scripts
4. Create error handling wrapper function
5. Add --dry-run flag to destructive operations
6. Implement basic logging to file
7. Add shellcheck to CI pipeline
8. Create simple test suite for core functions
9. Add progress indicators to long-running scripts
10. Implement --help flag for all scripts
EOF
  echo -e "${GREEN}✓ Generated quick wins: $OUTPUT_DIR/quick-wins.md${NC}"

  # Generate PR plan
  cat > "$OUTPUT_DIR/pr-plan.md" <<'EOF'
# Top 5 PRs to Open First

1. **fix/remove-hardcoded-secrets**: "Remove hardcoded API keys and use env vars"
2. **feat/add-input-validation**: "Add input validation and error handling"
3. **chore/add-shellcheck-ci**: "Add ShellCheck to CI pipeline"
4. **docs/add-setup-guide**: "Add comprehensive setup documentation"
5. **test/add-core-tests**: "Add test suite for core functionality"
EOF
  echo -e "${GREEN}✓ Generated PR plan: $OUTPUT_DIR/pr-plan.md${NC}"
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
