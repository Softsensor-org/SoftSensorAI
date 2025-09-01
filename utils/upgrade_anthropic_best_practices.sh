#!/usr/bin/env bash
# Apply Anthropic's official best practices for Claude development
set -euo pipefail

echo "=== Applying Anthropic Best Practices ==="
echo "This script adds high-leverage improvements from official guidance"
echo ""

# Helper function
backup() {
  [ -f "$1" ] && cp -a "$1" "$1.bak.$(date +%Y%m%d%H%M%S)" && echo "  Backed up: $1"
}

# 1. Security Review GitHub Action
echo "==> 1) Security Review GitHub Action"
mkdir -p .github/workflows
if [ ! -f .github/workflows/security-review.yml ]; then
  cat > .github/workflows/security-review.yml <<'EOF'
name: Security Review

on:
  pull_request:
    types: [opened, synchronize]
  workflow_dispatch:
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Mondays

jobs:
  security-scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write

    steps:
      - uses: actions/checkout@v4

      - name: Setup tools
        run: |
          pip install semgrep
          wget -qO- https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_x64.tar.gz | tar xz
          sudo mv gitleaks /usr/local/bin/

      - name: Run scans
        run: |
          semgrep --config=auto --json -o semgrep.json . || true
          gitleaks detect --no-banner -v --report-format json --report-path gitleaks.json || true

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: security-results
          path: '*.json'
EOF
  echo "✓ Created security-review.yml"
else
  echo "• Kept existing security-review.yml"
fi

# 2. Claude Commands
echo "==> 2) Claude Commands (/security-review, /think-hard)"
mkdir -p .claude/commands

if [ ! -f .claude/commands/security-review.md ]; then
  cat > .claude/commands/security-review.md <<'EOF'
# Security Review

Perform comprehensive security review focusing on highest-impact fixes.

## Process
1. Run scanners (npm audit, semgrep, gitleaks, trivy)
2. Prioritize by severity (Critical > High > Medium)
3. Fix top issues with minimal diffs
4. Verify fixes don't break functionality
5. Re-run scanners to confirm resolution

## Output
- Issues found/fixed summary
- Diffs for each fix
- Verification results
- Remaining work prioritized
EOF
  echo "✓ Created /security-review command"
else
  echo "• Kept existing /security-review"
fi

if [ ! -f .claude/commands/think-hard.md ]; then
  cat > .claude/commands/think-hard.md <<'EOF'
# Think Hard

Deep analysis mode for complex problems.

## Framework
1. **Problem Decomposition**: Core issue, constraints, success criteria
2. **Solution Exploration**: 3-5 approaches with trade-offs
3. **Decision Matrix**: Compare options on risk/effort/impact
4. **Recommendation**: Selected approach with rationale
5. **Implementation Plan**: Phased approach with rollback strategy

Use for: architecture decisions, performance optimization, debugging mysteries
EOF
  echo "✓ Created /think-hard command"
else
  echo "• Kept existing /think-hard"
fi

# 3. Update CLAUDE.md with performance tips
echo "==> 3) CLAUDE.md Performance & Git Sections"
if [ -f CLAUDE.md ]; then
  if ! grep -q "^# Performance" CLAUDE.md; then
    backup CLAUDE.md
    cat >> CLAUDE.md <<'EOF'

# Performance
- **Parallel Tools**: Call multiple tools in ONE message (Read, Grep, Bash).
- **Temp Cleanup**: After temp files: `rm -f /tmp/temp_* 2>/dev/null`
- **Batch Operations**: Use MultiEdit for multiple edits; batch git ops.
- **Search First**: Use Grep/Glob before Read to minimize context.

# Git Workflow
- **Worktrees**: For parallel work: `git worktree add ../proj-fix fix-branch`
- **Atomic Commits**: One logical change per commit.
- **Branch Hygiene**: Delete merged branches; rebase regularly.
- **No Force Push**: Never force push to main/shared branches.
EOF
    echo "✓ Added Performance & Git sections to CLAUDE.md"
  else
    echo "• CLAUDE.md already has Performance section"
  fi
else
  echo "! No CLAUDE.md found - run setup_agents_repo.sh first"
fi

# 4. Worktree Helper
echo "==> 4) Git Worktree Helper"
mkdir -p tools
if [ ! -f tools/worktree_helper.sh ]; then
  cat > tools/worktree_helper.sh <<'EOF'
#!/usr/bin/env bash
# Git worktree helper for parallel Claude sessions
set -euo pipefail

cmd="${1:-list}"
case "$cmd" in
  add)
    name="${2:?Usage: $0 add <name> [branch]}"
    branch="${3:-$name}"
    git worktree add "../$(basename $(pwd))-$name" "$branch"
    echo "✓ Created worktree: ../$(basename $(pwd))-$name"
    ;;
  remove)
    name="${2:?Usage: $0 remove <name>}"
    git worktree remove "../$(basename $(pwd))-$name" --force
    echo "✓ Removed worktree"
    ;;
  list)
    git worktree list
    ;;
  *)
    echo "Usage: $0 {add|remove|list} [args]"
    ;;
esac
EOF
  chmod +x tools/worktree_helper.sh
  echo "✓ Created worktree_helper.sh"
else
  echo "• Kept existing worktree_helper.sh"
fi

# 5. Makefile structured output
echo "==> 5) Makefile Structured Output Targets"
if [ -f Makefile ]; then
  if ! grep -q "audit-json:" Makefile; then
    backup Makefile
    cat >> Makefile <<'EOF'

# --- Structured Output ---
audit-json:
	@echo '{"timestamp":"'$$(date -Iseconds)'",' > audit.json
	@echo '"shellcheck":' >> audit.json
	@find . -name "*.sh" -exec shellcheck -f json {} \; >> audit.json 2>/dev/null || echo '[]' >> audit.json
	@echo '}' >> audit.json
	@echo "✓ Written to audit.json"

stats-json:
	@echo '{"scripts":'$$(find . -name "*.sh" | wc -l)',' > stats.json
	@echo '"loc":'$$(find . -name "*.sh" -exec cat {} \; | wc -l)'}' >> stats.json
	@echo "✓ Written to stats.json"

.PHONY: audit-json stats-json
EOF
    echo "✓ Added structured output targets to Makefile"
  else
    echo "• Makefile already has audit-json target"
  fi
fi

# 6. Enhanced permissions (update settings.json)
echo "==> 6) Enhanced .claude/settings.json Permissions"
if [ -f .claude/settings.json ]; then
  backup .claude/settings.json
  # Add cleanup commands to allow list
  if ! grep -q "rm -f /tmp" .claude/settings.json; then
    echo "  Note: Manually add to allow list: \"Bash(rm -f /tmp/temp_*:*)\""
  fi
else
  echo "! No .claude/settings.json - run setup_agents_repo.sh first"
fi

# 7. Create sub-agents example
echo "==> 7) Sub-Agents Documentation"
mkdir -p docs
cat > docs/sub-agents.md <<'EOF'
# Sub-Agents Architecture

Use the Task tool to delegate specialized work:

## Available Agents
- `general-purpose`: Research, multi-step tasks
- `output-style-setup`: Configure output formatting
- `statusline-setup`: Configure status line

## Example Usage
```
Task(
  subagent_type="general-purpose",
  description="Find security issues",
  prompt="Search for exposed secrets and auth bypasses in src/"
)
```

## Best Practices
- Launch multiple agents in parallel for independent tasks
- Provide detailed prompts with expected output format
- Each agent is stateless - include all context needed
EOF
echo "✓ Created sub-agents documentation"

# 8. Personal commands template
echo "==> 8) Personal Commands Template"
if [ ! -f .claude/commands/my-workflow.md ]; then
  cat > .claude/commands/my-workflow.md <<'EOF'
# My Workflow

Personal productivity command for common tasks.

## Quick Start
1. Run tests: `pnpm test`
2. Check types: `pnpm typecheck`
3. Fix lints: `pnpm lint --fix`
4. Update deps: `pnpm update --interactive`

## Debug Process
1. Add console.logs at entry/exit points
2. Check network tab for API calls
3. Verify env vars are loaded
4. Test in isolation with minimal repro

## Deploy Checklist
- [ ] All tests passing
- [ ] No console.logs
- [ ] Env vars documented
- [ ] Migration scripts ready
- [ ] Rollback plan documented
EOF
  echo "✓ Created personal workflow template"
else
  echo "• Kept existing my-workflow.md"
fi

echo ""
echo "=== Summary ==="
echo "✓ Security review GitHub Action"
echo "✓ Claude commands (/security-review, /think-hard)"
echo "✓ Performance tips in CLAUDE.md"
echo "✓ Worktree helper for parallel sessions"
echo "✓ Structured output in Makefile"
echo "✓ Sub-agents documentation"
echo "✓ Personal command template"
echo ""
echo "Next steps:"
echo "1. Review and customize .claude/commands/my-workflow.md"
echo "2. Run: make audit-json  # Test structured output"
echo "3. Try: bash tools/worktree_helper.sh add feature-x"
echo "4. Use: /security-review  # In Claude chat"
