# Start Seeing Value This Week

## Minimum Setup for Immediate Impact

### Day 1: Monday (30 minutes)

```bash
# 1. Install DevPilot
# Clone the repository first
git clone https://github.com/Softsensor-org/DevPilot.git ~/devpilot
cd ~/devpilot && ./setup_all.sh

# 2. Set up your main project
cd ~/your-main-project
~/devpilot/setup/existing_repo_setup.sh --skill l1 --phase mvp

# 3. Try your first power command
claude --system-prompt .claude/commands/tickets-from-code.md \
  "analyze src/ and identify quick wins"
```

**Immediate Win**: You now have a prioritized backlog in 10 minutes vs 3 hours

### Day 2: Tuesday (15 minutes)

```bash
# Enable AI PR reviewer
cd ~/your-main-project
cat >> .github/workflows/ci.yml <<'EOF'
  ai-review:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    continue-on-error: true  # Non-blocking
    steps:
      - uses: actions/checkout@v4
      - name: AI Review
        run: |
          for cli in claude gemini grok codex; do
            if command -v $cli &>/dev/null; then
              echo "Using $cli for review"
              git diff origin/main...HEAD | $cli \
                --system-prompt system/active.md \
                "review this diff for security, performance, and bugs"
              break
            fi
          done
          echo "No AI CLI available (this is fine)"
          exit 0
EOF
```

**Immediate Win**: Every PR now gets a first-pass review in 1-2 minutes

### Day 3: Wednesday (20 minutes)

```bash
# Create your first custom command
cat > .claude/commands/daily-standup.md <<'EOF'
You are a standup report generator. Analyze git history and working tree.

Output format:
## Yesterday
- [bullet points of completed work]

## Today
- [planned work based on working tree]

## Blockers
- [any issues found]
EOF

# Use it
claude --system-prompt .claude/commands/daily-standup.md \
  "generate my standup update"
```

**Immediate Win**: Standup prep in 30 seconds vs 5 minutes

### Day 4: Thursday (15 minutes)

```bash
# Add pre-push validation
cat > .git/hooks/pre-push <<'EOF'
#!/bin/bash
echo "Running pre-push validation..."

# Quick security scan
if command -v gitleaks &>/dev/null; then
  gitleaks detect --source . --verbose
fi

# AI review of staged changes
if command -v claude &>/dev/null; then
  git diff --staged | claude --system-prompt system/active.md \
    "quick review: any obvious issues? (be concise)"
fi

echo "Pre-push validation complete"
EOF
chmod +x .git/hooks/pre-push
```

**Immediate Win**: Catch issues before they hit CI

### Day 5: Friday (30 minutes)

```bash
# Generate week's accomplishments
claude --system-prompt .claude/commands/tickets-from-diff.md \
  "summarize this week's merged PRs for status report"

# Plan next week
claude --system-prompt .claude/commands/tickets-from-code.md \
  "identify top 5 priorities for next sprint"

# Document what you learned
echo "## Week 1 Wins" >> DEVPILOT_RESULTS.md
echo "- Setup time: 90min → 15min" >> DEVPILOT_RESULTS.md
echo "- PR reviews: 2 days → 2 hours" >> DEVPILOT_RESULTS.md
echo "- Backlog creation: 3 hours → 15 min" >> DEVPILOT_RESULTS.md
```

**Immediate Win**: Objective metrics to share with team/manager

## The Four Commands That Pay for Themselves

### 1. `/tickets-from-code` - Instant Backlog

```bash
# Instead of 3-hour planning meetings:
claude --system-prompt .claude/commands/tickets-from-code.md \
  "analyze entire codebase" > backlog.json

# Convert to CSV for Jira import
jq -r '.tickets[] | [.id, .title, .priority, .effort] | @csv' backlog.json > backlog.csv
```

**Time Saved**: 2.5 hours per planning session

### 2. `/secure-fix` - Proactive Security

```bash
# Instead of waiting for security team:
claude --system-prompt .claude/commands/secure-fix.md \
  "scan for OWASP Top 10 in src/"
```

**Risk Avoided**: Finding issues in dev vs production

### 3. `/long-context-map-reduce` - Digest Large Changes

```bash
# Instead of reading 1000-line PRs:
git diff main...feature-branch | \
  claude --system-prompt .claude/commands/long-context-map-reduce.md \
  "summarize changes and identify risks"
```

**Time Saved**: 45 min per large PR

### 4. `/architect-spike` - Design Decisions

```bash
# Instead of endless architecture meetings:
claude --system-prompt .claude/commands/architect-spike.md \
  "evaluate options for migrating to microservices"
```

**Time Saved**: 2 hours of debate → 15 min structured analysis

## Tracking Your Wins

Create this simple tracker:

```bash
# Create results tracker
cat > track_results.sh <<'EOF'
#!/bin/bash
echo "=== DevPilot Metrics Week of $(date +%Y-%m-%d) ==="
echo "PRs reviewed by AI: $(gh pr list --search "reviewed-by:app/github-actions" | wc -l)"
echo "Tickets generated: $(ls artifacts/tickets_*.json 2>/dev/null | wc -l)"
echo "Security issues caught: $(git log --grep="security" --since="1 week ago" | wc -l)"
echo "Setup time saved: ~2 hours per new repo"
echo "Review time saved: ~1.5 hours per PR"
EOF
chmod +x track_results.sh

# Run weekly
./track_results.sh >> DEVPILOT_METRICS.md
```

## Common Gotchas & Solutions

### "AI CLI not found"

```bash
# DevPilot is CLI-first - install any supported CLI:
# From the cloned repository
bash ~/devpilot/install/ai_clis.sh

# Or just one:
pip install --user anthropic-cli  # for Claude
npm install -g @google/generative-ai-cli  # for Gemini
```

### "Commands not working"

```bash
# Check system prompt exists:
ls system/active.md

# Regenerate if needed:
cat system/00-global.md system/10-repo.md system/20-task.md > system/active.md
```

### "CI failing after setup"

```bash
# Start with lightest phase:
~/devpilot/scripts/apply_profile.sh --phase poc

# CI won't block on anything - fix issues gradually
# Level up when ready:
~/devpilot/scripts/apply_profile.sh --phase mvp
```

## Share Your Success

After one week, you'll have concrete metrics. Share them:

```markdown
## DevPilot Week 1 Results

**Time Saved:**

- Repo setup: 90 min → 15 min (6x faster)
- PR reviews: 48 hrs → 2 hrs (24x faster)
- Backlog grooming: 3 hrs → 15 min (12x faster)

**Quality Improved:**

- Security issues caught pre-commit: 5
- PRs with AI review: 100%
- Onboarding time for new dev: 2 weeks → 3 days

**Next Steps:**

- Roll out to 2 more repos
- Create team-specific commands
- Track velocity improvement
```

## Get Help

- **Issues**: https://github.com/Softsensor-org/DevPilot/issues
- **Quick fixes**: `~/devpilot/scripts/doctor.sh`
- **Command help**: `ls .claude/commands/` to see all available commands
- **Profile check**: `~/devpilot/scripts/profile_show.sh`

Remember: Start small, measure everything, share wins early.
