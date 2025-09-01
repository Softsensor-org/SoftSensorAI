# Pattern: Release / Changelog (Automated Summary)

**Use-when:** prepping a release  
**Success:** concise notes + version bump plan

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

Goal: Draft release notes from commits since {TAG}.

PLAN:
- Summarize features/fixes/breaking changes; link PRs, JIRA keys.
- Commands: git log {TAG}..HEAD --oneline

OUTPUT:
- CHANGELOG snippet; version bump suggestion (semver); risks.
