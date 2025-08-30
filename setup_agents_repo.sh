#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Repository Agent Setup Script
# Sets up AI agent configurations for a specific repository
# Run this in each repository where you want agent support
# ============================================================================

# Parse command line arguments
FORCE=0
TEMPLATE_DIR="$HOME/templates/agent-setup"
NO_MCP=0
NO_COMMANDS=0
NO_DIRENV=0
NO_GITIGNORE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --template-dir)
      TEMPLATE_DIR="$2"
      shift 2
      ;;
    --no-mcp)
      NO_MCP=1
      shift
      ;;
    --no-commands)
      NO_COMMANDS=1
      shift
      ;;
    --no-direnv)
      NO_DIRENV=1
      shift
      ;;
    --no-gitignore)
      NO_GITIGNORE=1
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Set up AI agent configurations for a repository."
      echo ""
      echo "Options:"
      echo "  --force           Overwrite existing files"
      echo "  --template-dir    Use custom template directory (default: ~/templates/agent-setup)"
      echo "  --no-mcp          Skip MCP configuration (.mcp.json, .mcp.local.json.example)"
      echo "  --no-commands     Skip Claude commands (.claude/commands/)"
      echo "  --no-direnv       Skip direnv configuration (.envrc, .envrc.local.example)"
      echo "  --no-gitignore    Skip .gitignore updates"
      echo "  --help            Show this help message"
      echo ""
      echo "Examples:"
      echo "  # Standard setup"
      echo "  $0"
      echo ""
      echo "  # Force overwrite all files"
      echo "  $0 --force"
      echo ""
      echo "  # Skip MCP if repo has its own configuration"
      echo "  $0 --no-mcp --no-commands"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not inside a git repository"
  echo "Please run this script from within a git repository"
  exit 1
fi

# Helper function to write files conditionally
write_if_absent() {
  local filepath="$1"
  shift
  
  if [[ "$FORCE" -eq 1 ]] || [[ ! -f "$filepath" ]]; then
    cat > "$filepath"
    echo "  ✓ Created: $filepath"
  else
    echo "  • Keeping: $filepath (use --force to overwrite)"
  fi
}

echo "==> Setting up agent configurations for repository: $(basename "$(pwd)")"
echo ""

# Create necessary directories
echo "Creating directories..."
mkdir -p .claude
if [[ "$NO_COMMANDS" -eq 0 ]]; then
  mkdir -p .claude/commands
  echo "  ✓ Created: .claude/ and .claude/commands/"
else
  echo "  ✓ Created: .claude/ (skipping commands directory)"
fi

# ---------- CLAUDE.md - Repository-specific guardrails ----------
echo ""
echo "Setting up agent instruction files..."

write_if_absent "CLAUDE.md" <<'MD'
# Claude Code — Repo Guardrails
- Work in small atomic diffs; always show a unified diff.
- Tests are the contract: list checks first, run, then fix.
- Package manager: **pnpm**. Don't touch lockfiles without asking.
- Secrets hygiene: never read/write `.env*` or `secrets/**`; redact tokens.
- Cloud ops: discovery first (list/describe); ask before deploy/destroy.
- Commits: reference Jira key when given, e.g., `ENG-123: concise summary`.
MD

# ---------- AGENTS.md - General agent directives ----------
write_if_absent "AGENTS.md" <<'MD'
# Codex / CLI Agent Directives
- Start read-only (plan & inspect); switch to workspace-write with tests passing.
- Prefer: `codex exec "lint, typecheck, unit tests; fix failures"`.
- Use conventional commits; open PRs with a checklist and link the ticket.
- Add/adjust tests when changing behavior; keep coverage steady.
- Respect per-repo `.envrc` (direnv) for org-specific tokens/owners.
MD

# ---------- .claude/settings.json - Claude repository settings ----------
echo ""
echo "Configuring Claude settings..."

write_if_absent ".claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit", "MultiEdit", "Read", "Grep", "Glob", "LS",
      "Bash(rg:*)", "Bash(fd:*)", "Bash(jq:*)", "Bash(yq:*)", "Bash(http:*)",
      "Bash(gh:*)", "Bash(aws:*)", "Bash(az:*)", "Bash(docker:*)",
      "Bash(kubectl:*)", "Bash(helm:*)", "Bash(terraform:*)",
      "Bash(node:*)", "Bash(npm:*)", "Bash(pnpm:*)", "Bash(npx:*)",
      "Bash(pytest:*)", "Bash(python3:*)",
      "Bash(gemini:*)", "Bash(grok:*)", "Bash(codex:*)", "Bash(openai:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(docker push:*)",
      "Bash(terraform apply:*)",
      "Bash(aws s3 rm:*)",
      "Bash(az group delete:*)",
      "WebFetch"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "defaultMode": "acceptEdits"
  }
}
JSON

# ---------- .mcp.json - MCP server configuration ----------
if [[ "$NO_MCP" -eq 0 ]]; then
echo ""
echo "Configuring MCP servers..."

write_if_absent ".mcp.json" <<'JSON'
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "atlassian": {
      "type": "sse",
      "url": "https://mcp.atlassian.com/v1/sse"
    }
  }
}
JSON
fi

# ---------- Claude commands ----------
if [[ "$NO_COMMANDS" -eq 0 ]]; then
echo ""
echo "Setting up Claude commands..."

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

write_if_absent ".claude/commands/fix-ci-failures.md" <<'MD'
Run linter, typecheck, unit tests, e2e smoke. Fix first failure with a minimal diff; iterate until green. Output a short postmortem (root cause + prevention).
MD

write_if_absent ".claude/commands/code-review.md" <<'MD'
Review the recent changes:
1. Check for bugs, security issues, performance problems
2. Verify test coverage for new functionality
3. Ensure code follows project conventions
4. Suggest improvements if needed
MD

write_if_absent ".claude/commands/refactor-safe.md" <<'MD'
1. Run existing tests to establish baseline
2. Make refactoring changes
3. Run tests again to ensure no regression
4. Update tests if interface changed
5. Show before/after comparison
MD
fi

# ---------- Direnv Configuration ----------
if [[ "$NO_DIRENV" -eq 0 ]]; then
  echo ""
  echo "Setting up direnv configuration..."

write_if_absent ".envrc" <<'ENVRC'
# Load Python virtual environment if present
if [ -d .venv ]; then
  source .venv/bin/activate
fi

# Load local environment variables (not committed to git)
if [ -f .envrc.local ]; then
  source .envrc.local
fi

# Example .envrc.local content (create this file locally):
# export GEMINI_API_KEY="your-key-here"
# export XAI_API_KEY="your-key-here"
# export GITHUB_PAT="your-pat-here"
# export OPENAI_API_KEY="your-key-here"
ENVRC

# Create a template for .envrc.local
write_if_absent ".envrc.local.example" <<'EXAMPLE'
# Copy this to .envrc.local and fill in your API keys
# .envrc.local is gitignored and won't be committed

# AI API Keys
export GEMINI_API_KEY=""
export XAI_API_KEY=""
export OPENAI_API_KEY=""
export ANTHROPIC_API_KEY=""

# GitHub Personal Access Token
export GITHUB_PAT=""

# Other project-specific environment variables
# export DATABASE_URL=""
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
EXAMPLE

  # Allow direnv if it's installed
  if command -v direnv >/dev/null 2>&1; then
    direnv allow . 2>/dev/null || true
    echo "  ✓ Direnv configured (run 'direnv allow' to activate)"
  fi
fi

# ---------- MCP Local Override Support ----------
if [[ "$NO_MCP" -eq 0 ]]; then
echo ""
echo "Setting up MCP local override support..."

# Create a note about .mcp.local.json
cat > .mcp.local.json.example <<'JSON'
{
  "mcpServers": {
    "example-local": {
      "type": "stdio",
      "command": "/path/to/local/mcp/server",
      "args": ["--some-arg"],
      "env": {
        "API_KEY": "${YOUR_API_KEY}"
      }
    }
  }
}
JSON

echo "  ✓ Created .mcp.local.json.example (copy to .mcp.local.json for local overrides)"
fi

# ---------- Update .gitignore ----------
if [[ "$NO_GITIGNORE" -eq 0 ]]; then
  echo ""
  echo "Updating .gitignore..."

# Check if .gitignore exists, create if not
if [[ ! -f .gitignore ]]; then
  touch .gitignore
  echo "  ✓ Created: .gitignore"
fi

# Comprehensive gitignore entries for agents, secrets, and build artifacts
declare -a GITIGNORE_ENTRIES=(
  "# Agents & Environment"
  ".envrc.local"
  ".env.local"
  ".venv/"
  ".claude/cache/"
  ".mcp.local.json"
  ""
  "# Node/Python build"
  "node_modules/"
  "dist/"
  "build/"
  "__pycache__/"
  "*.pyc"
  ""
  "# OS/Editor"
  ".DS_Store"
  "Thumbs.db"
  "*.swp"
  "*.swo"
  "*~"
  ""
  "# Logs"
  "*.log"
  "logs/"
  ""
  "# Secrets"
  ".env"
  ".env.*"
  "!.env.example"
  "secrets/"
)

# Add entries if they don't exist
for entry in "${GITIGNORE_ENTRIES[@]}"; do
  if [[ -z "$entry" ]]; then
    # Empty line for spacing
    continue
  elif [[ "$entry" == "#"* ]]; then
    # Comment line
    if ! grep -qF "$entry" .gitignore 2>/dev/null; then
      echo "$entry" >> .gitignore
    fi
  else
    # Regular entry
    if ! grep -qF "$entry" .gitignore 2>/dev/null; then
      echo "$entry" >> .gitignore
      echo "  ✓ Added to .gitignore: $entry"
    fi
  fi
done
fi

# ---------- Sanity Checks ----------
echo ""
echo "Running sanity checks..."

# Check JSON validity
ERROR_COUNT=0
if command -v jq >/dev/null 2>&1; then
  if jq -e type .claude/settings.json >/dev/null 2>&1; then
    echo "  ✓ .claude/settings.json is valid JSON"
  else
    echo "  ✗ .claude/settings.json has invalid JSON"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi
  
  if jq -e type .mcp.json >/dev/null 2>&1; then
    echo "  ✓ .mcp.json is valid JSON"
  else
    echo "  ✗ .mcp.json has invalid JSON"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi
else
  echo "  ⚠ jq not installed, skipping JSON validation"
fi

# Check required tools
MISSING_TOOLS=()
for tool in rg fd pnpm; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    MISSING_TOOLS+=("$tool")
  fi
done

if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
  echo "  ⚠ Missing recommended tools: ${MISSING_TOOLS[*]}"
  echo "    Install with: ~/setup/install_key_software_wsl.sh"
fi

# ---------- Summary ----------
echo ""
echo "==> Repository agent setup complete!"
echo ""
echo "Files created/updated:"
echo "  • CLAUDE.md                   - Repository-specific Claude guardrails"
echo "  • AGENTS.md                   - General agent directives"
echo "  • .claude/settings.json       - Claude permissions and settings"
if [[ "$NO_MCP" -eq 0 ]]; then echo "  • .mcp.json                   - MCP server configuration"; fi
if [[ "$NO_MCP" -eq 0 ]]; then echo "  • .mcp.local.json.example     - Template for local MCP overrides"; fi
if [[ "$NO_COMMANDS" -eq 0 ]]; then echo "  • .claude/commands/           - Custom Claude commands"; fi
echo "  • .envrc                      - Direnv configuration"
echo "  • .envrc.local.example        - Template for local environment variables"
echo "  • .gitignore                  - Updated with agent/build entries"
echo ""
echo "Next steps:"
echo "  1. Copy .envrc.local.example to .envrc.local and add your API keys"
echo "  2. Review and customize CLAUDE.md for your project's specific needs"
echo "  3. Update package manager preference in CLAUDE.md if not using pnpm"
echo "  4. Add project-specific commands in .claude/commands/"
echo "  5. Configure additional MCP servers in .mcp.local.json if needed"

if [[ $ERROR_COUNT -gt 0 ]]; then
  echo ""
  echo "⚠ Warning: $ERROR_COUNT configuration error(s) detected. Please review above."
  exit 1
fi
