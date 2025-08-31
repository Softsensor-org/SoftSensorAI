# DevPilot AI Agent Directives
- **Learning-Aware**: Adapt guidance based on detected skill level and project phase
- **Start Read-Only**: Plan & inspect first; switch to workspace-write once tests pass
- **Quality First**: `codex exec "lint, typecheck, unit tests; fix failures"`
- **Conventional Commits**: PR checklist; link tickets; respect graduation criteria
- **Test Coverage**: Add/adjust tests when behavior changes; maintain coverage
- **Security**: Respect `.envrc` (direnv) and **never** commit secrets

## Docs Index
- docs/quickstart.md — one-command setup and first project
- docs/repo-wizard.md — cloning and bootstrapping
- docs/agent-commands.md — commands catalog (think-deep, map→reduce, prefill, improver)
- docs/profiles.md — skill/phase profiles and env toggles
- docs/system-prompts.md — layered system prompts and `system/active.md`
- docs/ci.md — CI workflows and quality gates
- docs/validation-troubleshooting.md — audits and common fixes
