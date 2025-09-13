#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# SoftSensorAI user-specific setup (for multi-user installations)
# Run as regular user to configure personal settings
set -euo pipefail

# ============================================================================
# User Setup Script for Multi-User SoftSensorAI
# ============================================================================
# This script configures SoftSensorAI for an individual user when SoftSensorAI
# is already installed system-wide (via multi_user_setup.sh)
# ============================================================================

# Load shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/sh/common.sh"

USER_DIR="${SOFTSENSORAI_USER_DIR:-$HOME/.softsensorai}"
SYSTEM_DIR="${SOFTSENSORAI_ROOT:-/opt/softsensorai}"

# Check if system installation exists
check_system_install() {
    if [[ ! -d "$SYSTEM_DIR" ]]; then
        error "SoftSensorAI is not installed system-wide"
        echo "Please ask your system administrator to run:"
        echo "  sudo /path/to/multi_user_setup.sh"
        exit 1
    fi

    if [[ ! -x "$SYSTEM_DIR/bin/ssai" ]] && [[ ! -x "/usr/local/bin/ssai" ]]; then
        error "SoftSensorAI binary not found"
        echo "System installation may be incomplete"
        exit 1
    fi
}

# Initialize user directory
init_user_dir() {
    info "Initializing SoftSensorAI for user: $USER"

    # Check if already initialized
    if [[ -d "$USER_DIR" ]] && [[ -f "$USER_DIR/config/settings.json" ]]; then
        warn "SoftSensorAI already initialized for this user"
        if ! confirm "Reinitialize? This will backup existing config"; then
            echo "Keeping existing configuration"
            return 0
        fi

        # Backup existing configuration
        backup "$USER_DIR"
        success "Existing config backed up"
    fi

    # Create user directories
    ensure_dir "$USER_DIR"/{config,cache,artifacts,workspace,logs}
    ensure_dir "$USER_DIR"/config/{personas,commands,projects}

    success "User directories created"
}

# Configure user settings
configure_settings() {
    info "Configuring user settings..."

    # Detect skill level
    echo "Select your skill level:"
    echo "  1) l1 - Beginner (learning to code)"
    echo "  2) l2 - Intermediate (can build features)"
    echo "  3) l3 - Expert (can architect systems)"
    echo "  4) l4 - Architect (can design platforms)"
    read -p "Choice [1-4]: " skill_choice

    case "$skill_choice" in
        1) SKILL="l1" ;;
        2) SKILL="l2" ;;
        3) SKILL="l3" ;;
        4) SKILL="l4" ;;
        *) SKILL="l2" ;;
    esac

    # Detect project phase preference
    echo ""
    echo "Default project phase:"
    echo "  1) poc - Proof of Concept"
    echo "  2) mvp - Minimum Viable Product"
    echo "  3) beta - Beta/Testing"
    echo "  4) scale - Production/Scale"
    read -p "Choice [1-4]: " phase_choice

    case "$phase_choice" in
        1) PHASE="poc" ;;
        2) PHASE="mvp" ;;
        3) PHASE="beta" ;;
        4) PHASE="scale" ;;
        *) PHASE="mvp" ;;
    esac

    # Detect preferred AI provider
    echo ""
    echo "Preferred AI provider:"
    echo "  1) anthropic - Claude (recommended)"
    echo "  2) openai - GPT/Codex"
    echo "  3) google - Gemini"
    echo "  4) grok - X.AI Grok"
    echo "  5) auto - Auto-detect available"
    read -p "Choice [1-5]: " ai_choice

    case "$ai_choice" in
        1) AI_PROVIDER="anthropic" ;;
        2) AI_PROVIDER="openai" ;;
        3) AI_PROVIDER="google" ;;
        4) AI_PROVIDER="grok" ;;
        5) AI_PROVIDER="auto" ;;
        *) AI_PROVIDER="auto" ;;
    esac

    # Create user settings
    cat > "$USER_DIR/config/settings.json" <<EOF
{
  "user": "$USER",
  "created": "$(date -Iseconds)",
  "version": "1.0.0",
  "preferences": {
    "skill_level": "$SKILL",
    "project_phase": "$PHASE",
    "ai_provider": "$AI_PROVIDER",
    "editor": "${EDITOR:-vim}",
    "shell": "${SHELL:-/bin/bash}"
  },
  "paths": {
    "system_root": "$SYSTEM_DIR",
    "user_dir": "$USER_DIR",
    "artifacts": "$USER_DIR/artifacts",
    "cache": "$USER_DIR/cache",
    "workspace": "$USER_DIR/workspace"
  },
  "features": {
    "sandbox_enabled": true,
    "audit_enabled": true,
    "telemetry_enabled": false,
    "auto_update": false
  },
  "limits": {
    "max_artifacts_mb": 1000,
    "max_cache_mb": 500,
    "max_concurrent_agents": 3
  }
}
EOF

    success "Settings configured"
}

# Set up API keys
setup_api_keys() {
    info "Setting up API keys..."

    # Create API keys template
    cat > "$USER_DIR/config/api_keys.env" <<'EOF'
# SoftSensorAI API Keys (Personal)
# Fill in your API keys below
# Run 'ssai secure-keys' to encrypt this file after configuration

# AI Providers (at least one required)
ANTHROPIC_API_KEY=""
OPENAI_API_KEY=""
GEMINI_API_KEY=""
GROK_API_KEY=""

# Version Control (recommended)
GITHUB_TOKEN=""
GITLAB_TOKEN=""
BITBUCKET_TOKEN=""

# Cloud Providers (optional)
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_REGION="us-east-1"

AZURE_CLIENT_ID=""
AZURE_CLIENT_SECRET=""
AZURE_TENANT_ID=""

GCP_PROJECT_ID=""
GCP_SERVICE_ACCOUNT_KEY=""

# Other Services (optional)
DOCKER_REGISTRY_TOKEN=""
JIRA_API_TOKEN=""
SLACK_BOT_TOKEN=""
EOF

    # Set secure permissions
    chmod 600 "$USER_DIR/config/api_keys.env"

    warn "API keys file created: $USER_DIR/config/api_keys.env"
    echo "    Please edit this file and add your API keys"
    echo "    Then run: ssai secure-keys"
}

# Create personal personas
setup_personas() {
    info "Setting up personal personas..."

    # Create a default personal persona based on skill level
    cat > "$USER_DIR/config/personas/default.json" <<EOF
{
  "name": "default",
  "description": "Personal default persona for $USER",
  "skill_level": "$SKILL",
  "preferences": {
    "verbosity": "concise",
    "explanation_depth": "$([ "$SKILL" = "l1" ] && echo "detailed" || echo "moderate")",
    "code_style": "clean",
    "testing": "$([ "$PHASE" = "scale" ] && echo "comprehensive" || echo "essential")"
  },
  "focus_areas": [
    "code_quality",
    "best_practices",
    "security"
  ],
  "active": true
}
EOF

    success "Personal personas configured"
}

# Set up shell integration
setup_shell_integration() {
    info "Setting up shell integration..."

    # Detect shell
    SHELL_NAME=$(basename "$SHELL")
    RC_FILE=""

    case "$SHELL_NAME" in
        bash)  RC_FILE="$HOME/.bashrc" ;;
        zsh)   RC_FILE="$HOME/.zshrc" ;;
        fish)  RC_FILE="$HOME/.config/fish/config.fish" ;;
        *)     RC_FILE="$HOME/.profile" ;;
    esac

    # Check if already configured
    if grep -q "SOFTSENSORAI_USER_DIR" "$RC_FILE" 2>/dev/null; then
        warn "Shell integration already configured"
        return 0
    fi

    # Add SoftSensorAI configuration
    cat >> "$RC_FILE" <<'EOF'

# SoftSensorAI configuration
export SOFTSENSORAI_USER_DIR="$HOME/.softsensorai"
export SOFTSENSORAI_ROOT="/opt/softsensorai"

# Aliases
alias ssaip='ssai palette'
alias ssair='ssai review'
alias ssaia='ssai agent'
alias ssaii='ssai init'

# Auto-load project settings when entering a directory
softsensorai_auto_load() {
    if [[ -f "softsensorai.project.yml" ]] || [[ -f ".softsensorai.yml" ]]; then
        if [[ -z "$SOFTSENSORAI_PROJECT_LOADED" ]]; then
            echo "📂 SoftSensorAI project detected. Run 'ssai init' to configure."
            export SOFTSENSORAI_PROJECT_LOADED=1
        fi
    else
        unset SOFTSENSORAI_PROJECT_LOADED
    fi
}

# Hook into cd command
if [[ -n "$BASH_VERSION" ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}softsensorai_auto_load"
elif [[ -n "$ZSH_VERSION" ]]; then
    precmd_functions+=(softsensorai_auto_load)
fi
EOF

    success "Shell integration added to: $RC_FILE"
    echo "    Run: source $RC_FILE"
}

# Create workspace examples
create_examples() {
    info "Creating example workspace..."

    # Create example project
    ensure_dir "$USER_DIR/workspace/example-project"

    cat > "$USER_DIR/workspace/example-project/softsensorai.project.yml" <<EOF
# SoftSensorAI Project Configuration Example
name: example-project
description: Example project for $USER

# Project settings
skill: $SKILL
phase: $PHASE

# AI preferences
ai:
  provider: $AI_PROVIDER
  model: auto
  temperature: 0.7

# Personas to activate
personas:
  - default
  - code-reviewer

# Custom commands
commands:
  test: "npm test"
  build: "npm run build"
  deploy: "npm run deploy"
EOF

    cat > "$USER_DIR/workspace/example-project/README.md" <<EOF
# Example SoftSensorAI Project

This is an example project showing SoftSensorAI configuration.

## Quick Start

1. \`cd $USER_DIR/workspace/example-project\`
2. \`ssai init\` - Initialize SoftSensorAI for this project
3. \`ssai review\` - Review any changes
4. \`ssai agent new "Add a new feature"\` - Create an agent task
5. \`ssai palette\` - Browse all commands

## Your Settings

- Skill Level: $SKILL
- Project Phase: $PHASE
- AI Provider: $AI_PROVIDER
EOF

    success "Example workspace created"
}

# Print summary
print_summary() {
    echo ""
    echo "============================================"
    echo "  SoftSensorAI User Setup Complete!"
    echo "============================================"
    echo ""
    echo "Configuration location: $USER_DIR"
    echo "System installation: $SYSTEM_DIR"
    echo ""
    echo "Your settings:"
    echo "  Skill Level: $SKILL"
    echo "  Project Phase: $PHASE"
    echo "  AI Provider: $AI_PROVIDER"
    echo ""
    echo "Next steps:"
    echo "1. Edit your API keys:"
    echo "   vi $USER_DIR/config/api_keys.env"
    echo ""
    echo "2. Encrypt your keys:"
    echo "   ssai secure-keys"
    echo ""
    echo "3. Source your shell config:"
    echo "   source $RC_FILE"
    echo ""
    echo "4. Try the example project:"
    echo "   cd $USER_DIR/workspace/example-project"
    echo "   ssai init"
    echo ""
    echo "Useful aliases now available:"
    echo "  ssaip - ssai palette (command browser)"
    echo "  ssair - ssai review (code review)"
    echo "  ssaia - ssai agent (AI agent)"
    echo "  ssaii - ssai init (initialize project)"
    echo ""
    success "You're ready to use SoftSensorAI!"
}

# Main flow
main() {
    echo "============================================"
    echo "  SoftSensorAI User Setup"
    echo "============================================"
    echo ""

    check_system_install
    init_user_dir
    configure_settings
    setup_api_keys
    setup_personas
    setup_shell_integration
    create_examples
    print_summary
}

# Run main
main "$@"
