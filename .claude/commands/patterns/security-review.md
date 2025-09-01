# Pattern: Security Review (Local, Tool-Assisted)

**Use-when:** pre-merge or audit  
**Success:** minimal fixes applied + residual risk noted

---

Context:
- OS: Linux (WSL/devcontainer). Node=LTS+pnpm. Python=.venv+pytest.
- Tools available: rg, jq, pnpm, pytest, docker, kubectl, helm, git, scripts/run_checks.sh.
- Repo rules: small atomic diffs, tests-first for new behavior, link Jira key in commits.

Operate with this loop:
1) PLAN → list acceptance checks + exact commands you'll run.
2) CODE → produce the smallest diff to satisfy PLAN; show unified diff.
3) VERIFY → run the commands; if anything fails, fix and re-run.
4) STOP with a brief next-steps list. Remove temp files you created.

---

Security pass for this diff.

PLAN:
- Run (if available): pnpm audit; semgrep --config auto; hadolint Dockerfile;
  trivy fs .; gitleaks detect.
- Pick highest-value fixes with low risk; list acceptance checks.

CODE: minimal diffs.

VERIFY: re-run tools; show summaries & remaining risk register.
