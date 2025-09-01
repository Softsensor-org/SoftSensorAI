# Pattern: Problem Discovery / Scoping

**Use-when:** ticket vague; clarify before touching code  
**Inputs:** `<JIRA_TITLE>`, optional paths  
**Success:** unambiguous spec + acceptance checks

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

Goal: turn this into a crisp spec and ready-to-execute checks.

Input: {PASTE_JIRA_TITLE_AND_NOTES}. Likely files: {PATH_HINTS_IF_ANY}.

PLAN:
- Summarize the problem in ≤5 bullets.
- Propose ≤6 acceptance checks (objective, testable).
- List exact commands to validate (lint/type/tests/benchmarks).

OUTPUT:
- "Spec" (1 paragraph)
- "Acceptance Checks" (bulleted)
- "Command Plan"
