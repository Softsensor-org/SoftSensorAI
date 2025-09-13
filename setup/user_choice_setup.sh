#!/usr/bin/env bash
# Simple project setup - asks user where they want things
set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

say() { echo -e "${BLUE}→${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }

main() {
    local url="${1:-}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  SoftSensorAI Project Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # If we're already in a git repo, just add AI configs
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        say "You're already in a git repository: $(basename $(git rev-parse --show-toplevel))"
        read -p "Add AI configurations here? (Y/n): " confirm
        if [[ ! "$confirm" =~ ^[Nn] ]]; then
            setup_ai_configs "."
            success "AI configurations added to current project!"
        fi
        return
    fi

    # Get URL if not provided
    if [[ -z "$url" ]]; then
        echo "Enter GitHub repository URL (or press Enter to skip):"
        read -p "> " url
    fi

    # If no URL, exit
    if [[ -z "$url" ]]; then
        say "No repository URL provided. Exiting."
        exit 0
    fi

    # Extract repository name
    local repo_name=$(basename -s .git "${url##*/}")

    # Ask user where to clone
    echo ""
    echo "Where do you want to clone '$repo_name'?"
    echo "1) Current directory ($(pwd))"
    echo "2) ~/projects/$repo_name"
    echo "3) Custom location"
    read -p "Choose (1-3) [1]: " choice

    local target_dir=""
    case "${choice:-1}" in
        1) target_dir="$(pwd)/$repo_name" ;;
        2)
            mkdir -p ~/projects
            target_dir="$HOME/projects/$repo_name"
            ;;
        3)
            read -p "Enter full path: " target_dir
            mkdir -p "$(dirname "$target_dir")"
            ;;
        *) target_dir="$(pwd)/$repo_name" ;;
    esac

    # Clone repository
    say "Cloning to: $target_dir"
    if git clone "$url" "$target_dir"; then
        success "Repository cloned!"

        # Add AI configurations
        setup_ai_configs "$target_dir"
        success "AI configurations added!"

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        success "Setup complete!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Next: cd $target_dir"
        echo "Then: ssai review, ssai tickets, etc."
    else
        warn "Clone failed. Check the URL and your GitHub access."
    fi
}

setup_ai_configs() {
    local project_dir="$1"

    # Create minimal CLAUDE.md
    cat > "$project_dir/CLAUDE.md" <<'EOF'
# AI Assistant Configuration

## Project Guidelines
- Keep changes small and focused
- Run tests before committing
- Never read or modify .env files or secrets/

## Available Commands
- `ssai review` - AI code review
- `ssai tickets` - Generate tickets from code
EOF

    # Create .claude directory and settings
    mkdir -p "$project_dir/.claude"
    cat > "$project_dir/.claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit", "MultiEdit", "Read", "Grep", "Glob",
      "Bash(git:*)", "Bash(npm:*)", "Bash(python:*)"
    ],
    "ask": ["WebFetch"],
    "deny": ["Read(./.env*)", "Read(./secrets/**)"]
  }
}
JSON
}

main "$@"