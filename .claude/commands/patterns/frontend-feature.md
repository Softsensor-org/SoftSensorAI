# Pattern: Frontend Feature (Component-First)

**Use-when:** UI addition  
**Success:** component story + tests + snapshot approved

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

Feature: {UI}. Stack: React + {lib}.

PLAN:
- Build isolated component with story; add unit & a11y tests.
- Commands: pnpm test -i; (optional) playwright smoke

CODE: minimal state & props; no hidden coupling.

VERIFY: tests green; paste Storybook args or screenshots path.
