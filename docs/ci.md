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

Secrets & Security
- Do not commit secrets; use repo/org secrets for CI
- Security review workflow is advisory by default; tighten as you graduate phases
