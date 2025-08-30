# Codex / CLI Agent Directives
- Start read-only (plan & inspect); switch to workspace-write once tests pass.
- Prefer: `codex exec "lint, typecheck, unit tests; fix failures"`.
- Conventional commits; PR checklist; link the ticket.
- Add/adjust tests when behavior changes; keep coverage steady.
- Respect `.envrc` (direnv) and **never** commit secrets.
