#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Upgrade: prompt scaffold + linter + /secure-fix + Makefile hooks + repo seeder refresh
set -euo pipefail

[ -d .git ] || { echo "[err] Run from the repo root (must contain .git)"; exit 1; }

backup() { [ -f "$1" ] && cp -a "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"; }

echo "==> 1) tools/prompt_lint.sh"
mkdir -p tools
cat > tools/prompt_lint.sh <<'EOS'
#!/usr/bin/env bash
# Lint a prompt file for required sections
set -euo pipefail
f="${1:-CLAUDE.md}"
[ -f "$f" ] || { echo "[miss] $f not found"; exit 2; }
need=("Role & Scope" "Tools" "Environment" "Loop" "Domain" "Safety" "Tone")
miss=0
for h in "${need[@]}"; do
  grep -qE "^[#]{1,3}\s*${h}\b" "$f" || { echo "[MISS] $h in $f"; miss=1; }
done
[ $miss -eq 0 ] && echo "[ok] $f sections present"
exit $miss
EOS
chmod +x tools/prompt_lint.sh

echo "==> 2) Makefile hooks (append if missing)"
if [ -f Makefile ]; then
  grep -q '^prompt-audit:' Makefile || cat >> Makefile <<'EOM'

# --- Prompt checks ---
prompt-audit:
	@bash tools/prompt_lint.sh CLAUDE.md || true
	@[ -f .claude/commands/secure-fix.md ] && echo "[ok] /secure-fix present" || echo "[miss] .claude/commands/secure-fix.md"

.PHONY: prompt-audit
EOM
else
  cat > Makefile <<'EOM'
.PHONY: audit fmt prompt-audit
audit:
	@echo "No audit pipeline yet. Running prompt-audit only."
	@bash tools/prompt_lint.sh CLAUDE.md || true

fmt:
	@find . -type f -name "*.sh" -print0 | xargs -0 -n1 sh -c 'sed -i'\'''\'' -e "s/\r$//" "$$0"'

prompt-audit:
	@bash tools/prompt_lint.sh CLAUDE.md || true
	@[ -f .claude/commands/secure-fix.md ] && echo "[ok] /secure-fix present" || echo "[miss] .claude/commands/secure-fix.md"
EOM
fi

echo "==> 3) setup_agents_repo.sh (refresh to best-practice CLAUDE.md + /secure-fix)"
if [ -f setup_agents_repo.sh ]; then
  backup setup_agents_repo.sh
fi
cat > setup_agents_repo.sh <<'EOS'
#!/usr/bin/env bash
# setup_agents_repo.sh — seed per-repo agent files (best-practice scaffold)
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

# ---------- Validate JSON ----------
command -v jq >/dev/null 2>&1 && {
  jq -e type .claude/settings.json >/dev/null && echo "[ok] .claude/settings.json JSON"
  [[ -f .mcp.json ]] && jq -e type .mcp.json >/dev/null && echo "[ok] .mcp.json JSON" || true
}

echo "Done."
EOS
chmod +x setup_agents_repo.sh

echo "==> 4) Friendly reminder"
echo "Run:  make prompt-audit   # or: bash tools/prompt_lint.sh CLAUDE.md"
