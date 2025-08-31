# Claude Commands Catalog

The following commands are seeded into repos to standardize workflows.

Explore → Plan → Code → Test
- `.claude/commands/explore-plan-code-test.md`
  - Explore: Summarize in bullets, list impacted files
  - Plan: Acceptance checks and exact commands (lint, typecheck, tests)
  - Code: Minimal diff, unified diff only
  - Test: Run checks and iterate until green

Secure Fix
- `.claude/commands/secure-fix.md`
  - Run optional security tools (semgrep, trivy, gitleaks, hadolint) when available
  - Choose a high-value, low-risk fix and verify

Extended Thinking (controlled)
- `.claude/commands/think-deep.md`
  - Uses `EXTENDED_THINKING` and `THINK_BUDGET_BULLETS` from profile env
  - If off, skip the <thinking> section
  - Output includes a small structured thinking block then normal Plan→Code→Test

Long-Context Map→Reduce
- `.claude/commands/long-context-map-reduce.md`
  - Split big inputs (files, docs, logs) into chunks with IDs
  - MAP: Produce <note id="…"> blocks with key facts + citations (file:line)
  - REDUCE: Merge and rank into a <summary> with risks, questions, and next actions

Prefill Structure
- `.claude/commands/prefill-structure.md`
  - Pre-shapes the response with `<thinking/><plan/><work/><verify/><next/>`
  - Keep thinking to ≤ 5 bullets

Prefill Diff
- `.claude/commands/prefill-diff.md`
  - Forces a unified diff response and explicit commands run

Prompt Improver
- `.claude/commands/prompt-improver.md`
  - Upgrades rough prompts into production-grade ones with variables and output specs

Skill-driven Availability
- Beginner/Vibe: `prefill-structure`, `long-context-map-reduce`
- L1: `think-deep` (budgeted)
- L2/Expert: `think-deep` (on, larger budget)

Environment Flags
- `EXTENDED_THINKING=on|off`
- `THINK_BUDGET_BULLETS=5` (or higher for expert)

