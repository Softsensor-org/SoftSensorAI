# After Clone Playbook

A practical, CLI-first workflow for immediate productivity after cloning any repository. This
playbook fits SoftSensorAI's architecture (system/active.md, profiles/phases, personas, zero-secrets
CI) and gives you an immediate repo review plus the best commands to keep shipping fast.

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
git diff HEAD~3 | softsensorai review --diff -             # Interactive review
```

## 3) Pre-PR Sanity (Local AI Review of Your Diff)

```bash
# Compare to base, get concise review bullets
BASE=${BASE_BRANCH:-main}
git fetch --no-tags origin "$BASE" --depth=1
git diff --unified=1 --minimal --no-color origin/$BASE...HEAD > artifacts/review_diff.patch
{ echo "ROLE: Senior reviewer. File-scoped bullets with fixes."; echo "DIFF:"; cat artifacts/review_diff.patch; } \
  > artifacts/review_prompt.txt

# Any supported CLI works; output goes to artifacts/review_local.txt
# Claude CLI
claude --system-prompt system/active.md \
  --input-file artifacts/review_prompt.txt \
  > artifacts/review_local.txt

# OR Codex CLI
codex exec --system-file system/active.md \
  --input-file artifacts/review_prompt.txt \
  > artifacts/review_local.txt

# OR Gemini CLI
gemini generate --model gemini-1.5-pro-latest \
  --system-file system/active.md \
  --prompt-file artifacts/review_prompt.txt \
  > artifacts/review_local.txt

# OR Grok CLI
grok chat --system "$(cat system/active.md)" \
  --input-file artifacts/review_prompt.txt \
  > artifacts/review_local.txt

# Quick one-liner using softsensorai CLI
softsensorai review --diff origin/main
```

## 4) Quick Wins (15 Minutes)

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

## Justfile Shortcuts (Production-Ready One-Liners)

Add these to your `Justfile` for clean, one-line execution:

```make
# Core workflows - clean one-liners
# ============================================================================

# Generate tickets from codebase
tickets:
    @mkdir -p artifacts
    @cat .claude/commands/tickets-from-code.md > artifacts/tickets_prompt.txt 2>/dev/null || echo "Analyze codebase and generate tickets" > artifacts/tickets_prompt.txt
    @if command -v claude >/dev/null; then \
        claude --system-prompt system/active.md --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json; \
    elif command -v codex >/dev/null; then \
        codex exec --system-file system/active.md --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json; \
    elif command -v gemini >/dev/null; then \
        gemini generate --system-file system/active.md --prompt-file artifacts/tickets_prompt.txt > artifacts/tickets.json; \
    elif command -v grok >/dev/null; then \
        grok chat --system "$$(cat system/active.md)" --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json; \
    fi
    @jq -r '.tickets[] | [ .id,.title,.type,.priority,.effort, (.labels//[]|join("|")), (.assignee//""), (.dependencies//[]|join("|")), (.notes//""|gsub("[\r\n]+";" ")), (.acceptance_criteria//[]|join("; ")) ] | @csv' artifacts/tickets.json > artifacts/tickets.csv
    @echo "✓ Wrote artifacts/tickets.{json,csv}"

# Review changes against base branch
review-local BASE="main":
    @mkdir -p artifacts
    @git fetch --no-tags origin {{BASE}} --depth=1
    @git diff --unified=1 --minimal --no-color origin/{{BASE}}...HEAD > artifacts/review_diff.patch
    @echo "ROLE: Senior reviewer. Bulleted, file-scoped suggestions." > artifacts/review_prompt.txt
    @echo "DIFF:" >> artifacts/review_prompt.txt
    @cat artifacts/review_diff.patch >> artifacts/review_prompt.txt
    @if command -v claude >/dev/null; then \
        claude --system-prompt system/active.md --input-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
    elif command -v codex >/dev/null; then \
        codex exec --system-file system/active.md --input-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
    elif command -v gemini >/dev/null; then \
        gemini generate --system-file system/active.md --prompt-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
    elif command -v grok >/dev/null; then \
        grok chat --system "$$(cat system/active.md)" --input-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
    fi
    @echo "✓ Wrote artifacts/review_local.txt"

# Repository review: hygiene + security
repo-review:
    @./scripts/pack_context.sh || true
    @just fmt || true; just lint || true; just test-unit -k smoke || true
    @gitleaks detect -r artifacts/gitleaks.json || true
    @semgrep ci --json --output artifacts/semgrep.json || true
    @trivy fs --scanners vuln,secret,config -f json -o artifacts/trivy.json . || true
    @echo "✓ Complete. Check artifacts/"

# Extended playbook commands
# ============================================================================

# Run complete after-clone playbook
after-clone:
  @echo "🚀 Running after-clone playbook..."
  @./scripts/doctor.sh || true
  @./scripts/apply_profile.sh --skill l1 --phase mvp || true
  @./scripts/system_build.sh || true
  @just repo-review
  @echo "✅ Playbook complete! Check artifacts/ for reports"

# Quick security scan
security-quick:
  @echo "🔒 Quick security scan..."
  @gitleaks detect --no-git || echo "No secrets found"
  @semgrep --config=auto --severity=ERROR || echo "No critical issues"
  @trivy fs . --severity=HIGH,CRITICAL --exit-code=0

# Pre-PR review: AI review of your changes
review-pre-pr BASE="main":
  @echo "🔍 Running pre-PR review against {{BASE}}..."
  @mkdir -p artifacts
  @git fetch --no-tags origin {{BASE}} --depth=1
  @git diff --unified=1 --minimal --no-color origin/{{BASE}}...HEAD > artifacts/review_diff.patch
  @echo "ROLE: Senior reviewer. File-scoped bullets with fixes." > artifacts/review_prompt.txt
  @echo "DIFF:" >> artifacts/review_prompt.txt
  @cat artifacts/review_diff.patch >> artifacts/review_prompt.txt
  @if command -v claude >/dev/null; then \
    claude --system-prompt system/active.md --input-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
  elif command -v codex >/dev/null; then \
    codex exec --system-file system/active.md --input-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
  elif command -v gemini >/dev/null; then \
    gemini generate --system-file system/active.md --prompt-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
  elif command -v grok >/dev/null; then \
    grok chat --system "$$(cat system/active.md)" --input-file artifacts/review_prompt.txt > artifacts/review_local.txt; \
  else \
    echo "No AI CLI found. Install claude, codex, gemini, or grok"; \
  fi
  @echo "📝 Review saved to artifacts/review_local.txt"
  @cat artifacts/review_local.txt

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
  @echo "Current SoftSensorAI Configuration:"
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

      - name: Setup SoftSensorAI
        run: |
          # Note: For private repo, clone first:
          # git clone git@github.com:Softsensor-org/SoftSensorAI.git ~/softsensorai
          ~/softsensorai/scripts/doctor.sh
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

Create `.softsensorai/playbook.yml`:

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

## 6) Quick Alignment Questions (Optional)

Answer these 6 questions to instantly tailor all commands to your specific repo:

### Quick Setup Interview

```bash
# Run this to generate a custom configuration
cat > .softsensorai/alignment.yml << 'EOF'
# Answer these 6 questions for instant customization:

1. Primary goal (next 2-4 weeks)?
   goal: feature        # Options: feature|hardening|research

2. Stack & runtime(s)?
   stack: "Node/TypeScript"
   runtime: "containerized"  # Options: local|containerized|serverless

3. Current phase & gates?
   phase: mvp           # Options: poc|mvp|beta|scale
   gates:
     - "coverage >= 60%"
     - "no HIGH vulns"

4. Security posture?
   security:
     secrets_blocking: true
     sast_threshold: HIGH     # Options: LOW|MEDIUM|HIGH|CRITICAL
     vuln_threshold: HIGH

5. Domain modules?
   modules: []          # Options: [ocr_cv, robotics, notebooks, ml_ops, data_eng]

6. CI has AI CLIs?
   ci_ai_cli: false     # Set true if runner has claude/codex/gemini/grok
EOF

# Generate custom Justfile based on answers
./scripts/generate_custom_justfile.sh .softsensorai/alignment.yml > Justfile.custom
```

### Example Configurations

**Feature Development (Startup)**

```yaml
goal: feature
stack: "Node/React"
runtime: "containerized"
phase: mvp
gates: ["tests pass", "no secrets"]
security:
  secrets_blocking: true
  sast_threshold: HIGH
modules: []
ci_ai_cli: false
```

**ML/Data Project**

```yaml
goal: research
stack: "Python/PyTorch"
runtime: "local+gpu"
phase: poc
gates: ["notebooks run", "data validated"]
security:
  secrets_blocking: true
  sast_threshold: MEDIUM
modules: [notebooks, ml_ops, data_eng]
ci_ai_cli: true
```

**Production Hardening**

```yaml
goal: hardening
stack: "Go/K8s"
runtime: "containerized"
phase: scale
gates: ["coverage >= 80%", "no MEDIUM+ vulns", "load tests pass"]
security:
  secrets_blocking: true
  sast_threshold: MEDIUM
  vuln_threshold: MEDIUM
modules: []
ci_ai_cli: true
```

### Auto-Generated Commands

Based on your answers, we'll customize:

- **Ticket generation** - Focus areas (features vs tech debt vs security)
- **Review prompts** - Emphasis (correctness vs performance vs security)
- **Test requirements** - Coverage thresholds and test types
- **Security gates** - What blocks vs warns
- **CI/CD config** - What runs automatically

### Use the built-in `ssai`

SoftSensorAI ships a unified `ssai` already. Don't create/overwrite `bin/ssai`. Run `ssai palette` to
browse commands, or `just palette` if you prefer Just.

```bash
# SoftSensorAI's unified interface is already available:
ssai setup        # Smart project setup
ssai init         # Initialize with health check + profile + build
ssai doctor       # System health check
ssai palette      # Browse all commands interactively
ssai review       # AI code review
ssai tickets      # Generate backlog from codebase

# For teams preferring Just:
just tickets    # Same as ssai tickets
just review     # Same as ssai review
```

The built-in `ssai` command handles smart detection and routing to the appropriate scripts internally.
No need to create your own wrapper - just use the provided CLI.

## See Also

- [Quick Start Guide](quickstart.md) - Initial setup
- [Profiles & Phases](profiles.md) - Customizing skill/phase
- [DPRS](dprs.md) - Understanding readiness scores
- [CI Integration](ci.md) - Automating reviews
- [Project Profiles](../README.md#project-profiles) - YAML-based customization
