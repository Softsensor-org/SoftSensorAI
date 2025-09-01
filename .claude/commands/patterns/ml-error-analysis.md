# Pattern: Error Analysis (ML)

**Use-when:** metric stalls; inspect failures  
**Success:** actionable error buckets + next actions

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

Model: {NAME}. Failures: path/to/preds_vs_labels.csv

PLAN:
- Slice by top-n features; confusion buckets; top-5 errors with examples.
- Commands: python analysis/error_buckets.py …

OUTPUT:
- Table of slices with metric deltas; 3 concrete fixes to try next.
