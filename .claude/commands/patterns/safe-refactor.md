# Pattern: Safe Refactor

**Use-when:** restructure without behavior change  
**Success:** no test deltas; code quality up

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

Refactor target: {PATHS}. No behavior change allowed.

PLAN:
- Invariants (unchanged IO/side-effects).
- Metrics to monitor (grep TODO/FIXME/dup, cyclomatic if available).
- Commands: pnpm lint; pnpm typecheck; pnpm test -i.

CODE:
- Small steps; keep public interfaces stable; add adapter if needed.

VERIFY:
- Zero test changes except snapshots justified; summarize risk.

COMMIT:
- "refactor({scope}): {what/why}"