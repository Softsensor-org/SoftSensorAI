# Pattern: SQL & Migrations

**Use-when:** schema change or query work
**Success:** safe migration, audited SQL

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

Change: {MIGRATION}. DB: {ENGINE}.

PLAN:
- Write forward migration (idempotent) + rollback notes.
- Validate queries with sqlfluff; add index/EXPLAIN check.

COMMANDS:
- sqlfluff lint .; EXPLAIN {QUERY}; run migration on test db.

OUTPUT:
- migration.sql; checklist of risks and mitigations.
