#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# setup_agents_repo.sh — SoftSensorAI repository setup script
# Configures AI agents and development tools for individual repositories
# Part of SoftSensorAI: Learning-aware AI development platform
#
# Flags:
#   --force         overwrite existing files
#   --no-mcp        skip writing .mcp.json
#   --no-commands   skip writing .claude/commands/*
#   --no-direnv     skip creating .envrc
#   --no-gitignore  skip appending to .gitignore
set -euo pipefail

FORCE=0; DO_MCP=1; DO_CMDS=1; DO_DIRENV=1; DO_GITIGNORE=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift;;
    --no-mcp) DO_MCP=0; shift;;
    --no-commands) DO_CMDS=0; shift;;
    --no-direnv) DO_DIRENV=0; shift;;
    --no-gitignore) DO_GITIGNORE=0; shift;;
    *) echo "Unknown flag: $1" >&2; exit 2;;
  esac
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not in a git repo"; exit 1; }
mkdir -p .claude .claude/commands

write_if_absent() { # $1=path ; body from heredoc follows
  local p="$1"
  if [[ "$FORCE" -eq 1 || ! -f "$p" ]]; then
    cat > "$p"
    echo "✓ wrote $p"
  else
    echo "• kept $p"
  fi
}

ensure_gitignore() {
  local g=.gitignore; touch "$g"
  grep -qxF "$1" "$g" || echo "$1" >> "$g"
}

# ---------- CLAUDE.md (best-practice scaffold) ----------
write_if_absent "CLAUDE.md" <<'MD'
# Role & Scope
You are this repo's coding agent. Produce minimal, correct diffs that pass tests and linters.

# Tools
- Primary: pnpm, node (LTS), python3 + .venv/pytest, docker, kubectl, helm.
- MCP: github (issues/PRs), atlassian (Jira). Link ticket keys in commits/PRs.
- Ask before: deploy/destroy, WebFetch, or touching `.env*`/`secrets/**`.
- Format tool calls precisely; show the exact commands you intend to run.

# Environment
- OS: Linux (WSL / Dev Container).
- Package managers: pnpm for JS/TS; pip/uv inside `.venv` for Python.
- Workspace cwd: repository root unless stated.

# Loop
1) **Plan**: list acceptance checks + the exact commands (lint, typecheck, tests).
2) **Code**: smallest possible diff to satisfy checks. Show a unified diff.
3) **Test**: run the commands; if anything fails, fix and re-run.
4) **PR**: open a concise PR with summary, checklist, and ticket link.

# Domain
- Typescript with ESLint/Prettier; keep types strict.
- Tests first for new behavior; never reduce coverage intentionally.
- Backend: prefer small, composable functions; instrument for observability.
- Data/ML: track datasets & runs; prefer reproducible scripts/pipelines.

# Safety
- Never read or write `.env*` or `secrets/**`; redact tokens from logs.
- Ask before destructive ops (`aws s3 rm`, `az group delete`, `terraform apply`).
- Keep commits atomic; avoid committing generated binaries or large data.

# Tone
Concise, technical, and actionable. Explain only when needed to decide.

# Performance
- **Parallel Tools**: When gathering info, call multiple tools in ONE message (Read, Grep, Bash in parallel).
- **Temp Cleanup**: After working with temp files, always clean up: `rm -f /tmp/temp_* 2>/dev/null`
- **Batch Operations**: Group related file edits with MultiEdit; batch git operations.
- **Search First**: Use Grep/Glob before Read to minimize context usage.

# Git Workflow
- **Worktrees**: For parallel work, use: `git worktree add ../proj-feature-x feature-x`
- **Atomic Commits**: One logical change per commit; write clear messages.
- **Branch Hygiene**: Delete merged branches; rebase feature branches regularly.
- **No Force Push**: Never force push to main/master or shared branches.

## Formatting preferences
- Be explicit: follow headings and bullet lists; when asked for JSON, return **valid JSON only**.
- Match the prompt's style: if the prompt uses tables/bullets, mirror that; if prose, keep paragraphs tight.
- You may use XML tags to structure output blocks we'll parse later (e.g., <plan/>, <diff/>, <verify/>).

## Tool use & parallelism
- When multiple operations are independent, **invoke tools in parallel** rather than sequentially.
- After a tool-use message, return **all** tool results in a **single** user message, with **tool_result blocks first**, each carrying its matching `tool_use_id`, then any text.
- If a task is stateful or rate-limited (e.g., DB migration), set **disable_parallel_tool_use=true** and run sequentially.

## Thinking controls
- For hard steps, do a brief step-by-step *thinking* section before the answer; keep it concise and separate using <thinking/> and <answer/> tags.
- Prefer *guided* or *structured* thinking (explicit steps and tags) over generic "think more" prompts.

## Long-context hygiene
- Summarize before quoting; prefer citations (file:line) over long excerpts.
- Cap quotes to what’s necessary; avoid re-pasting unchanged large blocks.
- Use IDs for chunks (e.g., [A], [B]) and reference them in the summary.

## Formatting preferences (additional)
- If asked for Markdown tickets: use the provided skeleton exactly.
- If asked for CSV: return one table; headers first row; quote fields with commas/newlines.
- Match the prompt’s style (bullets vs prose). For JSON requests: valid JSON only (no prose).
MD

# ---------- .claude/settings.json ----------
write_if_absent ".claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit","MultiEdit","Read","Grep","Glob","LS",
      "Bash(rg:*)","Bash(fd:*)","Bash(jq:*)","Bash(yq:*)","Bash(http:*)",
      "Bash(gh:*)","Bash(aws:*)","Bash(az:*)","Bash(docker:*)",
      "Bash(kubectl:*)","Bash(helm:*)","Bash(terraform:*)",
      "Bash(node:*)","Bash(npm:*)","Bash(pnpm:*)","Bash(npx:*)",
      "Bash(pytest:*)","Bash(python3:*)",
      "Bash(gemini:*)","Bash(grok:*)","Bash(codex:*)","Bash(openai:*)"
    ],
    "ask": [
      "Bash(git push:*)","Bash(docker push:*)","Bash(terraform apply:*)",
      "Bash(aws s3 rm:*)","Bash(az group delete:*)","WebFetch"
    ],
    "deny": ["Read(./.env)","Read(./.env.*)","Read(./secrets/**)"],
    "defaultMode": "acceptEdits"
  }
}
JSON

# ---------- AGENTS.md (Codex/CLI guidance) ----------
write_if_absent "AGENTS.md" <<'MD'
# Codex / CLI Agent Directives
- Start read-only (plan & inspect); switch to workspace-write once tests pass.
- Prefer: `codex exec "lint, typecheck, unit tests; fix failures"`.
- Conventional commits; PR checklist; link the ticket.
- Add/adjust tests when behavior changes; keep coverage steady.
- Respect `.envrc` (direnv) and **never** commit secrets.
MD

# ---------- .mcp.json ----------
if [[ "$DO_MCP" -eq 1 ]]; then
write_if_absent ".mcp.json" <<'JSON'
{
  "mcpServers": {
    "github":   { "type": "http", "url": "https://api.githubcopilot.com/mcp/" },
    "atlassian":{ "type": "sse",  "url": "https://mcp.atlassian.com/v1/sse" }
  }
}
JSON
fi

# ---------- Commands (Claude slash-commands) ----------
if [[ "$DO_CMDS" -eq 1 ]]; then
write_if_absent ".claude/commands/explore-plan-code-test.md" <<'MD'
# Explore
Summarize the task in 3 bullets. List impacted files.
# Plan
List acceptance checks and exact commands (lint, typecheck, tests).
# Code
Make the smallest change to pass checks. Show a unified diff.
# Test
Run the commands. If anything fails, fix and re-run.
MD

write_if_absent ".claude/commands/secure-fix.md" <<'MD'
# Goal
Identify and fix the most impactful security issue(s) with minimal diffs.

# Plan
1) Enumerate candidate issues; if tools exist, run:
   - JS/TS: `pnpm audit` (or `npm audit`), `semgrep --config auto` if available
   - Docker/IaC: `hadolint Dockerfile`, `trivy fs .` if available
   - Secrets: `gitleaks detect --no-banner -v` if available
2) Choose the highest-value fix (low risk, high impact).
3) List acceptance checks + exact commands you will run.

# Code
Make the smallest necessary change. Show a unified diff.

# Test
Run: lints/tests and re-run the relevant security tool. If anything fails, fix and re-run.

# Output
- Findings summary (1–3 bullets)
- Diff
- Command outputs (trimmed)
- Next steps (follow-ups / tickets)
MD

write_if_absent ".claude/commands/think-deep.md" <<'MD'
# Extended Thinking (controlled)
Use this only if the task is complex or ambiguous. Keep it tight.

<thinking>
- List ≤ {{THINK_BUDGET_BULLETS|5}} key uncertainties, edge cases, risks.
- Compare 2–3 options; pick 1 with rationale (one-liner).
- Note success metrics / acceptance checks you'll prove.
</thinking>

<answer>
Now execute the Plan→Code→Test loop with minimal diffs. Show the unified diff and the exact commands run.
</answer>

Rules:
- If EXTENDED_THINKING=off, skip <thinking> and proceed.
- Never include secrets; remove any temp files you create.
MD

write_if_absent ".claude/commands/long-context-map-reduce.md" <<'MD'
# Long-Context Map→Reduce

<input>
{{BIG_CONTEXT_OR_PATH_LIST}}
</input>

Plan
- Split input into logical chunks (modules/files/sections). Emit an ID + title for each.
- MAP: For each chunk, produce a <note id="..."> with key facts, risks, and citations (file:line).
- REDUCE: Merge notes: dedupe, rank by severity/impact, produce a <summary> with:
  - Top risks/opportunities (bullets with citations)
  - Open questions (what info would materially change the answer)
  - Next actions (commands/PRs)

Output order
<notes> ...multiple <note id="X">…</note> … </notes>
<summary> …merged view… </summary>
MD

write_if_absent ".claude/commands/prefill-structure.md" <<'MD'
# Prefill Structure
Assistant (prefill this, then continue):

<thinking></thinking>
<plan></plan>
<work></work>
<verify></verify>
<next></next>

User: Continue and fill each block. Keep <thinking> ≤ 5 bullets.
MD

write_if_absent ".claude/commands/prefill-diff.md" <<'MD'
# Prefill Diff
Assistant (prefill):

```diff
@@ Planned minimal diff @@
```

User: Replace the fenced block with an actual unified diff. Then list the exact commands you ran.
MD

write_if_absent ".claude/commands/prompt-improver.md" <<'MD'
# Prompt Improver

<input>
{{RAW_PROMPT}}
</input>

Rewrite into a production-grade prompt with:
- System/User separation
- Variables as {{LIKE_THIS}}, with a "Variables" block listing defaults
- Output spec with headings/tables/JSON as appropriate
- Guardrails (no secrets, minimal diffs, exact commands)
- A "Test run" example with sample values (one-liner each)

Emit:
<improved_prompt>…final prompt text…</improved_prompt>
<variables>
- NAME: default + notes
</variables>
<why>1–3 bullets: what changed and why</why>
MD

# Additional patterns and task guides
write_if_absent ".claude/commands/parallel-map.md" <<'MD'
# Parallel Map (independent tasks)

<plan>
- List independent sub-tasks that can run in parallel.
- For each, specify inputs, outputs, and the exact commands.
- Define a merge step to combine results.
</plan>

<work>
- Run parallel steps where safe; capture outputs/logs succinctly.
</work>

<merge>
- Combine results; highlight conflicts and resolutions.
</merge>

<verify>
- Re-run tests/lints; confirm acceptance checks.
</verify>
MD

write_if_absent ".claude/commands/chain-step-skeleton.md" <<'MD'
# Chain Step Skeleton

<goal>
- State the step’s objective in one sentence.
</goal>

<inputs>
- Summarize handoff from previous step (IDs, files, notes).
</inputs>

<work>
- Actions taken; commands; minimal changes with diffs.
</work>

<handoff>
- What the next step needs (IDs, files, assumptions).
</handoff>
MD

write_if_absent ".claude/commands/audit-full.md" <<'MD'
# Full Audit (90 minutes max)

<scope>
- Code health, tests, security, performance, DX.
</scope>

<checks>
- Lints/type/tests; security scans; coverage; bundle size; CI gates.
</checks>

<findings>
- 3–7 findings ranked by impact/risk with evidence (file:line).
</findings>

<actions>
- 3 quick wins, 3 medium, 1 big rock; include acceptance criteria.
</actions>
MD

write_if_absent ".claude/commands/tickets-from-code.md" <<'MD'
# Tickets From Code

<input>
- Paths/areas: {{PATHS}}
</input>

<tickets>
- Generate concise tickets with title, context, acceptance, estimate.
- Link files and risks; batch by epic.
</tickets>
MD

write_if_absent ".claude/commands/architect-spike.md" <<'MD'
# Architecture Spike

<problem>
- Define constraints, SLAs/SLOs, and success metrics.
</problem>

<options>
- Compare 2–3 approaches (pros/cons, risks, costs).
</options>

<recommendation>
- Pick 1; outline MVP plan and rollback.
</recommendation>
MD

write_if_absent ".claude/commands/migration-plan.md" <<'MD'
# Migration Plan

<context>
- Current vs target state; data shape; downtime budget.
</context>

<plan>
- Backfill, dual writes/reads, cutover, verify, rollback.
- Commands and checkpoints per phase.
</plan>
MD

write_if_absent ".claude/commands/observability-pass.md" <<'MD'
# Observability Pass

<targets>
- Services/modules; key transactions.
</targets>

<instrument>
- Tracing, structured logs, metrics; SLIs.
</instrument>

<verify>
- Local + CI checks; dashboards linked.
</verify>
MD

write_if_absent ".claude/commands/api-contract-update.md" <<'MD'
# API Contract Update

<input>
- OpenAPI/GraphQL files; breaking-change policy.
</input>

<changes>
- Minimal diff to spec; regenerate clients; update tests.
</changes>

<verify>
- Contract lint; codegen compiles; consumers tested.
</verify>
MD
fi

# ---------- .envrc (optional) ----------
if [[ "$DO_DIRENV" -eq 1 ]]; then
  if [[ "$FORCE" -eq 1 || ! -f .envrc ]]; then
    cat > .envrc <<'RC'
# Auto-activate venv if present
if [ -d .venv ]; then
  source .venv/bin/activate
fi
# Load private overrides (never commit)
[ -f .envrc.local ] && source .envrc.local
RC
    echo "✓ wrote .envrc"
  else
    echo "• kept .envrc"
  fi
fi

# ---------- .gitignore hygiene ----------
if [[ "$DO_GITIGNORE" -eq 1 ]]; then
  ensure_gitignore ".envrc.local"
  ensure_gitignore ".venv/"
  ensure_gitignore ".claude/cache/"
  ensure_gitignore ".mcp.local.json"
  ensure_gitignore "node_modules/"
  ensure_gitignore "dist/"
  ensure_gitignore "build/"
fi

# ---------- .trivyignore template ----------
write_if_absent ".trivyignore" <<'IGN'
# Trivy ignore file (optional)
# List CVE IDs or patterns to suppress known, accepted vulnerabilities.
# Keep this file reviewed; reference a ticket for each entry.

# Examples:
# CVE-2023-12345  # accepted until upstream library X is updated
# CVE-2024-00001  # false positive on package Y in dev-only context

# You can also ignore specific files/paths for config scans:
# cmd/**/testdata/**
IGN

# ---------- .semgrepignore template ----------
write_if_absent ".semgrepignore" <<'SEM'
# Semgrep ignore file (optional)
# Paths to exclude from scans. Keep this file reviewed.

# Common directories
node_modules/
dist/
build/
.venv/
coverage/
.git/

# Generated or vendor code (adjust as needed)
vendor/
*.min.js

# Test data
**/testdata/**
**/__fixtures__/**
SEM

# ---------- Validate JSON ----------
command -v jq >/dev/null 2>&1 && {
  jq -e type .claude/settings.json >/dev/null && echo "[ok] .claude/settings.json JSON"
  [[ -f .mcp.json ]] && jq -e type .mcp.json >/dev/null && echo "[ok] .mcp.json JSON" || true
}

echo "Done."
