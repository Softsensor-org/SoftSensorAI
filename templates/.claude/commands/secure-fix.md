# Goal
Identify and fix the most impactful security issue(s) with minimal diffs.

# Plan
1) Enumerate candidate issues; if tools exist, run:
   - JS/TS: `pnpm audit` (or `npm audit`), `semgrep --config auto` if available
   - Docker/IaC: `hadolint Dockerfile`, `trivy fs .` if available
   - Secrets: `gitleaks detect --no-banner -v` if available
2) Choose the highest-value fix (low risk, high impact).
3) List acceptance checks + exact commands you will run.

# Code
Make the smallest necessary change. Show a unified diff.

# Test
Run: lints/tests and re-run the relevant security tool. If anything fails, fix and re-run.

# Output
- Findings summary (1–3 bullets)
- Diff
- Command outputs (trimmed)
- Next steps (follow-ups / tickets)
