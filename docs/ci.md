# CI Integrations

## Included Workflows

- `.github/workflows/ci.yml` — pre-commit checks, shell linting, audit script
- `.github/workflows/security-review.yml` — SAST, secrets, Dockerfile linting with tool-specific
  labels
- `.github/workflows/ai-review.yml` — CLI-first AI PR reviews (no API keys required)
- `.github/workflows/dprs-report.yml` — DevPilot Readiness Score tracking

## AI PR Review Setup

Enable AI-powered PR reviews without API keys:

### Method 1: Repository Variable (Recommended)

1. Go to **Settings** → **Secrets and variables** → **Actions** → **Variables**
2. Click **New repository variable**
3. Name: `AI_REVIEW_ENABLED`
4. Value: `true`
5. All PRs will now receive AI reviews automatically

### Method 2: PR Label

Add the `ai-review` label to any PR to trigger a review for that specific PR:

```bash
gh pr edit 123 --add-label ai-review
```

### CLI Requirements

The workflow tries AI CLIs in this order:

1. Claude CLI
2. Codex CLI
3. Gemini CLI
4. Grok CLI

If no CLI is found, the workflow exits neutrally (won't fail your PR).

**Note:** Install at least one AI CLI on your runner or use GitHub-hosted runners with setup steps.

Phase-Specific CI

- `scripts/apply_profile.sh --phase <poc|mvp|beta|scale>` installs a phase CI under
  `.github/workflows/ci.yml`
- MVP: lints, typecheck, unit tests required
- Beta: coverage ≥ 60%; security gates block on high severity
  - gitleaks fail on any secret
  - semgrep fail on HIGH (`--severity=ERROR`) and upload SARIF
  - trivy fs fail on CRITICAL,HIGH with `--ignore-unfixed`
  - hadolint warns only
- Scale: coverage ≥ 80%; security gates stricter
  - gitleaks fail on any secret
  - semgrep fail on MEDIUM+ (`--severity=WARNING,ERROR`) and upload SARIF
  - trivy fs/image fail on CRITICAL,HIGH with `--ignore-unfixed`
  - hadolint fail on errors
  - IaC (tfsec) and supply chain checks recommended as blocking

Baselines and ignores (Scale)

- Semgrep baseline: set a repo variable `SEMGREP_BASELINE_REF` to a branch/commit (e.g., `main`). CI
  will pass `--baseline-ref` so only new findings fail.
- Trivy ignore file: add `.trivyignore` at repo root with CVE IDs or patterns to suppress known,
  accepted issues.
- Semgrep ignore file: add `.semgrepignore` paths to exclude (node_modules, build output, fixtures,
  etc.). The seeder drops a sensible default.

Example `.trivyignore`

```text
# CVE IDs allowed temporarily (reference a ticket per line)
CVE-2023-12345  # Accepted in dev-only toolchain until library X updates
CVE-2024-00001  # False positive on package Y

# Ignore paths (for config scanning)
cmd/**/testdata/**
```

Secrets & Security

- Do not commit secrets; use repo/org secrets for CI
- Security review workflow is advisory by default; tighten as you graduate phases
