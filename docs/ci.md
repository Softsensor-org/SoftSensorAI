# CI Integrations

Included Workflows
- `.github/workflows/ci.yml` — pre-commit checks, shell linting, audit script
- `.github/workflows/security-review.yml` — SAST, secrets, Dockerfile linting
- `.github/workflows/codex-ci.yml` — Optional: Codex applies minimal fixes on PRs

Phase-Specific CI
- `scripts/apply_profile.sh --phase <poc|mvp|beta|scale>` installs a phase CI under `.github/workflows/ci.yml`
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
- Semgrep baseline: set a repo variable `SEMGREP_BASELINE_REF` to a branch/commit (e.g., `main`). CI will pass `--baseline-ref` so only new findings fail.
- Trivy ignore file: add `.trivyignore` at repo root with CVE IDs or patterns to suppress known, accepted issues.
- Semgrep ignore file: add `.semgrepignore` paths to exclude (node_modules, build output, fixtures, etc.). The seeder drops a sensible default.

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
