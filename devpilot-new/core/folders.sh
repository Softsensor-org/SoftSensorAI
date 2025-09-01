#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# DevPilot Folder Structure Setup
# Creates standardized directory structure for development projects
# Part of DevPilot: Modern AI-powered development platform
# ============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVPILOT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source core utilities
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/logger.sh"

# Configuration (can be overridden via environment)
ORGS="${DEVPILOT_ORGS:-org1 org2}"
PERSONAL="${DEVPILOT_PERSONAL:-personal}"
PROJECT_BASE="${DEVPILOT_PROJECT_BASE:-$HOME/projects}"
WORKSPACE_BASE="${DEVPILOT_WORKSPACE_BASE:-$HOME/workspaces}"

# Command-line options
DRY_RUN=false
SKIP_WORKSPACES=false
SKIP_TEMPLATES=false

# ============================================================================
# Help and Usage
# ============================================================================

show_help() {
    cat <<EOF
Usage: devpilot core folders [OPTIONS]

Create standardized directory structure for development projects.

Options:
    --orgs           Space-separated list of organization names
    --personal       Name for personal projects folder
    --dry-run        Preview actions without creating directories
    --skip-workspaces Skip VS Code workspace file creation
    --skip-templates Skip template file creation
    --help, -h       Show this help message

Environment Variables:
    DEVPILOT_ORGS       Organization names (default: "org1 org2")
    DEVPILOT_PERSONAL   Personal folder name (default: "personal")
    DEVPILOT_PROJECT_BASE  Base directory for projects (default: ~/projects)

Examples:
    # Default setup
    devpilot core folders

    # Custom organizations
    devpilot core folders --orgs "acme corp startup"

    # Preview structure
    devpilot core folders --dry-run

EOF
    exit 0
}

# ============================================================================
# Directory Creation Functions
# ============================================================================

create_directory() {
    local dir="$1"
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would create: $dir"
        return
    fi
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_success "Created: $dir"
    else
        log_info "Exists: $dir"
    fi
}

create_base_directories() {
    log_step "Creating base directories"
    
    local bases=(
        "$PROJECT_BASE"
        "$WORKSPACE_BASE"
        "$HOME/.devpilot"
        "$HOME/.devpilot/logs"
        "$HOME/.devpilot/backups"
        "$HOME/.devpilot/state"
        "$HOME/.devpilot/cache"
        "$HOME/.devpilot/agents"
        "$HOME/templates"
        "$HOME/templates/agent-setup"
        "$HOME/setup"
        "$HOME/venvs"
        "$HOME/bin"
        "$HOME/data"
        "$HOME/scratch"
        "$HOME/.claude"
        "$HOME/.gemini"
        "$HOME/.grok"
        "$HOME/.codex"
        "$HOME/.ssh"
    )
    
    for dir in "${bases[@]}"; do
        create_directory "$dir"
    done
    
    # Set proper permissions for sensitive directories
    if ! $DRY_RUN; then
        chmod 700 "$HOME/.ssh" 2>/dev/null || true
        chmod 700 "$HOME/.devpilot" 2>/dev/null || true
    fi
}

create_project_structure() {
    local org="$1"
    local base_dir="$PROJECT_BASE/$org"
    
    log_step "Creating project structure for: $org"
    
    # Standard subdirectories for each organization/personal space
    local subdirs=(
        "backend"
        "frontend"
        "mobile"
        "infra"
        "ml"
        "ops"
        "data"
        "docs"
        "sandbox"
        "playground"
        "scripts"
        "tools"
        "experiments"
        "archived"
    )
    
    for subdir in "${subdirs[@]}"; do
        create_directory "$base_dir/$subdir"
    done
    
    # Create README if it doesn't exist
    local readme="$base_dir/README.md"
    if [[ ! -f "$readme" ]] && ! $DRY_RUN; then
        cat > "$readme" <<EOF
# $org Projects

## Directory Structure

- **backend/** - Backend services and APIs
- **frontend/** - Web applications and UIs
- **mobile/** - Mobile applications
- **infra/** - Infrastructure as code and configurations
- **ml/** - Machine learning projects and models
- **ops/** - Operations, monitoring, and tooling
- **data/** - Data pipelines and processing
- **docs/** - Documentation and specifications
- **sandbox/** - Experimental code and prototypes
- **playground/** - Quick tests and snippets
- **scripts/** - Automation and utility scripts
- **tools/** - Development tools and utilities
- **experiments/** - Research and experiments
- **archived/** - Archived projects

## Setup

Projects in this directory are managed by DevPilot.

To initialize a new project:
\`\`\`bash
devpilot project wizard
\`\`\`

To configure AI agents for a project:
\`\`\`bash
cd <project-dir>
devpilot pilot repo-setup
\`\`\`
EOF
        log_success "Created README: $readme"
    fi
}

create_workspace_files() {
    if $SKIP_WORKSPACES; then
        log_info "Skipping workspace file creation (--skip-workspaces)"
        return
    fi
    
    log_step "Creating VS Code workspace files"
    
    local orgs_array=($ORGS)
    local all_orgs=("$PERSONAL" "${orgs_array[@]}")
    
    for org in "${all_orgs[@]}"; do
        local workspace_file="$WORKSPACE_BASE/${org}.code-workspace"
        
        if $DRY_RUN; then
            log_info "[DRY RUN] Would create workspace: $workspace_file"
            continue
        fi
        
        if [[ ! -f "$workspace_file" ]]; then
            cat > "$workspace_file" <<EOF
{
  "folders": [
    {
      "path": "$PROJECT_BASE/$org",
      "name": "$org"
    }
  ],
  "settings": {
    "window.title": "${org^^} — \${activeEditorShort}",
    "npm.packageManager": "pnpm",
    "git.enableCommitSigning": true,
    "files.exclude": {
      "**/.git": false,
      "**/.DS_Store": true,
      "**/node_modules": true,
      "**/__pycache__": true,
      "**/.pytest_cache": true,
      "**/.venv": true
    },
    "search.exclude": {
      "**/node_modules": true,
      "**/bower_components": true,
      "**/*.code-search": true,
      "**/dist": true,
      "**/build": true,
      "**/.venv": true
    },
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.eslint": true,
      "source.organizeImports": true
    },
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": false,
    "python.linting.flake8Enabled": true,
    "typescript.updateImportsOnFileMove.enabled": "always"
  },
  "extensions": {
    "recommendations": [
      "dbaeumer.vscode-eslint",
      "esbenp.prettier-vscode",
      "ms-python.python",
      "ms-python.vscode-pylance",
      "ms-vscode.vscode-typescript-next",
      "github.copilot",
      "github.copilot-chat",
      "eamodio.gitlens",
      "donjayamanne.githistory",
      "streetsidesoftware.code-spell-checker"
    ]
  }
}
EOF
            log_success "Created workspace: $workspace_file"
        else
            log_info "Workspace exists: $workspace_file"
        fi
    done
}

create_template_files() {
    if $SKIP_TEMPLATES; then
        log_info "Skipping template file creation (--skip-templates)"
        return
    fi
    
    log_step "Creating agent template files"
    
    local template_dir="$HOME/templates/agent-setup"
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would create templates in: $template_dir"
        return
    fi
    
    # These are minimal templates - the full ones are created by pilot/agents/setup.sh
    local claude_template="$template_dir/CLAUDE.md"
    if [[ ! -f "$claude_template" ]]; then
        cat > "$claude_template" <<'EOF'
# Project Guardrails for Claude Code

## Core Rules
- Work in small, atomic diffs; always show a unified diff
- Branch per task; reference ticket keys in commits
- Secrets: never read/write `.env` or `secrets/**`; redact tokens
- Output format: plan → diff → tests → results

## Development Flow
1. Understand requirements and acceptance criteria
2. Plan implementation with specific test commands
3. Write minimal code to pass tests
4. Verify with lint, typecheck, and test suite
5. Commit with descriptive message

## Security
- No hardcoded credentials or API keys
- Validate all external inputs
- Use environment variables for configuration
- Review generated code for vulnerabilities
EOF
        log_success "Created template: $claude_template"
    fi
    
    local agents_template="$template_dir/AGENTS.md"
    if [[ ! -f "$agents_template" ]]; then
        cat > "$agents_template" <<'EOF'
# Project Agent Directives

## General Rules
- Start read-only; switch to write mode only with tests passing
- Use conventional commits for all changes
- Open PRs with checklist and ticket reference
- Maintain or improve test coverage

## Agent Selection
- **Claude**: Complex refactoring, architecture, code reviews
- **Gemini**: Data analysis, ML workflows, pattern detection
- **Grok**: Debugging, exploration, quick prototypes
- **Codex**: Code generation, boilerplate, API integration

## Workflow
1. Explore codebase and understand context
2. Plan changes with test-first approach
3. Implement incrementally with verification
4. Document significant changes
5. Ensure CI/CD passes before marking complete
EOF
        log_success "Created template: $agents_template"
    fi
}

# ============================================================================
# Summary Display
# ============================================================================

show_summary() {
    echo ""
    log_header "Folder Structure Created"
    echo ""
    
    # Show tree structure
    if command -v tree >/dev/null 2>&1; then
        echo "Project structure:"
        tree -L 2 "$PROJECT_BASE" 2>/dev/null || {
            echo "Projects created in: $PROJECT_BASE"
            ls -la "$PROJECT_BASE/"
        }
    else
        echo "Projects created in: $PROJECT_BASE"
        find "$PROJECT_BASE" -maxdepth 2 -type d | sed "s|$HOME|~|" | sort
    fi
    
    echo ""
    echo "Workspaces available:"
    local orgs_array=($ORGS)
    local all_orgs=("$PERSONAL" "${orgs_array[@]}")
    for org in "${all_orgs[@]}"; do
        echo "  code $WORKSPACE_BASE/${org}.code-workspace"
    done
    
    echo ""
    echo "Next steps:"
    echo "  1. Open a workspace in VS Code"
    echo "  2. Clone or create projects in the appropriate directories"
    echo "  3. Run 'devpilot pilot repo-setup' in each project"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --orgs)
                ORGS="${2:-}"
                if [[ -z "$ORGS" ]]; then
                    log_error "--orgs requires a value"
                    exit 1
                fi
                shift 2
                ;;
            --personal)
                PERSONAL="${2:-}"
                if [[ -z "$PERSONAL" ]]; then
                    log_error "--personal requires a value"
                    exit 1
                fi
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-workspaces)
                SKIP_WORKSPACES=true
                shift
                ;;
            --skip-templates)
                SKIP_TEMPLATES=true
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
    
    log_header "DevPilot Folder Structure Setup"
    echo ""
    
    if $DRY_RUN; then
        log_info "Running in DRY RUN mode - no changes will be made"
        echo ""
    fi
    
    # Create base directories
    create_base_directories
    
    # Create personal project structure
    create_project_structure "$PERSONAL"
    
    # Create organization project structures
    local orgs_array=($ORGS)
    for org in "${orgs_array[@]}"; do
        create_project_structure "$org"
    done
    
    # Create VS Code workspace files
    create_workspace_files
    
    # Create template files
    create_template_files
    
    # Show summary
    if ! $DRY_RUN; then
        show_summary
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi