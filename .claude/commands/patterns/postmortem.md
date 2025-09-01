# Pattern: Postmortem Mini-Template (After Incidents)

**Use-when:** after fix lands  
**Success:** crisp learning + prevention

---

Context:
- OS: Linux (WSL/devcontainer). Node=LTS+pnpm. Python=.venv+pytest.
- Tools available: rg, jq, pnpm, pytest, docker, kubectl, helm, git, scripts/run_checks.sh.
- Repo rules: small atomic diffs, tests-first for new behavior, link Jira key in commits.

---

Write a 1-page postmortem:

- Summary (what broke, user impact, timeline)
- Root cause (5-why)
- Fix implemented (link commit)
- Prevent: tests/alerts/process change (1–3 items)
