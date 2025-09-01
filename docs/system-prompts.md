# System Prompt Layering

Compose consistent guidance across three layers:

Layers
- Global: `templates/system/00-global.md` (security, formatting, tool ordering)
- Repo: `templates/system/10-repo.md` (stack, scripts, conventions)
- Task: `templates/system/20-task.md` (ticket/audit/spec context)

Apply Profile generates
- `system/active.md` by concatenating `00-global + 10-repo + 20-task (if present)`

How to Use
- Use `system/active.md` as your system prompt in CLIs that support it
- Keep `10-repo.md` small and repo-specific; avoid account/secrets
- Update `20-task.md` per ticket/run as needed

Long-Context Hygiene (also in CLAUDE.md)
- Summarize before quoting; cite `file:line`
- Cap quotes to what’s necessary
- Refer to chunk IDs (like [A], [B]) and cite them in summaries
