# CI Integrations

Included Workflows
- `.github/workflows/ci.yml` — pre-commit checks, shell linting, audit script
- `.github/workflows/security-review.yml` — SAST, secrets, Dockerfile linting
- `.github/workflows/codex-ci.yml` — Optional: Codex applies minimal fixes on PRs

Phase-Specific CI
- `scripts/apply_profile.sh --phase <poc|mvp|beta|scale>` installs a phase CI under `.github/workflows/ci.yml`
- MVP: lints, typecheck, unit tests required
- Beta/Scale: encourage higher coverage and additional gates

Secrets & Security
- Do not commit secrets; use repo/org secrets for CI
- Security review workflow is advisory by default; tighten as you graduate phases

