# Pattern: Performance Pass

**Use-when:** slowness suspected  
**Success:** proof with numbers + micro-optimizations

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

PATHS: {HOT CODE}. Target: reduce p95 latency / CPU / memory.

PLAN:
- Add microbench or capture timings; hypothesis for hot path.
- Commands: hyperfine "{cmd}" --warmup 3; add timing logs guarded by flag.

CODE: optimize with smallest change; note trade-offs.

VERIFY: show before/after numbers (table). Rollback plan if regression found.