#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

# GitHub Issue Solver
# Picks issues from GitHub, creates branches, and helps solve them with AI

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

say() { echo -e "${CYAN}→${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err() { echo -e "${RED}✗${NC} $*" >&2; }

# Check prerequisites
check_prerequisites() {
    if ! command -v gh >/dev/null 2>&1; then
        err "GitHub CLI (gh) not installed"
        echo "Install with: brew install gh (macOS) or apt install gh (Linux)"
        exit 1
    fi
    
    if ! gh auth status >/dev/null 2>&1; then
        err "Not authenticated with GitHub"
        echo "Run: gh auth login"
        exit 1
    fi
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        err "Not in a git repository"
        exit 1
    fi
}

# List available issues
list_issues() {
    local filter="${1:-all}"
    local limit="${2:-20}"
    
    say "Fetching issues from GitHub..."
    
    case "$filter" in
        bugs)
            gh issue list --label "bug" --limit "$limit"
            ;;
        unassigned)
            gh issue list --assignee "@me" --limit "$limit"
            ;;
        good-first)
            gh issue list --label "good first issue" --limit "$limit"
            ;;
        all)
            gh issue list --limit "$limit"
            ;;
        *)
            gh issue list --limit "$limit"
            ;;
    esac
}

# Pick an issue to work on
pick_issue() {
    say "Available issues:"
    echo ""
    
    # Get issues and format for selection
    local issues=$(gh issue list --limit 20 --json number,title,labels,assignees)
    
    echo "$issues" | jq -r '.[] | "\(.number)|\(.title[0:60])|\(.labels[0].name // "none")"' | \
    while IFS='|' read -r number title label; do
        printf "${BOLD}#%-5s${NC} %-60s ${YELLOW}[%s]${NC}\n" "$number" "$title" "$label"
    done
    
    echo ""
    read -p "Enter issue number to work on (or 'q' to quit): " issue_num
    
    if [[ "$issue_num" == "q" ]]; then
        exit 0
    fi
    
    # Validate issue number
    if ! [[ "$issue_num" =~ ^[0-9]+$ ]]; then
        err "Invalid issue number"
        exit 1
    fi
    
    # Get issue details
    say "Fetching issue #$issue_num..."
    local issue_details=$(gh issue view "$issue_num" --json title,body,labels,assignees)
    
    echo ""
    echo -e "${BOLD}Issue #$issue_num${NC}"
    echo "$issue_details" | jq -r '.title'
    echo ""
    echo "Description:"
    echo "$issue_details" | jq -r '.body' | head -20
    echo ""
    
    read -p "Work on this issue? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        exit 0
    fi
    
    work_on_issue "$issue_num"
}

# Create branch and start working on issue
work_on_issue() {
    local issue_num="$1"
    
    # Get issue details
    local issue_json=$(gh issue view "$issue_num" --json title,body,labels)
    local issue_title=$(echo "$issue_json" | jq -r '.title')
    local issue_body=$(echo "$issue_json" | jq -r '.body')
    
    # Create branch name from issue
    local branch_name="issue-${issue_num}-$(echo "$issue_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | cut -c1-40)"
    
    say "Creating branch: $branch_name"
    git checkout -b "$branch_name" || git checkout "$branch_name"
    
    # Assign issue to self
    gh issue edit "$issue_num" --add-assignee "@me" 2>/dev/null || true
    
    # Create work context file
    local context_file=".github/ISSUE_CONTEXT.md"
    mkdir -p .github
    cat > "$context_file" <<EOF
# Working on Issue #$issue_num

## Title
$issue_title

## Description
$issue_body

## Approach
<!-- AI will fill this -->

## Changes Needed
<!-- AI will analyze and list -->

## Test Plan
<!-- AI will suggest -->

---
*This file helps AI assistants understand the current work context*
EOF
    
    success "Created context file: $context_file"
    
    # Analyze issue with AI
    analyze_issue_with_ai "$issue_num" "$context_file"
}

# Use AI to analyze and suggest solution
analyze_issue_with_ai() {
    local issue_num="$1"
    local context_file="$2"
    
    say "Analyzing issue with AI..."
    
    # Check for AI CLI
    local ai_cli=""
    if command -v claude >/dev/null 2>&1; then
        ai_cli="claude"
    elif command -v openai >/dev/null 2>&1; then
        ai_cli="openai"
    elif command -v gemini >/dev/null 2>&1; then
        ai_cli="gemini"
    else
        warn "No AI CLI found. Install claude, openai, or gemini CLI"
        echo "Skipping AI analysis..."
        return
    fi
    
    # Create analysis prompt
    local prompt="Analyze this GitHub issue and suggest a solution approach:

$(cat "$context_file")

Repository structure:
$(tree -L 2 -I 'node_modules|.git|dist|build' 2>/dev/null || ls -la)

Please provide:
1. Root cause analysis
2. Suggested implementation approach
3. Files that need to be modified
4. Test cases to add
5. Any potential side effects

Format as markdown."
    
    # Run AI analysis
    local analysis_file=".github/ISSUE_ANALYSIS.md"
    echo "# AI Analysis for Issue #$issue_num" > "$analysis_file"
    echo "" >> "$analysis_file"
    
    if [[ "$ai_cli" == "claude" ]]; then
        echo "$prompt" | claude --no-markdown >> "$analysis_file"
    elif [[ "$ai_cli" == "openai" ]]; then
        echo "$prompt" | openai api chat.completions.create -m gpt-4 >> "$analysis_file"
    elif [[ "$ai_cli" == "gemini" ]]; then
        echo "$prompt" | gemini generate >> "$analysis_file"
    fi
    
    success "AI analysis saved to $analysis_file"
    
    # Show summary
    echo ""
    echo -e "${BOLD}AI Analysis Summary:${NC}"
    head -30 "$analysis_file"
    echo ""
    echo "Full analysis in: $analysis_file"
}

# Auto-solve simple issues
auto_solve() {
    local issue_num="$1"
    
    say "Attempting to auto-solve issue #$issue_num..."
    
    # This would integrate with AI to actually implement fixes
    # For now, it creates a structured approach
    
    local solve_script=".github/SOLVE_SCRIPT.sh"
    cat > "$solve_script" <<'EOF'
#!/usr/bin/env bash
# Auto-generated solve script

# 1. Run tests to ensure starting state
echo "Running initial tests..."
npm test 2>/dev/null || pytest 2>/dev/null || go test ./... 2>/dev/null || true

# 2. Make changes (AI would fill this in)
echo "Making changes..."
# TODO: Implement fix

# 3. Run tests again
echo "Running tests after changes..."
npm test 2>/dev/null || pytest 2>/dev/null || go test ./... 2>/dev/null || true

# 4. Commit changes
git add -A
git commit -m "fix: Resolve issue #ISSUE_NUM

- Root cause: [identified cause]
- Solution: [what was changed]
- Testing: [how it was tested]

Fixes #ISSUE_NUM"
EOF
    
    chmod +x "$solve_script"
    success "Created solve script: $solve_script"
    
    echo ""
    echo "Next steps:"
    echo "1. Review the AI analysis"
    echo "2. Implement the fix"
    echo "3. Run: $solve_script"
    echo "4. Push and create PR: gh pr create"
}

# Create PR for solved issue
create_pr() {
    local issue_num="${1:-}"
    
    if [ -z "$issue_num" ]; then
        # Try to extract from branch name
        local branch=$(git branch --show-current)
        issue_num=$(echo "$branch" | grep -oE 'issue-([0-9]+)' | grep -oE '[0-9]+' || echo "")
    fi
    
    if [ -z "$issue_num" ]; then
        err "Cannot determine issue number"
        echo "Usage: $0 create-pr [issue-number]"
        exit 1
    fi
    
    say "Creating PR for issue #$issue_num..."
    
    # Get issue title
    local issue_title=$(gh issue view "$issue_num" --json title --jq '.title')
    
    # Create PR
    gh pr create \
        --title "Fix: $issue_title (#$issue_num)" \
        --body "## Description
Fixes #$issue_num

## Changes
- [List changes made]

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] No regressions identified

## Checklist
- [ ] Code follows project style
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Breaking changes documented

---
*PR created by SoftSensorAI Issue Solver*" \
        --assignee "@me"
    
    success "PR created!"
}

# Main menu
main() {
    local action="${1:-menu}"
    shift || true
    
    check_prerequisites
    
    case "$action" in
        list)
            list_issues "$@"
            ;;
            
        pick)
            pick_issue
            ;;
            
        work)
            local issue_num="$1"
            if [ -z "$issue_num" ]; then
                pick_issue
            else
                work_on_issue "$issue_num"
            fi
            ;;
            
        solve)
            local issue_num="$1"
            if [ -z "$issue_num" ]; then
                err "Issue number required"
                echo "Usage: $0 solve <issue-number>"
                exit 1
            fi
            auto_solve "$issue_num"
            ;;
            
        pr|create-pr)
            create_pr "$@"
            ;;
            
        menu)
            echo -e "${BOLD}${BLUE}GitHub Issue Solver${NC}"
            echo ""
            echo "What would you like to do?"
            echo ""
            echo "  1) List open issues"
            echo "  2) Pick an issue to work on"
            echo "  3) Auto-analyze current issue"
            echo "  4) Create PR for current work"
            echo "  5) Exit"
            echo ""
            read -p "Choice [1-5]: " choice
            
            case "$choice" in
                1) list_issues ;;
                2) pick_issue ;;
                3) 
                    if [ -f ".github/ISSUE_CONTEXT.md" ]; then
                        analyze_issue_with_ai "" ".github/ISSUE_CONTEXT.md"
                    else
                        err "No issue context found. Pick an issue first."
                    fi
                    ;;
                4) create_pr ;;
                5) exit 0 ;;
                *) err "Invalid choice" ;;
            esac
            ;;
            
        help|--help|-h)
            echo "GitHub Issue Solver"
            echo ""
            echo "Usage:"
            echo "  $0 list [filter]      # List issues (bugs|unassigned|good-first|all)"
            echo "  $0 pick              # Interactive issue picker"
            echo "  $0 work <number>     # Start working on specific issue"
            echo "  $0 solve <number>    # Auto-solve simple issue"
            echo "  $0 create-pr         # Create PR for current work"
            echo "  $0 menu              # Interactive menu (default)"
            echo ""
            echo "Examples:"
            echo "  $0 list bugs"
            echo "  $0 work 123"
            echo "  $0 create-pr"
            ;;
            
        *)
            err "Unknown action: $action"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
}

main "$@"