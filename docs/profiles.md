# Profiles & Skill Levels

Skill levels control permissions, defaults, and command sets. Apply or change profiles with:

```bash
scripts/apply_profile.sh --skill <vibe|beginner|l1|l2|expert> --phase <poc|mvp|beta|scale>
```

Vibe (PM/non-eng)
- Default mode: require approval; read-only shell
- Env: `TEACH_MODE=1`, `EXTENDED_THINKING=off`
- Commands: explain-oriented; no dangerous operations

Beginner
- Default mode: accept edits; safe shell subset
- Env: `TEACH_MODE=1`, `EXTENDED_THINKING=off`, `THINK_BUDGET_BULLETS=5`
- Commands: `prefill-structure`, `long-context-map-reduce`

L1 (Junior)
- Default mode: accept edits; more tools available
- Env: `EXTENDED_THINKING=off`, `THINK_BUDGET_BULLETS=5`, `PARALLEL_TOOLS=1`
- Commands: adds `think-deep`

L2 (Intermediate)
- Default mode: accept edits + commands; security/dev tools
- Env: `EXTENDED_THINKING=on`, `THINK_BUDGET_BULLETS=5`, `PARALLEL_TOOLS=1`
- Commands: `think-deep`

Expert
- Default mode: full-auto; broad tool access
- Env: `EXTENDED_THINKING=on`, `THINK_BUDGET_BULLETS=7`, `ARCHITECT_MODE=1`
- Commands: `think-deep`

Project Phases
- POC: fastest iteration, gates advisory
- MVP: lints/typecheck/unit tests required
- Beta: coverage ≥ 60%, security gates, integrations
- Scale: coverage ≥ 80%, SLOs, load/perf and reliability

Artifacts Created
- `.claude/commands/` linked to skill-specific command sets
- `.github/workflows/ci.yml` replaced with phase-specific workflow
- `PROFILE.md` documents the active profile

