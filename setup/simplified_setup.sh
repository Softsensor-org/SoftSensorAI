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

# Convert HTTPS URL to SSH format
convert_to_ssh_url() {
    local url="$1"
    if [[ "$url" =~ ^https://github\.com/(.+)$ ]]; then
        echo "git@github.com:${BASH_REMATCH[1]}"
    else
        echo "$url"
    fi
}

# Check GitHub CLI authentication
check_gh_auth() {
    if command -v gh >/dev/null 2>&1; then
        if gh auth status >/dev/null 2>&1; then
            return 0
        else
            warn "GitHub CLI (gh) is installed but not authenticated"
            echo "Run: gh auth login"
            return 1
        fi
    else
        warn "GitHub CLI (gh) not installed. Install it for better GitHub integration"
        echo "Install with: brew install gh (macOS) or apt install gh (Linux)"
        return 1
    fi
}

# Clone repository with fallback methods
clone_repository() {
    local url="$1"
    local target="$2"
    
    # Convert HTTPS to SSH
    local ssh_url=$(convert_to_ssh_url "$url")
    
    # Try SSH first (most reliable for private repos)
    if git clone -q "$ssh_url" "$target" 2>/dev/null; then
        return 0
    fi
    
    # Try gh CLI if available
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
        if [[ "$url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
            local repo="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
            if gh repo clone "$repo" "$target" -- -q 2>/dev/null; then
                return 0
            fi
        fi
    fi
    
    # Last resort: try original URL (will prompt for credentials)
    if git clone -q "$url" "$target" 2>/dev/null; then
        return 0
    fi
    
    return 1
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

setup_project_configs() {
    local project_path="$1"
    shift
    local repo_urls=("$@")
    
    # Create project-level .claude directory
    mkdir -p "$project_path/.claude"
    mkdir -p "$project_path/.codex"
    
    # Create project-level CLAUDE.md
    cat > "$project_path/CLAUDE.md" <<'EOF'
# Project-Level AI Assistant Configuration

This is a multi-repository project. When working from this directory, you have access to all repositories below.

## Project Structure
EOF
    
    # Add repo list to CLAUDE.md
    for url in "${repo_urls[@]}"; do
        local repo_name
        if [[ "$url" == local:* ]]; then
            repo_name="${url#local:}"
        else
            repo_name=$(extract_repo_name "$url")
        fi
        echo "- \`./$repo_name/\` - $(detect_repo_purpose "$repo_name")" >> "$project_path/CLAUDE.md"
    done
    
    cat >> "$project_path/CLAUDE.md" <<'EOF'

## Cross-Repository Operations

When running AI commands from this directory:
- You can analyze code across all repositories
- You can refactor shared interfaces
- You can generate documentation spanning multiple services
- You can find dependencies between services

## Guidelines

1. **Architecture Analysis**: Look at the big picture across all repos
2. **Consistency Checks**: Ensure APIs, types, and patterns match across repos
3. **Dependency Mapping**: Understand how services interact
4. **Global Refactoring**: Make coordinated changes across repos

## Common Tasks

- "Find all API endpoints across all services"
- "Check for version mismatches in shared dependencies"
- "Generate architecture diagram from code"
- "Find all database queries across repos"
- "Standardize error handling across all services"
EOF
    
    # Create project-level settings
    if [ -f "$SETUP_ROOT/.claude/settings.json" ]; then
        cp "$SETUP_ROOT/.claude/settings.json" "$project_path/.claude/"
        # Modify settings for project-level operations
        if command -v jq >/dev/null 2>&1; then
            jq '.env.PROJECT_ROOT = "true" | .env.MULTI_REPO = "true"' \
                "$project_path/.claude/settings.json" > "$project_path/.claude/settings.json.tmp" && \
                mv "$project_path/.claude/settings.json.tmp" "$project_path/.claude/settings.json"
        fi
    fi
    
    # Create PROJECT.json for tracking
    cat > "$project_path/PROJECT.json" <<EOF
{
  "type": "multi-repo",
  "created": "$(date -Iseconds)",
  "repositories": [
EOF
    
    local first=1
    for url in "${repo_urls[@]}"; do
        local repo_name=$(extract_repo_name "$url")
        [[ $first -eq 1 ]] && first=0 || echo "," >> "$project_path/PROJECT.json"
        echo -n "    { \"name\": \"$repo_name\", \"url\": \"$url\" }" >> "$project_path/PROJECT.json"
    done
    
    cat >> "$project_path/PROJECT.json" <<EOF

  ]
}
EOF
}

detect_repo_purpose() {
    local name="$1"
    case "$name" in
        *api*|*backend*|*server*) echo "Backend API service" ;;
        *ui*|*frontend*|*web*|*client*) echo "Frontend application" ;;
        *mobile*|*app*|*ios*|*android*) echo "Mobile application" ;;
        *lib*|*common*|*shared*) echo "Shared library" ;;
        *docs*|*documentation*) echo "Documentation" ;;
        *infra*|*terraform*|*k8s*) echo "Infrastructure" ;;
        *) echo "Service" ;;
    esac
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
    
    # Check GitHub authentication upfront for better UX
    if ! check_gh_auth; then
        echo ""
        warn "GitHub authentication recommended for private repositories"
        echo "You can continue, but may need to enter credentials for each repo"
        echo ""
    fi
    
    # Check current directory context
    if [ -z "$URL" ]; then
        # Check if we're in a git repo
        if is_git_repo; then
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
        
        # Check if we're in a project folder with multiple repos
        local repo_count=$(find . -maxdepth 2 -name ".git" -type d 2>/dev/null | wc -l)
        if [ "$repo_count" -gt 1 ]; then
            say "Detected project folder with ${BOLD}$repo_count repositories${NC}"
            echo "Repositories found:"
            for repo_dir in $(find . -maxdepth 2 -name ".git" -type d 2>/dev/null | xargs -I {} dirname {}); do
                echo "  • $(basename "$repo_dir")"
            done
            
            read -p "Add project-level AI configurations for cross-repo operations? (Y/n): " confirm
            if [[ ! "$confirm" =~ ^[Nn] ]]; then
                # Build URLs array from existing repos
                local fake_urls=()
                for repo_dir in $(find . -maxdepth 2 -name ".git" -type d 2>/dev/null | xargs -I {} dirname {}); do
                    fake_urls+=("local:$(basename "$repo_dir")")
                done
                setup_project_configs "." "${fake_urls[@]}"
                success "Project-level configurations added!"
                echo -e "\n${CYAN}You can now run AI commands from this folder to work across all repos${NC}"
            fi
            exit 0
        fi
    fi
    
    # If no URL provided, ask for it
    if [ -z "$URL" ]; then
        echo -e "${BOLD}Enter GitHub URL${NC} (or 'local' for current directory):"
        echo -e "  ${GREEN}Tip: You can use HTTPS or SSH format${NC}"
        read -p "> " URL
        [ -z "$URL" ] && { err "No URL provided"; exit 1; }
        # Convert HTTPS to SSH for better authentication
        URL=$(convert_to_ssh_url "$URL")
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
            # Convert HTTPS to SSH for better authentication
            extra_url=$(convert_to_ssh_url "$extra_url")
            URLS+=("$extra_url")
        done
    fi
    
    # Process repositories
    if [ ${#URLS[@]} -gt 1 ]; then
        # Multiple repos = project setup
        say "Setting up project with ${#URLS[@]} repositories..."
        
        # For multiple repos, just use org as the project folder
        # Don't create another nested level
        local org=$(extract_org_from_url "${URLS[0]}")
        
        # The project path IS the org path (no extra nesting)
        local project_path="$BASE/$org"
        mkdir -p "$project_path"
        
        # Clone each repo
        for url in "${URLS[@]}"; do
            local repo_name=$(extract_repo_name "$url")
            say "Cloning $repo_name..."
            
            cd "$project_path"
            if ! clone_repository "$url" "$repo_name"; then
                warn "Failed to clone $url"
                warn "Check your SSH keys or GitHub authentication"
                continue
            fi
            
            setup_repo_configs "$project_path/$repo_name"
            bootstrap_dependencies "$project_path/$repo_name" &
        done
        
        wait  # Wait for all background bootstraps
        
        # Add project-level configurations for cross-repo operations
        say "Adding project-level AI configurations..."
        setup_project_configs "$project_path" "${URLS[@]}"
        
        success "Project setup complete!"
        echo -e "\n${BOLD}Location:${NC} $project_path"
        echo -e "${BOLD}Open in VS Code:${NC} code \"$project_path\""
        echo -e "\n${CYAN}Tip:${NC} You can run AI commands from the project folder to work across all repos:"
        echo -e "  cd $project_path"
        echo -e "  claude 'analyze architecture across all services'"
        echo -e "  codex 'find all API endpoints'"
        
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
        if ! clone_repository "$URL" "$repo_name"; then
            err "Failed to clone $URL"
            err "Please check your SSH keys or GitHub authentication"
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