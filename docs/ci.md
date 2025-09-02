# CI Integrations

## Included Workflows

- `.github/workflows/ci.yml` — pre-commit checks, shell linting, audit script
- `.github/workflows/os-compatibility.yml` — Cross-platform testing matrix (Ubuntu, macOS, Windows,
  containers)
- `.github/workflows/security-review.yml` — SAST, secrets, Dockerfile linting with tool-specific
  labels
- `.github/workflows/ai-review.yml` — CLI-first AI PR reviews (no API keys required)
- `.github/workflows/dprs-report.yml` — DevPilot Readiness Score tracking

## OS Compatibility Testing

The `os-compatibility.yml` workflow ensures DevPilot works across all supported platforms:

### Test Matrix

- **Native OS**: Ubuntu (20.04, 22.04, latest), macOS (Intel & ARM), Windows (WSL)
- **Containers**: Debian, Ubuntu, Fedora, Alpine, Arch Linux, Rocky Linux
- **Simulated**: FreeBSD, OpenBSD, NetBSD

### Local Testing

Run compatibility tests locally:

```bash
./tests/test_os_compatibility.sh
```

For detailed platform support, see the [OS Compatibility Guide](OS_COMPATIBILITY.md).

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

## Security Issue Tracking

When security tools find vulnerabilities, the security-review workflow automatically creates GitHub
issues with appropriate labels:

### Tool-Specific Labels

Issues created by the security workflow include:

- **Primary labels:**

  - `security` - All security-related issues
  - `automated` - Created by CI/CD pipeline

- **Tool-specific labels:**

  - `semgrep` - Static analysis findings
  - `trivy` - Dependency and container vulnerabilities
  - `gitleaks` - Exposed secrets or credentials
  - `hadolint` - Dockerfile security issues

- **Severity labels:**
  - `severity:critical` - Immediate action required
  - `severity:high` - Address in current sprint
  - `severity:medium` - Schedule for next release
  - `severity:low` - Track for future improvement

### Example Issue Creation

```yaml
# In .github/workflows/security-review.yml
- name: Create Issue for Critical Findings
  if: steps.semgrep.outcome == 'failure'
  uses: actions/github-script@v7
  with:
    script: |
      const issue = await github.rest.issues.create({
        owner: context.repo.owner,
        repo: context.repo.repo,
        title: '🔒 Security: Semgrep found critical vulnerabilities',
        body: `## Security Scan Results\n\n${semgrepOutput}`,
        labels: ['security', 'automated', 'semgrep', 'severity:critical']
      });
```

### Tracking and Remediation

1. **Dashboard view:** Filter issues by labels

   ```
   is:issue is:open label:security label:automated
   ```

2. **By tool:** Track specific scanner findings

   ```
   is:issue is:open label:semgrep
   is:issue is:open label:trivy
   ```

3. **By severity:** Prioritize critical issues
   ```
   is:issue is:open label:security label:severity:critical
   ```

## Phase-Specific CI

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
