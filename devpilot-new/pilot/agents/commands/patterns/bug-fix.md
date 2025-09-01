# Pattern: Bug Fix (Repro → Test → Fix)

**Use-when:** defect; ensure non-regression  
**Inputs:** repro steps/logs  
**Success:** failing test first, then fixed

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

Bug: {SYMPTOM}. Likely files: {PATHS}.

PLAN:
- Write a failing test demonstrating the bug.
- Commands: pnpm test -i {SCOPE}; scripts/run_checks.sh

CODE:
- Fix with smallest diff; note root cause in the test name.

VERIFY:
- Re-run tests; show before/after failure.

COMMIT:
- "{JIRA_KEY}: fix {component}: {root cause}"