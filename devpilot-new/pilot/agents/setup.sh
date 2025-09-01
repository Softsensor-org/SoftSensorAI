#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# DevPilot Agent Setup - Global Configuration for AI CLI Agents
# Sets up configurations for Claude, Gemini, Grok, Codex, and other AI tools
# Part of DevPilot: Modern AI-powered development platform
# ============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOT_ROOT="$(dirname "$SCRIPT_DIR")"
DEVPILOT_ROOT="$(dirname "$PILOT_ROOT")"

# Source core utilities
source "$DEVPILOT_ROOT/core/config.sh"
source "$DEVPILOT_ROOT/core/logger.sh"

# Configuration directories
TEMPLATE_DIR="$HOME/templates/agent-setup"
AGENTS_CONFIG_DIR="$HOME/.devpilot/agents"

# Command-line options
FORCE_INSTALL=false
SKIP_TEMPLATES=false
DRY_RUN=false

# ============================================================================
# Help and Usage
# ============================================================================

show_help() {
    cat <<EOF
Usage: devpilot pilot setup [OPTIONS]

Configure AI CLI agents globally with appropriate permissions and settings.

Options:
    --force          Overwrite existing configurations
    --skip-templates Skip template file creation
    --dry-run        Preview actions without making changes
    --help, -h       Show this help message

Agents Configured:
    • Claude CLI  - Anthropic's AI coding assistant
    • Gemini CLI  - Google's AI model interface
    • Grok CLI    - xAI's conversational AI
    • Codex CLI   - OpenAI's code generation tool

Examples:
    # Initial setup
    devpilot pilot setup

    # Force update all configurations
    devpilot pilot setup --force

    # Preview changes
    devpilot pilot setup --dry-run

EOF
    exit 0
}

# ============================================================================
# Agent Configuration Functions
# ============================================================================

setup_claude() {
    log_step "Configuring Claude CLI"
    
    local claude_dir="$HOME/.claude"
    local settings_file="$claude_dir/settings.json"
    
    if [[ -f "$settings_file" ]] && ! $FORCE_INSTALL; then
        log_info "Claude already configured (use --force to overwrite)"
        return
    fi
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would configure Claude at: $settings_file"
        return
    fi
    
    mkdir -p "$claude_dir"
    
    cat > "$settings_file" <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit", "MultiEdit", "Read", "Grep", "Glob", "LS",
      "Bash(rg:*)", "Bash(fd:*)", "Bash(jq:*)", "Bash(yq:*)",
      "Bash(http:*)", "Bash(curl:*)", "Bash(wget:*)"
    ],
    "ask": [
      "WebFetch", "WebSearch",
      "Bash(gh:*)", "Bash(git push:*)",
      "Bash(docker:*)", "Bash(kubectl:*)",
      "Bash(terraform:*)", "Bash(aws:*)", "Bash(az:*)",
      "Bash(npm publish:*)", "Bash(cargo publish:*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(**/.ssh/id_*)",
      "Bash(rm -rf /)"
    ],
    "defaultMode": "acceptEdits"
  },
  "enableAllProjectMcpServers": true,
  "hooks": {
    "preCommit": "devpilot insights lint --staged",
    "postCommit": "devpilot insights audit --quick"
  }
}
JSON
    
    log_success "Claude configured at: $settings_file"
}

setup_gemini() {
    log_step "Configuring Gemini CLI"
    
    local gemini_dir="$HOME/.gemini"
    local settings_file="$gemini_dir/settings.json"
    
    if [[ -f "$settings_file" ]] && ! $FORCE_INSTALL; then
        log_info "Gemini already configured (use --force to overwrite)"
        return
    fi
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would configure Gemini at: $settings_file"
        return
    fi
    
    mkdir -p "$gemini_dir"
    
    cat > "$settings_file" <<'JSON'
{
  "defaultModel": "gemini-2.5-pro",
  "temperature": 0.7,
  "maxTokens": 8192,
  "mcpServers": {},
  "telemetry": false,
  "safety": {
    "harassment": "BLOCK_NONE",
    "hateSpeech": "BLOCK_NONE",
    "sexuallyExplicit": "BLOCK_NONE",
    "dangerousContent": "BLOCK_NONE"
  }
}
JSON
    
    log_success "Gemini configured at: $settings_file"
}

setup_grok() {
    log_step "Configuring Grok CLI"
    
    local grok_dir="$HOME/.grok"
    local settings_file="$grok_dir/user-settings.json"
    
    if [[ -f "$settings_file" ]] && ! $FORCE_INSTALL; then
        log_info "Grok already configured (use --force to overwrite)"
        return
    fi
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would configure Grok at: $settings_file"
        return
    fi
    
    mkdir -p "$grok_dir"
    
    cat > "$settings_file" <<'JSON'
{
  "defaultModel": "grok-4-latest",
  "baseURL": "https://api.x.ai/v1",
  "maxTokens": 4096,
  "temperature": 0.8,
  "stream": true,
  "responseFormat": "markdown"
}
JSON
    
    log_success "Grok configured at: $settings_file"
}

setup_codex() {
    log_step "Configuring Codex CLI"
    
    local codex_dir="$HOME/.codex"
    local config_file="$codex_dir/config.yaml"
    
    if [[ -f "$config_file" ]] && ! $FORCE_INSTALL; then
        log_info "Codex already configured (use --force to overwrite)"
        return
    fi
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would configure Codex at: $config_file"
        return
    fi
    
    mkdir -p "$codex_dir"
    
    cat > "$config_file" <<'YAML'
# OpenAI Codex CLI Configuration
model: o4-mini
approvalMode: auto-edit
notify: true
temperature: 0.3
maxTokens: 4096

# Execution settings
executionMode: safe
timeout: 30

# Sandbox settings (uncomment to enable)
# sandbox: docker
# sandboxImage: python:3.11-slim

# Code review settings
review:
  enabled: true
  strictness: medium
  checkTypes: true
  checkSecurity: true
YAML
    
    # Check for legacy config
    if [[ -f "$codex_dir/config.toml" ]]; then
        log_warn "Found legacy config.toml (YAML is now preferred)"
        if $FORCE_INSTALL; then
            mv "$codex_dir/config.toml" "$codex_dir/config.toml.bak"
            log_info "Backed up legacy config to config.toml.bak"
        fi
    fi
    
    log_success "Codex configured at: $config_file"
}

# ============================================================================
# Template Creation
# ============================================================================

create_templates() {
    if $SKIP_TEMPLATES; then
        log_info "Skipping template creation (--skip-templates)"
        return
    fi
    
    log_step "Creating repository template files"
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would create templates in: $TEMPLATE_DIR"
        return
    fi
    
    mkdir -p "$TEMPLATE_DIR"
    
    # CLAUDE.md template - Repository guardrails
    cat > "$TEMPLATE_DIR/CLAUDE.md" <<'MD'
# Claude Code — Repository Guardrails

## Core Principles
- Work in small, atomic diffs; always show a unified diff
- Tests are the contract: list checks first, run, then fix
- Package manager: **pnpm** (don't touch lockfiles without asking)
- Secrets hygiene: never read/write `.env*` or `secrets/**`; redact tokens
- Cloud ops: discovery first (list/describe); ask before deploy/destroy

## Development Workflow
1. **Plan**: List acceptance criteria and exact commands (lint, typecheck, tests)
2. **Code**: Smallest possible diff to satisfy checks; show unified diff
3. **Test**: Run the commands; if anything fails, fix and re-run
4. **Commit**: Reference ticket key (e.g., `ENG-123: concise summary`)

## AI Agent Guidelines
- Start read-only (plan & inspect), then switch to workspace-write
- Use conventional commits; open PRs with checklist and ticket link
- Add/adjust tests when changing behavior; keep coverage steady
- Respect per-repo `.envrc` (direnv) for org-specific tokens/owners

## Performance & Security
- Batch operations when possible (parallel tool calls)
- Clean up temp files after use: `rm -f /tmp/temp_* 2>/dev/null`
- Never commit generated binaries or large data files
- Always validate external inputs and sanitize user data
MD
    
    # Repository-specific Claude settings
    cat > "$TEMPLATE_DIR/claude-settings.json" <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit", "MultiEdit", "Read", "Grep", "Glob", "LS",
      "Bash(rg:*)", "Bash(fd:*)", "Bash(jq:*)", "Bash(yq:*)", "Bash(http:*)",
      "Bash(gh:*)", "Bash(aws:*)", "Bash(az:*)", "Bash(docker:*)",
      "Bash(kubectl:*)", "Bash(helm:*)", "Bash(terraform:*)",
      "Bash(node:*)", "Bash(npm:*)", "Bash(pnpm:*)", "Bash(npx:*)",
      "Bash(pytest:*)", "Bash(python3:*)", "Bash(poetry:*)", "Bash(pip:*)",
      "Bash(cargo:*)", "Bash(rustc:*)", "Bash(go:*)",
      "Bash(make:*)", "Bash(just:*)", "Bash(mise:*)",
      "Bash(ruff:*)", "Bash(black:*)", "Bash(mypy:*)", "Bash(eslint:*)",
      "Bash(prettier:*)", "Bash(tsc:*)", "Bash(vitest:*)", "Bash(jest:*)",
      "Bash(prisma:*)", "Bash(drizzle-kit:*)", "Bash(migrate:*)",
      "Bash(dbt:*)", "Bash(sqlfluff:*)", "Bash(pgcli:*)",
      "Bash(trivy:*)", "Bash(semgrep:*)", "Bash(gitleaks:*)",
      "Bash(commitlint:*)", "Bash(cz:*)", "Bash(changeset:*)",
      "Bash(hyperfine:*)", "Bash(entr:*)", "Bash(watchexec:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(docker push:*)",
      "Bash(npm publish:*)",
      "Bash(cargo publish:*)",
      "Bash(terraform apply:*)",
      "Bash(terraform destroy:*)",
      "Bash(aws s3 rm:*)",
      "Bash(az group delete:*)",
      "Bash(kubectl delete:*)",
      "WebFetch"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(**/.ssh/id_*)",
      "Write(./.env)",
      "Write(./secrets/**)"
    ],
    "defaultMode": "acceptEdits"
  },
  "projectHooks": {
    "preCommit": "npm run lint && npm run typecheck",
    "postMerge": "npm install && npm run build"
  }
}
JSON
    
    # MCP servers configuration template
    cat > "$TEMPLATE_DIR/mcp.json" <<'JSON'
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "auth": "${GITHUB_TOKEN}"
    },
    "atlassian": {
      "type": "sse",
      "url": "https://mcp.atlassian.com/v1/sse",
      "auth": "${ATLASSIAN_TOKEN}"
    },
    "database": {
      "type": "postgres",
      "connectionString": "${DATABASE_URL}",
      "readOnly": true
    },
    "redis": {
      "type": "redis",
      "url": "${REDIS_URL}",
      "prefix": "devpilot:"
    }
  }
}
JSON
    
    # AGENTS.md template - General AI agent directives
    cat > "$TEMPLATE_DIR/AGENTS.md" <<'MD'
# AI Agent Directives

## General Guidelines
- Start read-only (plan & inspect), then switch to workspace-write with tests passing
- Prefer `codex exec "lint, typecheck, unit tests; fix failures"` for non-interactive runs
- Use conventional commits; open PRs with a checklist and link the ticket
- Add/adjust tests when changing behavior; keep coverage steady
- Respect per-repo `.envrc` (direnv) for org-specific tokens/owners

## Agent-Specific Notes

### Claude
- Best for complex refactoring and architecture decisions
- Use for code reviews and documentation generation
- Leverage MCP servers for external integrations

### Gemini
- Excellent for data analysis and ML workflows
- Use for exploring large codebases and pattern detection
- Good at generating test cases and edge case scenarios

### Grok
- Best for conversational debugging and exploratory coding
- Use for quick prototypes and proof-of-concepts
- Good at explaining complex concepts

### Codex
- Optimized for code generation and completion
- Use for boilerplate generation and API integration
- Best with clear, specific prompts

## Security Reminders
- Never commit API keys or secrets
- Always validate and sanitize inputs
- Review generated code for security vulnerabilities
- Use environment variables for sensitive configuration
MD
    
    log_success "Templates created in: $TEMPLATE_DIR"
}

# ============================================================================
# DevPilot Agent Registry
# ============================================================================

setup_agent_registry() {
    log_step "Setting up DevPilot agent registry"
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would create agent registry at: $AGENTS_CONFIG_DIR"
        return
    fi
    
    mkdir -p "$AGENTS_CONFIG_DIR"
    
    # Create agent registry file
    cat > "$AGENTS_CONFIG_DIR/registry.json" <<'JSON'
{
  "version": "1.0.0",
  "agents": {
    "claude": {
      "name": "Claude CLI",
      "vendor": "Anthropic",
      "configPath": "~/.claude/settings.json",
      "executable": "claude",
      "installed": false,
      "version": null
    },
    "gemini": {
      "name": "Gemini CLI",
      "vendor": "Google",
      "configPath": "~/.gemini/settings.json",
      "executable": "gemini",
      "installed": false,
      "version": null
    },
    "grok": {
      "name": "Grok CLI",
      "vendor": "xAI",
      "configPath": "~/.grok/user-settings.json",
      "executable": "grok",
      "installed": false,
      "version": null
    },
    "codex": {
      "name": "Codex CLI",
      "vendor": "OpenAI",
      "configPath": "~/.codex/config.yaml",
      "executable": "codex",
      "installed": false,
      "version": null
    }
  },
  "defaultAgent": "claude",
  "lastUpdated": null
}
JSON
    
    # Update registry with installed agents
    update_agent_registry
    
    log_success "Agent registry created at: $AGENTS_CONFIG_DIR/registry.json"
}

update_agent_registry() {
    local registry_file="$AGENTS_CONFIG_DIR/registry.json"
    
    if [[ ! -f "$registry_file" ]]; then
        return
    fi
    
    # Check which agents are installed
    local temp_file="/tmp/registry_update.json"
    cp "$registry_file" "$temp_file"
    
    # Update Claude status
    if command -v claude >/dev/null 2>&1; then
        local claude_version=$(claude --version 2>/dev/null | head -1 || echo "unknown")
        jq '.agents.claude.installed = true | .agents.claude.version = "'$claude_version'"' "$temp_file" > "$temp_file.new"
        mv "$temp_file.new" "$temp_file"
    fi
    
    # Update Gemini status
    if command -v gemini >/dev/null 2>&1; then
        local gemini_version=$(gemini --version 2>/dev/null | head -1 || echo "unknown")
        jq '.agents.gemini.installed = true | .agents.gemini.version = "'$gemini_version'"' "$temp_file" > "$temp_file.new"
        mv "$temp_file.new" "$temp_file"
    fi
    
    # Update Grok status
    if command -v grok >/dev/null 2>&1; then
        local grok_version=$(grok --version 2>/dev/null | head -1 || echo "unknown")
        jq '.agents.grok.installed = true | .agents.grok.version = "'$grok_version'"' "$temp_file" > "$temp_file.new"
        mv "$temp_file.new" "$temp_file"
    fi
    
    # Update Codex status
    if command -v codex >/dev/null 2>&1; then
        local codex_version=$(codex --version 2>/dev/null | head -1 || echo "unknown")
        jq '.agents.codex.installed = true | .agents.codex.version = "'$codex_version'"' "$temp_file" > "$temp_file.new"
        mv "$temp_file.new" "$temp_file"
    fi
    
    # Update timestamp
    jq '.lastUpdated = "'$(date -Iseconds)'"' "$temp_file" > "$temp_file.new"
    mv "$temp_file.new" "$registry_file"
    
    rm -f "$temp_file" "$temp_file.new"
}

# ============================================================================
# Summary Display
# ============================================================================

show_summary() {
    echo ""
    log_header "Agent Setup Complete"
    echo ""
    
    echo "Configured locations:"
    echo "  • ~/.claude/settings.json       - Claude global settings"
    echo "  • ~/.gemini/settings.json       - Gemini global settings"
    echo "  • ~/.grok/user-settings.json    - Grok global settings"
    echo "  • ~/.codex/config.yaml          - Codex global settings"
    echo "  • ~/templates/agent-setup/      - Repository templates"
    echo "  • ~/.devpilot/agents/           - Agent registry"
    echo ""
    
    echo "Next steps:"
    echo "  1. Set your API keys:"
    echo "     export ANTHROPIC_API_KEY='your-key'"
    echo "     export GEMINI_API_KEY='your-key'"
    echo "     export XAI_API_KEY='your-key'"
    echo "     export OPENAI_API_KEY='your-key'"
    echo ""
    echo "  2. Configure agents in a repository:"
    echo "     cd <your-repo>"
    echo "     devpilot pilot repo-setup"
    echo ""
    echo "  3. Verify agent installations:"
    echo "     devpilot insights audit --agents"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)
                FORCE_INSTALL=true
                shift
                ;;
            --skip-templates)
                SKIP_TEMPLATES=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                ;;
        esac
    done
    
    log_header "DevPilot Agent Setup"
    echo ""
    
    # Setup each agent
    setup_claude
    setup_gemini
    setup_grok
    setup_codex
    
    # Create template files
    create_templates
    
    # Setup agent registry
    setup_agent_registry
    
    # Show summary
    if ! $DRY_RUN; then
        show_summary
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi