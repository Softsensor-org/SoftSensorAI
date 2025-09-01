# Pattern: API Contract Update (OpenAPI or Typed Schema)

**Use-when:** endpoint change
**Success:** spec + types + server/client updates aligned

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

Endpoint: {METHOD PATH}. Change: {ADD/REMOVE/FIELD/STATUS}.

PLAN:
- Update spec/schema; regenerate types; touch server and client.
- Commands: redocly lint openapi.yaml; openapi-typescript; pnpm typecheck & test.

CODE: keep backward-compatibility where feasible (feature flag).

VERIFY: run commands; include example request/response.
