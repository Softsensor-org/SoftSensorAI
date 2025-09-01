# Pattern: Architecture Spike

**Use-when:** new feature/system boundary  
**Inputs:** constraints (perf, latency, data)  
**Success:** 2–3 options with trade-offs + chosen plan

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

Goal: propose 2–3 viable designs and pick one.

PLAN:
- State constraints (throughput, latency, SLAs, data shape).
- Propose Designs A/B(/C) with sequence diagrams / data flow (text ok).
- Compare by complexity, risk, testability, rollout plan.
- Choose one; list MVP surfaces, stubs, and a kill-switch.

OUTPUT:
- "Decision" (why)
- "Interfaces" (function signatures, DTOs)
- "MVP Steps" (≤6, in order)
