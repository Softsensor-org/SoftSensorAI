# Pattern: Implement Backend Feature

**Use-when:** ticket ready; code the minimal diff  
**Inputs:** `<JIRA_KEY>`, API/DB impacts  
**Success:** green tests, migration safety if any

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

Task: Implement {FEATURE} for {JIRA_KEY}.

PLAN:
- Acceptance checks.
- Commands: pnpm typecheck; pnpm test -i; scripts/run_checks.sh
- If DB: add migration plan (idempotent, rollback notes).

CODE: minimal changes only. Show unified diff.

VERIFY: run the commands. If a test fails, fix and re-run.

COMMIT: "{JIRA_KEY}: {concise summary}"