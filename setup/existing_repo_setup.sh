#!/usr/bin/env bash
# Setup script for existing repositories - adds agent configurations without cloning
set -euo pipefail

# Colors and helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

say(){ printf "${CYAN}==> %s${NC}\n" "$*"; }
warn(){ printf "${YELLOW}[warn]${NC} %s\n" "$*"; }
err(){ printf "${RED}[err]${NC} %s\n" "$*"; }
success(){ printf "${GREEN}✓ %s${NC}\n" "$*"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")"

# Check if current directory is a git repo
is_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Check if directory has a project structure
has_project_structure() {
  local dir="${1:-.}"
  [ -f "$dir/package.json" ] || [ -f "$dir/requirements.txt" ] || [ -f "$dir/pyproject.toml" ] || \
  [ -f "$dir/Makefile" ] || [ -f "$dir/Cargo.toml" ] || [ -f "$dir/go.mod" ] || \
  [ -d "$dir/.git" ] || [ -f "$dir/README.md" ]
}

# Detect project type
detect_project_type() {
  local dir="${1:-.}"
  local types=()

  [ -f "$dir/package.json" ] && types+=("Node.js")
  [ -f "$dir/requirements.txt" ] || [ -f "$dir/pyproject.toml" ] && types+=("Python")
  [ -f "$dir/Cargo.toml" ] && types+=("Rust")
  [ -f "$dir/go.mod" ] && types+=("Go")
  [ -f "$dir/Gemfile" ] && types+=("Ruby")
  [ -f "$dir/pom.xml" ] || [ -f "$dir/build.gradle" ] && types+=("Java")
  [ -f "$dir/composer.json" ] && types+=("PHP")

  if [ ${#types[@]} -gt 0 ]; then
    echo "${types[*]}"
  else
    echo "Unknown"
  fi
}

# Copy agent configurations
setup_agent_configs() {
  local target_dir="$1"

  say "Setting up agent configurations..."

  # Create .claude directory
  mkdir -p "$target_dir/.claude"

  # Copy CLAUDE.md template
  if [ ! -f "$target_dir/CLAUDE.md" ]; then
    if [ -f "$SETUP_SCRIPTS_DIR/templates/CLAUDE.md" ]; then
      cp "$SETUP_SCRIPTS_DIR/templates/CLAUDE.md" "$target_dir/CLAUDE.md"
      success "Created CLAUDE.md"
    fi
  else
    warn "CLAUDE.md already exists, skipping"
  fi

  # Copy CODEX.md template
  if [ ! -f "$target_dir/CODEX.md" ]; then
    if [ -f "$SETUP_SCRIPTS_DIR/templates/CODEX.md" ]; then
      cp "$SETUP_SCRIPTS_DIR/templates/CODEX.md" "$target_dir/CODEX.md"
      success "Created CODEX.md"
    fi
  else
    warn "CODEX.md already exists, skipping"
  fi

  # Copy settings
  if [ ! -f "$target_dir/.claude/settings.json" ]; then
    if [ -f "$SETUP_SCRIPTS_DIR/templates/.claude/settings.json" ]; then
      cp "$SETUP_SCRIPTS_DIR/templates/.claude/settings.json" "$target_dir/.claude/settings.json"
      success "Created .claude/settings.json"
    fi
  else
    warn ".claude/settings.json already exists, skipping"
  fi

  # Copy command sets for Claude
  if [ -d "$SETUP_SCRIPTS_DIR/.claude/commands/sets" ]; then
    mkdir -p "$target_dir/.claude/commands"
    cp -r "$SETUP_SCRIPTS_DIR/.claude/commands/sets" "$target_dir/.claude/commands/"
    success "Copied Claude command sets"
  fi

  # Setup Codex directory and settings
  mkdir -p "$target_dir/.codex"
  if [ -f "$SETUP_SCRIPTS_DIR/.codex/settings.json" ]; then
    cp "$SETUP_SCRIPTS_DIR/.codex/settings.json" "$target_dir/.codex/settings.json"
    success "Created Codex settings"
  fi

  # Copy Codex commands if they exist
  if [ -d "$SETUP_SCRIPTS_DIR/.codex/commands" ]; then
    cp -r "$SETUP_SCRIPTS_DIR/.codex/commands" "$target_dir/.codex/"
    success "Copied Codex command sets"
  fi

  # Create system prompts directory
  mkdir -p "$target_dir/system"
  if [ -d "$SETUP_SCRIPTS_DIR/templates/system" ]; then
    for file in "$SETUP_SCRIPTS_DIR/templates/system"/*.md; do
      [ -f "$file" ] && cp -n "$file" "$target_dir/system/" 2>/dev/null || true
    done
    success "Created system prompts"
  fi
}

# Apply profile
apply_profile() {
  local target_dir="$1"
  local skill="${2:-}"
  local phase="${3:-}"

  if [ -n "$skill" ] || [ -n "$phase" ]; then
    say "Applying profile configuration..."
    cd "$target_dir"

    local profile_args=""
    [ -n "$skill" ] && profile_args="$profile_args --skill $skill"
    [ -n "$phase" ] && profile_args="$profile_args --phase $phase"

    if [ -f "$SETUP_SCRIPTS_DIR/scripts/apply_profile.sh" ]; then
      "$SETUP_SCRIPTS_DIR/scripts/apply_profile.sh" $profile_args
    fi
  fi
}

# Main interactive flow
main() {
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║        ${BOLD}🔧 Setup for Existing Repository 🔧${NC}${CYAN}                ║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo

  # Check current directory first
  local target_dir=""
  local current_is_repo=false

  if is_git_repo && has_project_structure "."; then
    current_is_repo=true
    local repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    echo -e "${GREEN}✓ Current directory is a repository: $repo_name${NC}"
    echo
    read -p "Setup agent configurations here? (y/n): " use_current

    if [[ "$use_current" =~ ^[Yy] ]]; then
      target_dir="."
    fi
  fi

  # If not using current directory, ask for path
  if [ -z "$target_dir" ]; then
    echo -e "${BLUE}Enter the path to your existing repository:${NC}"
    read -p "Repository path (or press Enter to browse): " repo_path

    if [ -z "$repo_path" ]; then
      # Browse for repository
      echo
      echo -e "${YELLOW}Looking for repositories...${NC}"

      # Search common locations
      local search_dirs=("$HOME/projects" "$HOME/repos" "$HOME/dev" "$HOME/code" "$HOME/workspace")
      local found_repos=()

      for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
          while IFS= read -r -d '' repo; do
            found_repos+=("$repo")
          done < <(find "$dir" -maxdepth 3 -type d -name ".git" -print0 2>/dev/null | xargs -0 -I {} dirname {} | head -20 | tr '\n' '\0')
        fi
      done

      if [ ${#found_repos[@]} -gt 0 ]; then
        echo -e "${GREEN}Found ${#found_repos[@]} repositories:${NC}"
        echo

        PS3="Select repository (or 0 to enter path manually): "
        select repo in "${found_repos[@]}"; do
          if [ -n "$repo" ]; then
            target_dir="$repo"
            break
          elif [ "$REPLY" = "0" ]; then
            read -p "Enter repository path: " target_dir
            break
          fi
        done
      else
        warn "No repositories found in common locations"
        read -p "Enter repository path: " target_dir
      fi
    else
      target_dir="$repo_path"
    fi
  fi

  # Validate target directory
  if [ ! -d "$target_dir" ]; then
    err "Directory does not exist: $target_dir"
    exit 1
  fi

  # Expand to absolute path
  target_dir="$(cd "$target_dir" && pwd)"

  # Check if it's a valid project
  if ! has_project_structure "$target_dir"; then
    warn "Directory doesn't appear to be a project repository"
    read -p "Continue anyway? (y/n): " cont
    [[ "$cont" =~ ^[Yy] ]] || exit 1
  fi

  # Detect project type
  echo
  say "Analyzing repository..."
  local project_type=$(detect_project_type "$target_dir")
  echo -e "  ${BOLD}Repository:${NC} $(basename "$target_dir")"
  echo -e "  ${BOLD}Path:${NC} $target_dir"
  echo -e "  ${BOLD}Type:${NC} $project_type"

  if is_git_repo; then
    local branch=$(cd "$target_dir" && git branch --show-current 2>/dev/null || echo "unknown")
    echo -e "  ${BOLD}Branch:${NC} $branch"
  fi
  echo

  # Check existing setup
  local has_claude=false
  if [ -f "$target_dir/CLAUDE.md" ] || [ -d "$target_dir/.claude" ]; then
    has_claude=true
    warn "Repository already has agent configurations"
    echo "  • CLAUDE.md: $([ -f "$target_dir/CLAUDE.md" ] && echo "✓" || echo "✗")"
    echo "  • .claude/: $([ -d "$target_dir/.claude" ] && echo "✓" || echo "✗")"
    echo
    read -p "Update/overwrite existing configurations? (y/n): " update
    [[ "$update" =~ ^[Yy] ]] || exit 0
  fi

  # Setup configurations
  setup_agent_configs "$target_dir"

  # Ask about profile
  echo
  echo -e "${BLUE}${BOLD}Configure AI assistant profile?${NC}"
  echo "This sets permission levels and available commands based on your skill level."
  echo
  read -p "Setup profile now? (y/n): " setup_profile

  if [[ "$setup_profile" =~ ^[Yy] ]]; then
    # Run profile menu
    cd "$target_dir"
    if [ -f "$SETUP_SCRIPTS_DIR/scripts/profile_menu.sh" ]; then
      "$SETUP_SCRIPTS_DIR/scripts/profile_menu.sh"
    fi
  fi

  # Install git hooks
  echo
  read -p "Install commit sanitizer hooks? (y/n): " install_hooks
  if [[ "$install_hooks" =~ ^[Yy] ]]; then
    if [ -f "$SETUP_SCRIPTS_DIR/setup/repo_wizard.sh" ]; then
      cd "$target_dir"
      # Source the functions we need
      source "$SETUP_SCRIPTS_DIR/setup/repo_wizard.sh" --source-only 2>/dev/null || true
      if declare -f install_commit_sanitizer >/dev/null 2>&1; then
        install_commit_sanitizer
        success "Installed git hooks"
      fi
    fi
  fi

  # Summary
  echo
  echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                    ${BOLD}✓ Setup Complete!${NC}${GREEN}                       ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo
  echo -e "${BOLD}Repository configured at:${NC} $target_dir"
  echo
  echo -e "${YELLOW}Next steps:${NC}"
  echo "  1. Review CLAUDE.md for AI assistant instructions"
  echo "  2. Check .claude/settings.json for permissions"
  echo "  3. Run 'scripts/profile_show.sh' to view current profile"
  echo "  4. Start coding with your AI assistant!"
  echo
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
