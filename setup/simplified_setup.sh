#!/usr/bin/env bash
set -euo pipefail

# Simplified setup with smart defaults and minimal questions
# Usage: softsensorai setup [URL] [--advanced]

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

say() { printf "${CYAN}→ %s${NC}\n" "$*"; }
success() { printf "${GREEN}✓ %s${NC}\n" "$*"; }
warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*"; }
err() { printf "${RED}✗ %s${NC}\n" "$*" >&2; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_ROOT="$(dirname "$SCRIPT_DIR")"

# Smart defaults
BASE="${SOFTSENSORAI_BASE:-$HOME/projects}"
DEFAULT_ORG="${SOFTSENSORAI_ORG:-default}"
DEFAULT_PROFILE_SKILL="l2"
DEFAULT_PROFILE_PHASE="mvp"

# Parse arguments
URL="${1:-}"
ADVANCED=0
[[ "${2:-}" == "--advanced" ]] && ADVANCED=1

# Helper functions
is_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Removed detect_repo_type - not needed without categories

extract_repo_name() {
    local url="$1"
    basename -s .git "${url##*/}"
}

extract_org_from_url() {
    local url="$1"
    if [[ "$url" =~ github\.com[:/]([^/]+)/ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "$DEFAULT_ORG"
    fi
}

setup_repo_configs() {
    local repo_path="$1"
    
    # Create directories
    mkdir -p "$repo_path/.claude"
    mkdir -p "$repo_path/.codex"
    
    # Copy templates - use actual locations
    [ -f "$SETUP_ROOT/templates/CLAUDE.md" ] && cp -n "$SETUP_ROOT/templates/CLAUDE.md" "$repo_path/" 2>/dev/null || true
    [ -f "$SETUP_ROOT/.claude/settings.json" ] && cp -n "$SETUP_ROOT/.claude/settings.json" "$repo_path/.claude/" 2>/dev/null || true
    
    # Copy command sets if available
    if [ -d "$SETUP_ROOT/.claude/commands/sets" ]; then
        mkdir -p "$repo_path/.claude/commands"
        cp -r "$SETUP_ROOT/.claude/commands/sets" "$repo_path/.claude/commands/" 2>/dev/null || true
    fi
    
    # Apply default profile silently (remove --quiet as it's not supported)
    if [ -f "$SETUP_ROOT/scripts/apply_profile.sh" ]; then
        (cd "$repo_path" && "$SETUP_ROOT/scripts/apply_profile.sh" --skill "$DEFAULT_PROFILE_SKILL" --phase "$DEFAULT_PROFILE_PHASE" >/dev/null 2>&1 || true)
    fi
    
    # Install git hooks silently
    if [ -d "$repo_path/.git" ]; then
        mkdir -p "$repo_path/.githooks"
        cat > "$repo_path/.githooks/commit-msg" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
MSG="$1"
# Remove Claude/AI signatures
sed -i'' -e '/Generated with \[Claude Code\]/d' "$MSG" 2>/dev/null || true
sed -i'' -e '/Co-Authored-By:.*Claude/d' "$MSG" 2>/dev/null || true
exit 0
HOOK
        chmod +x "$repo_path/.githooks/commit-msg"
        (cd "$repo_path" && git config core.hooksPath .githooks 2>/dev/null || true)
    fi
}

bootstrap_dependencies() {
    local repo_path="$1"
    cd "$repo_path"
    
    # Node.js
    if [ -f package.json ]; then
        if command -v pnpm >/dev/null 2>&1; then
            pnpm install --silent 2>/dev/null || true
        else
            npm install --silent 2>/dev/null || true
        fi
    fi
    
    # Python
    if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
        if command -v uv >/dev/null 2>&1; then
            uv venv .venv 2>/dev/null || python3 -m venv .venv
            .venv/bin/pip install -q -r requirements.txt 2>/dev/null || true
        else
            python3 -m venv .venv 2>/dev/null || true
            .venv/bin/pip install -q -r requirements.txt 2>/dev/null || true
        fi
    fi
}

# Main flow
main() {
    echo -e "${BOLD}${BLUE}🚀 SoftSensorAI Quick Setup${NC}\n"
    
    # Check if we're in an existing repo
    if [ -z "$URL" ] && is_git_repo; then
        local repo_name=$(basename "$(git rev-parse --show-toplevel)")
        say "Detected repository: ${BOLD}$repo_name${NC}"
        
        read -p "Add SoftSensorAI configurations here? (Y/n): " confirm
        if [[ ! "$confirm" =~ ^[Nn] ]]; then
            setup_repo_configs "."
            success "Repository configured!"
            echo -e "\n${BOLD}Next:${NC} Start coding with your AI assistant"
        fi
        exit 0
    fi
    
    # If no URL provided, ask for it
    if [ -z "$URL" ]; then
        echo -e "${BOLD}Enter GitHub URL${NC} (or 'local' for current directory):"
        read -p "> " URL
        [ -z "$URL" ] && { err "No URL provided"; exit 1; }
    fi
    
    # Handle local directory
    if [[ "$URL" == "local" ]]; then
        if [ -f package.json ] || [ -f requirements.txt ] || [ -f pyproject.toml ]; then
            setup_repo_configs "."
            success "Local repository configured!"
        else
            err "Current directory doesn't appear to be a project"
        fi
        exit 0
    fi
    
    # Multiple repos detection (if user pastes multiple lines)
    URLS=("$URL")
    if [ -t 0 ]; then  # Only ask if interactive
        echo -e "\nAdditional URLs? ${CYAN}(empty line to continue)${NC}"
        while true; do
            read -p "> " extra_url
            [ -z "$extra_url" ] && break
            URLS+=("$extra_url")
        done
    fi
    
    # Process repositories
    if [ ${#URLS[@]} -gt 1 ]; then
        # Multiple repos = project setup
        say "Setting up project with ${#URLS[@]} repositories..."
        
        # Extract project name from first repo
        local first_repo=$(extract_repo_name "${URLS[0]}")
        local project_name="${first_repo%-*}"  # Remove suffix like -api, -ui
        local org=$(extract_org_from_url "${URLS[0]}")
        
        # Create project structure
        local project_path="$BASE/$org/$project_name"
        mkdir -p "$project_path"
        
        # Clone each repo
        for url in "${URLS[@]}"; do
            local repo_name=$(extract_repo_name "$url")
            say "Cloning $repo_name..."
            
            cd "$project_path"
            git clone -q "$url" "$repo_name" 2>/dev/null || { warn "Failed to clone $url"; continue; }
            
            setup_repo_configs "$project_path/$repo_name"
            bootstrap_dependencies "$project_path/$repo_name" &
        done
        
        wait  # Wait for all background bootstraps
        
        success "Project setup complete!"
        echo -e "\n${BOLD}Location:${NC} $project_path"
        echo -e "${BOLD}Open in VS Code:${NC} code \"$project_path\""
        
    else
        # Single repo setup
        local repo_name=$(extract_repo_name "$URL")
        local org=$(extract_org_from_url "$URL")
        
        say "Setting up: ${BOLD}$repo_name${NC}"
        
        # Simple structure: org/repo_name (no categories!)
        local target="$BASE/$org/$repo_name"
        mkdir -p "$BASE/$org"
        
        # Clone
        say "Cloning repository..."
        cd "$BASE/$org"
        if ! git clone -q "$URL" "$repo_name" 2>/dev/null; then
            err "Failed to clone $URL"
            err "Please check the URL and your SSH keys"
            exit 1
        fi
        
        # Configure
        setup_repo_configs "$target"
        
        # Bootstrap
        say "Installing dependencies..."
        bootstrap_dependencies "$target"
        
        success "Repository ready!"
        echo -e "\n${BOLD}Location:${NC} $target"
        echo -e "${BOLD}Open in VS Code:${NC} code \"$target\""
    fi
    
    # Advanced options (only if requested)
    if [ $ADVANCED -eq 1 ]; then
        echo -e "\n${YELLOW}Advanced options available:${NC}"
        echo "  • Change profile: cd <repo> && $SETUP_ROOT/scripts/profile_menu.sh"
        echo "  • View settings: cat <repo>/CLAUDE.md"
    fi
}

# Run
main