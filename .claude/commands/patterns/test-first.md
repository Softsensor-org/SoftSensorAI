# Pattern: Test-First for New Unit/API

**Use-when:** adding new behavior  
**Success:** new failing test → pass → green suite

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

Write tests for {UNIT/API}; they must fail on current code.

PLAN:
- Enumerate cases (happy, edge, error).
- Commands: pnpm test -i {scope}.

CODE:
- Implement minimal production code to pass.

VERIFY:
- All tests green; show coverage delta if available.
