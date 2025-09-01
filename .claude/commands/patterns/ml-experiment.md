# Pattern: ML Experiment Loop (Reproducible)

**Use-when:** try a model/feature  
**Success:** a results table + artifacts referenced

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

Experiment: {NAME}. Target metric: {METRIC} on {DATA_SPLIT}.

PLAN:
- Baseline; 2–3 variants; fixed seeds; log all configs.
- Commands: python -m train --config <…>; save runs to runs/{exp}.

CODE:
- Implement config-driven training; log metrics to CSV/JSON.

VERIFY:
- Present table: variant, params, metric, Δ vs baseline, time.
- Save best checkpoint path and exact repro command.
