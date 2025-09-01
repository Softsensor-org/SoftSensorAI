# Pattern: Data Pipeline / EDA

**Use-when:** explore dataset or build ETL  
**Success:** clear data contract + reproducible steps

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

Dataset: {LOCATION}. Question: {QUESTION}.

PLAN:
- Profile schema, missingness, distributions, join keys.
- Commands (if available): duckdb/sqlfluff; python .venv/…; nbstripout

CODE:
- Produce: data dictionary (markdown), profiling summary (table),
  notebook/py script for EDA with saved plots under docs/eda/.

VERIFY:
- Re-run notebook/script headless; artifact paths listed.
