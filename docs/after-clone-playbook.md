# After Clone Playbook

A practical, CLI-first workflow for immediate productivity after cloning any repository. This
playbook fits DevPilot's architecture (system/active.md, profiles/phases, personas, zero-secrets CI)
and gives you an immediate repo review plus the best commands to keep shipping fast.

## 0) Bootstrap (Once Per Repo)

```bash
# Sanity + environment check
./scripts/doctor.sh

# Pick sensible defaults (tune later)
./scripts/apply_profile.sh --skill l1 --phase mvp

# Build the layered system prompt
./scripts/system_build.sh   # writes system/active.md
```

## 1) 10-Minute Repository Review (Run All)

```bash
# Inventory & context (tree, cloc, top JSON/YAML, recent failing tests)
./scripts/pack_context.sh                               # → artifacts/context_pack.txt

# Hygiene: format/lint/test smoke
just fmt || true; just lint || true; just test-unit -k smoke || true

# Security (advisory at MVP): secrets/SAST/vulns
gitleaks detect -r artifacts/gitleaks.json || true
semgrep ci --json --output artifacts/semgrep.json || true
trivy fs --scanners vuln,secret,config -f json -o artifacts/trivy.json . || true

# Dependency & license snapshot (optional)
./scripts/deps_snapshot.sh > artifacts/deps_snapshot.txt || true
```

## 2) AI-Powered Analysis

### Generate Tickets (Turn Code into Plan)

```bash
# Method 1: Using generate_tickets.sh (recommended)
./scripts/generate_tickets.sh --quick --output artifacts  # → artifacts/tickets.json

# Method 2: Manual CLI approach
# Use the seeded command as INPUT; point system to system/active.md
cat .claude/commands/tickets-from-code.md > artifacts/tickets_prompt.txt

# Pick your installed CLI (fallback chain: claude → codex → gemini → grok)
# Claude CLI
claude --system-prompt system/active.md \
  --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json

# OR Codex CLI
codex exec --system-file system/active.md \
  --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json

# OR Gemini CLI
gemini generate --model gemini-1.5-pro-latest \
  --system-file system/active.md \
  --prompt-file artifacts/tickets_prompt.txt > artifacts/tickets.json

# OR Grok CLI
grok chat --system "$(cat system/active.md)" \
  --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json

# Convert JSON to CSV for import/triage
jq -r '.tickets[] | [
  .id,.title,.type,.priority,.effort,
  (.labels//[]|join("|")), (.assignee//""), (.dependencies//[]|join("|")),
  (.notes//""|gsub("[\r\n]+";" ")), (.acceptance_criteria//[]|join("; "))
] | @csv' artifacts/tickets.json > artifacts/tickets.csv
```

### Other Analysis Tools

```bash
# Get DPRS score for maturity assessment
./scripts/dprs.sh                                       # → artifacts/dprs.md

# Run AI review on recent changes
git diff HEAD~3 | devpilot review --diff -             # Interactive review
```

## 3) Quick Wins (15 Minutes)

```bash
# Auto-fix formatting issues
just fmt-fix

# Update dependencies (if safe)
just deps-update

# Generate/update documentation
just docs-gen

# Set up pre-commit hooks
pre-commit install
pre-commit run --all-files || true
```

## Justfile Shortcuts

Add these to your `Justfile` for one-line execution:

```make
# After-clone playbook commands
# ============================================================================

# Run complete after-clone playbook
after-clone:
  @echo "🚀 Running after-clone playbook..."
  @./scripts/doctor.sh
  @./scripts/apply_profile.sh --skill l1 --phase mvp
  @./scripts/system_build.sh
  @just review-repo
  @echo "✅ Playbook complete! Check artifacts/ for reports"

# 10-minute repository review
review-repo:
  @echo "📊 Running repository review..."
  @mkdir -p artifacts
  @./scripts/pack_context.sh || true
  @just fmt || true
  @just lint || true
  @just test-unit -k smoke || true
  @gitleaks detect -r artifacts/gitleaks.json || true
  @semgrep ci --json --output artifacts/semgrep.json || true
  @trivy fs --scanners vuln,secret,config -f json -o artifacts/trivy.json . || true
  @./scripts/deps_snapshot.sh > artifacts/deps_snapshot.txt || true
  @echo "📁 Review complete. Reports in artifacts/"

# Quick security scan
security-quick:
  @echo "🔒 Quick security scan..."
  @gitleaks detect --no-git || echo "No secrets found"
  @semgrep --config=auto --severity=ERROR || echo "No critical issues"
  @trivy fs . --severity=HIGH,CRITICAL --exit-code=0

# Generate all artifacts
artifacts-all:
  @mkdir -p artifacts
  @./scripts/pack_context.sh
  @./scripts/generate_tickets.sh --quick
  @./scripts/dprs.sh
  @./scripts/deps_snapshot.sh > artifacts/deps_snapshot.txt
  @echo "📦 All artifacts generated in artifacts/"

# Show current configuration
config-show:
  @echo "Current DevPilot Configuration:"
  @./scripts/profile_show.sh
  @echo ""
  @echo "Active Personas:"
  @./scripts/persona_manager.sh list
  @echo ""
  @echo "System Prompt:"
  @head -n 20 system/active.md

# Bootstrap new contributor
bootstrap-contributor:
  @echo "👋 Setting up new contributor..."
  @./scripts/doctor.sh
  @./scripts/apply_profile.sh --skill beginner --phase mvp
  @./scripts/apply_persona.sh developer
  @./scripts/system_build.sh
  @echo "✅ Ready to contribute! Run 'just after-clone' for repo review"
```

## Workflow Integration

### For New Team Members

```bash
# One command to rule them all
just bootstrap-contributor
just after-clone
```

### For Existing Projects

```bash
# Quick review before starting work
just review-repo

# Check security before PR
just security-quick

# Generate artifacts for planning
just artifacts-all
```

### CI/CD Integration

```yaml
# .github/workflows/after-clone.yml
name: After Clone Analysis

on:
  workflow_dispatch:
  schedule:
    - cron: "0 9 * * 1" # Weekly on Monday

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup DevPilot
        run: |
          curl -sL https://raw.githubusercontent.com/Softsensor-org/DevPilot/main/scripts/doctor.sh | bash
          ./scripts/apply_profile.sh --skill l2 --phase beta

      - name: Run Repository Review
        run: just review-repo

      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: repo-analysis
          path: artifacts/
```

## Key Benefits

1. **Immediate Context** - Understand any codebase in 10 minutes
2. **Security First** - Catch issues before they reach production
3. **Zero Configuration** - Works with sensible defaults
4. **Progressive Enhancement** - Start simple, add complexity as needed
5. **CLI-First** - No API keys, no external dependencies
6. **Artifact Trail** - All analysis saved for review/audit

## Customization

### Per-Project Overrides

Create `.devpilot/playbook.yml`:

```yaml
playbook:
  default_skill: l2
  default_phase: beta

  review:
    skip_security: false
    skip_tests: false
    additional_checks:
      - npm audit
      - pip-audit

  artifacts:
    output_dir: reports/
    formats:
      - json
      - markdown
      - csv
```

### Team-Specific Workflows

Extend the playbook for your team:

```bash
# Data team additions
just review-repo
python scripts/data_quality_check.py
dbt test

# Frontend team additions
just review-repo
npm run lighthouse
npm run bundle-analyze

# Backend team additions
just review-repo
go test -bench=.
go mod tidy
```

## Troubleshooting

**Missing commands?**

```bash
./scripts/doctor.sh  # Check what's missing
```

**Permissions issues?**

```bash
chmod +x scripts/*.sh
```

**Slow performance?**

```bash
# Run checks in parallel
just review-repo &
just artifacts-all &
wait
```

## See Also

- [Quick Start Guide](QUICK_START.md) - Initial setup
- [Profiles & Phases](profiles.md) - Customizing skill/phase
- [DPRS](dprs.md) - Understanding readiness scores
- [CI Integration](ci.md) - Automating reviews
