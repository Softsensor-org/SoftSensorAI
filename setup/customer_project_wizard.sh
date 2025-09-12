#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

say(){ printf "\033[1;36m==> %s\033[0m\n" "$*"; }
warn(){ printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err(){ printf "\033[1;31m[err]\033[0m %s\n" "$*"; }
has(){ command -v "$1" >/dev/null 2>&1; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
BASE="${BASE:-$HOME/projects}"
NON_INTERACTIVE=0
DRY=0
YES=0

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Customer-Project based repository setup wizard.
Creates structure: org/customer/project/repos (backend, frontend, etc.)

Options:
  --org ORG            Organization name
  --customer CUSTOMER  Customer name
  --project PROJECT    Project name
  --repos "URL1 URL2"  Space-separated list of repo URLs
  --base PATH          Base directory (default: ~/projects)
  --non-interactive    Run without prompts
  --dry-run            Show plan without making changes
  --yes, -y            Skip confirmation
  --help               Show this help

Examples:
  # Interactive mode
  $0

  # Setup project with multiple repos
  $0 --org acme --customer bigcorp --project webapp \\
     --repos "git@github.com:acme/webapp-backend.git git@github.com:acme/webapp-frontend.git"

  # Dry run to preview
  $0 --dry-run --org acme --customer bigcorp --project ecommerce \\
     --repos "https://github.com/acme/shop-api https://github.com/acme/shop-ui"
EOF
  exit 0
}

# Parse arguments
ORG=""
CUSTOMER=""
PROJECT=""
REPO_URLS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org) ORG="$2"; shift 2;;
    --customer) CUSTOMER="$2"; shift 2;;
    --project) PROJECT="$2"; shift 2;;
    --repos) IFS=' ' read -ra REPO_URLS <<< "$2"; shift 2;;
    --base) BASE="$2"; shift 2;;
    --non-interactive) NON_INTERACTIVE=1; shift;;
    --dry-run) DRY=1; shift;;
    --yes|-y) YES=1; shift;;
    --help|-h) show_help;;
    *) err "Unknown option: $1"; show_help;;
  esac
done

# Helper functions
require_tools() {
  local tools=(git gh jq)
  local missing=()
  for t in "${tools[@]}"; do
    has "$t" || missing+=("$t")
  done
  if ((${#missing[@]})); then
    err "Missing required tools: ${missing[*]}"
    exit 1
  fi
}

to_ssh_url() {
  local url="$1"
  if [[ "$url" =~ ^https?://github\.com/([^/]+)/([^/]+?)/?$ ]]; then
    local repo="${BASH_REMATCH[2]}"
    repo="${repo%.git}"
    echo "git@github.com:${BASH_REMATCH[1]}/${repo}.git"
  else
    echo "$url"
  fi
}

select_menu() {
  local PS3="Select a number: "
  select opt in "$@"; do
    [[ -n "$opt" ]] && { echo "$opt"; return; }
    echo "Invalid. Try again."
  done
}

get_repo_name_from_url() {
  local url="$1"
  basename -s .git "${url##*/}"
}

# Detect repo type based on common patterns
detect_repo_type() {
  local repo_name="$1"
  case "$repo_name" in
    *-backend|*-api|*-server|*backend*|*api*|*server*) echo "backend";;
    *-frontend|*-ui|*-web|*-client|*frontend*|*ui*|*web*) echo "frontend";;
    *-mobile|*-app|*-ios|*-android|*mobile*) echo "mobile";;
    *-infra|*-infrastructure|*-devops|*infra*) echo "infra";;
    *-ml|*-ai|*-model|*ml*|*ai*) echo "ml";;
    *-data|*-etl|*-pipeline|*data*) echo "data";;
    *-docs|*-documentation|*docs*) echo "docs";;
    *) echo "other";;
  esac
}

# Create project manifest
create_project_manifest() {
  local project_path="$1"
  shift
  local repos=("$@")
  
  cat > "$project_path/PROJECT.json" <<EOF
{
  "organization": "$ORG",
  "customer": "$CUSTOMER",
  "project": "$PROJECT",
  "created": "$(date -Iseconds)",
  "structure": "org/customer/project/repos",
  "repositories": [
EOF
  
  local first=1
  for repo_url in "${repos[@]}"; do
    local repo_name=$(get_repo_name_from_url "$repo_url")
    local repo_type=$(detect_repo_type "$repo_name")
    
    [[ $first -eq 1 ]] && first=0 || echo "," >> "$project_path/PROJECT.json"
    
    cat >> "$project_path/PROJECT.json" <<EOF
    {
      "name": "$repo_name",
      "type": "$repo_type",
      "url": "$repo_url",
      "path": "$repo_type/$repo_name"
    }
EOF
  done
  
  cat >> "$project_path/PROJECT.json" <<EOF

  ]
}
EOF
}

# Create project README
create_project_readme() {
  local project_path="$1"
  shift
  local repos=("$@")
  
  cat > "$project_path/README.md" <<EOF
# $PROJECT

**Organization:** $ORG  
**Customer:** $CUSTOMER  
**Created:** $(date +"%Y-%m-%d")

## Project Structure

\`\`\`
$ORG/
└── $CUSTOMER/
    └── $PROJECT/
        ├── backend/
        ├── frontend/
        ├── mobile/
        ├── infra/
        ├── data/
        └── docs/
\`\`\`

## Repositories

EOF
  
  for repo_url in "${repos[@]}"; do
    local repo_name=$(get_repo_name_from_url "$repo_url")
    local repo_type=$(detect_repo_type "$repo_name")
    echo "- **$repo_name** ($repo_type): \`$repo_url\`" >> "$project_path/README.md"
  done
  
  cat >> "$project_path/README.md" <<EOF

## Quick Start

\`\`\`bash
# Navigate to project
cd $project_path

# Run setup for all repos
./scripts/setup_all.sh

# Run checks for all repos
./scripts/check_all.sh
\`\`\`

## Development

Each repository has its own README with specific instructions.
EOF
}

# Create project helper scripts
create_project_scripts() {
  local project_path="$1"
  mkdir -p "$project_path/scripts"
  
  # Setup all script
  cat > "$project_path/scripts/setup_all.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Setting up all repositories..."

for dir in backend frontend mobile infra data docs; do
  if [ -d "$dir" ] && [ "$(ls -A $dir 2>/dev/null)" ]; then
    echo "==> Setting up $dir repositories"
    for repo in $dir/*/; do
      if [ -d "$repo" ]; then
        echo "  → $(basename $repo)"
        (
          cd "$repo"
          # Node.js setup
          if [ -f package.json ]; then
            if [ -f pnpm-lock.yaml ]; then
              pnpm install
            elif command -v pnpm >/dev/null; then
              pnpm install
            else
              npm ci || npm install
            fi
          fi
          # Python setup
          if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
            python3 -m venv .venv
            . .venv/bin/activate
            pip install -U pip
            [ -f requirements.txt ] && pip install -r requirements.txt
            [ -f pyproject.toml ] && pip install -e .
            deactivate
          fi
        )
      fi
    done
  fi
done

echo "✓ All repositories set up"
EOF
  chmod +x "$project_path/scripts/setup_all.sh"
  
  # Check all script
  cat > "$project_path/scripts/check_all.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Running checks for all repositories..."
failed=()

for dir in backend frontend mobile infra data docs; do
  if [ -d "$dir" ] && [ "$(ls -A $dir 2>/dev/null)" ]; then
    for repo in $dir/*/; do
      if [ -d "$repo" ]; then
        repo_name="$(basename $repo)"
        echo "==> Checking $dir/$repo_name"
        (
          cd "$repo"
          # Node.js checks
          if [ -f package.json ]; then
            if command -v pnpm >/dev/null && [ -f pnpm-lock.yaml ]; then
              pnpm run lint 2>/dev/null || true
              pnpm run typecheck 2>/dev/null || true
              pnpm run test 2>/dev/null || true
            else
              npm run lint 2>/dev/null || true
              npm run typecheck 2>/dev/null || true
              npm run test 2>/dev/null || true
            fi
          fi
          # Python checks
          if [ -d .venv ] && [ -f .venv/bin/pytest ]; then
            . .venv/bin/activate
            pytest -q 2>/dev/null || true
            deactivate
          fi
        ) || failed+=("$dir/$repo_name")
      fi
    done
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  echo "⚠ Checks failed for: ${failed[*]}"
  exit 1
else
  echo "✓ All checks passed"
fi
EOF
  chmod +x "$project_path/scripts/check_all.sh"
  
  # Git status script
  cat > "$project_path/scripts/git_status_all.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Git status for all repositories:"
echo "================================"

for dir in backend frontend mobile infra ml ops data docs other; do
  if [ -d "$dir" ]; then
    for repo in $dir/*/; do
      if [ -d "$repo" ] && [ -d "$repo/.git" ]; then
        echo ""
        echo "→ $dir/$(basename $repo)"
        (
          cd "$repo"
          branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
          status=$(git status --porcelain 2>/dev/null | wc -l)
          ahead_behind=$(git rev-list --left-right --count origin/$branch...$branch 2>/dev/null || echo "0	0")
          ahead=$(echo "$ahead_behind" | cut -f2)
          behind=$(echo "$ahead_behind" | cut -f1)
          
          echo "  Branch: $branch"
          [ "$status" -gt 0 ] && echo "  ⚠ Uncommitted changes: $status files"
          [ "$ahead" -gt 0 ] && echo "  ↑ Ahead by $ahead commits"
          [ "$behind" -gt 0 ] && echo "  ↓ Behind by $behind commits"
          [ "$status" -eq 0 ] && [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ] && echo "  ✓ Clean"
        )
      fi
    done
  fi
done
EOF
  chmod +x "$project_path/scripts/git_status_all.sh"
}

# Main execution
say "Customer-Project Repository Setup Wizard"

# Check tools
require_tools

# Interactive collection if needed
if [[ $NON_INTERACTIVE -eq 0 ]]; then
  # Organization
  if [[ -z "$ORG" ]]; then
    if [ -d "$BASE" ]; then
      mapfile -t ORGS < <(find "$BASE" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort)
      if ((${#ORGS[@]})); then
        say "Select organization:"
        ORG=$(select_menu "${ORGS[@]}" "Create new...")
        [[ "$ORG" == "Create new..." ]] && read -rp "New organization name: " ORG
      else
        read -rp "Organization name: " ORG
      fi
    else
      read -rp "Organization name: " ORG
    fi
  fi
  
  # Customer
  if [[ -z "$CUSTOMER" ]]; then
    if [ -d "$BASE/$ORG" ]; then
      mapfile -t CUSTOMERS < <(find "$BASE/$ORG" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort)
      if ((${#CUSTOMERS[@]})); then
        say "Select customer:"
        CUSTOMER=$(select_menu "${CUSTOMERS[@]}" "Create new...")
        [[ "$CUSTOMER" == "Create new..." ]] && read -rp "New customer name: " CUSTOMER
      else
        read -rp "Customer name: " CUSTOMER
      fi
    else
      read -rp "Customer name: " CUSTOMER
    fi
  fi
  
  # Project
  if [[ -z "$PROJECT" ]]; then
    read -rp "Project name: " PROJECT
  fi
  
  # Repository URLs
  if [[ ${#REPO_URLS[@]} -eq 0 ]]; then
    say "Enter repository URLs (one per line, empty line to finish):"
    while true; do
      read -rp "Repo URL: " url
      [[ -z "$url" ]] && break
      REPO_URLS+=("$url")
    done
  fi
fi

# Validate inputs
[[ -z "$ORG" ]] && { err "Organization required"; exit 1; }
[[ -z "$CUSTOMER" ]] && { err "Customer required"; exit 1; }
[[ -z "$PROJECT" ]] && { err "Project required"; exit 1; }
[[ ${#REPO_URLS[@]} -eq 0 ]] && { err "At least one repository URL required"; exit 1; }

# Convert URLs to SSH format
SSH_URLS=()
for url in "${REPO_URLS[@]}"; do
  SSH_URLS+=("$(to_ssh_url "$url")")
done

# Build project path
PROJECT_PATH="$BASE/$ORG/$CUSTOMER/$PROJECT"

# Show plan
echo ""
echo "================= SETUP PLAN ================="
echo "Structure      : $ORG → $CUSTOMER → $PROJECT"
echo "Location       : $PROJECT_PATH"
echo "Repositories   : ${#SSH_URLS[@]} repos to clone"
for url in "${SSH_URLS[@]}"; do
  repo_name=$(get_repo_name_from_url "$url")
  repo_type=$(detect_repo_type "$repo_name")
  echo "  - $repo_name ($repo_type)"
done
echo ""
echo "Will create:"
echo "  - Project structure with categorized repos"
echo "  - PROJECT.json manifest"
echo "  - Project README.md"
echo "  - Helper scripts (setup_all, check_all, git_status_all)"
echo "  - Agent configurations for each repo"
echo "=============================================="

if [[ $DRY -eq 1 ]]; then
  say "[DRY-RUN] No changes made"
  exit 0
fi

if [[ $YES -eq 0 && $NON_INTERACTIVE -eq 0 ]]; then
  read -rp "Proceed? (y/N): " confirm
  [[ "${confirm,,}" != "y" ]] && { say "Aborted"; exit 1; }
fi

# Create structure
say "Creating project structure..."
mkdir -p "$PROJECT_PATH"
for dir in backend frontend mobile infra ml data docs ops; do
  mkdir -p "$PROJECT_PATH/$dir"
done

# Clone repositories
say "Cloning repositories..."
for url in "${SSH_URLS[@]}"; do
  repo_name=$(get_repo_name_from_url "$url")
  repo_type=$(detect_repo_type "$repo_name")
  target_dir="$PROJECT_PATH/$repo_type/$repo_name"
  
  if [ -d "$target_dir" ]; then
    warn "Repository already exists: $target_dir"
  else
    say "  Cloning $repo_name → $repo_type/"
    git clone "$url" "$target_dir"
    
    # Add agent configs
    if [ -f "$SCRIPT_DIR/agents_repo.sh" ]; then
      (cd "$target_dir" && "$SCRIPT_DIR/agents_repo.sh" --force)
    fi
  fi
done

# Create project files
say "Creating project configuration..."
create_project_manifest "$PROJECT_PATH" "${SSH_URLS[@]}"
create_project_readme "$PROJECT_PATH" "${SSH_URLS[@]}"
create_project_scripts "$PROJECT_PATH"

# Create VS Code workspace
say "Creating VS Code workspace..."
cat > "$PROJECT_PATH/${PROJECT}.code-workspace" <<EOF
{
  "folders": [
EOF

first=1
for url in "${SSH_URLS[@]}"; do
  repo_name=$(get_repo_name_from_url "$url")
  repo_type=$(detect_repo_type "$repo_name")
  [[ $first -eq 1 ]] && first=0 || echo "," >> "$PROJECT_PATH/${PROJECT}.code-workspace"
  echo -n "    { \"path\": \"$repo_type/$repo_name\", \"name\": \"[$repo_type] $repo_name\" }" >> "$PROJECT_PATH/${PROJECT}.code-workspace"
done

cat >> "$PROJECT_PATH/${PROJECT}.code-workspace" <<EOF

  ],
  "settings": {
    "window.title": "$ORG / $CUSTOMER / $PROJECT - \${activeEditorShort}",
    "npm.packageManager": "pnpm",
    "git.enableCommitSigning": true
  }
}
EOF

say "✓ Project setup complete!"
echo ""
echo "📂 Project location: $PROJECT_PATH"
echo "💻 Open in VS Code: code \"$PROJECT_PATH/${PROJECT}.code-workspace\""
echo ""
echo "📝 Next steps:"
echo "  1. cd \"$PROJECT_PATH\""
echo "  2. ./scripts/setup_all.sh    # Install dependencies"
echo "  3. ./scripts/git_status_all.sh # Check git status"
echo ""
echo "Structure created:"
echo "  $ORG/"
echo "  └── $CUSTOMER/"
echo "      └── $PROJECT/"
echo "          ├── backend/"
echo "          ├── frontend/"
echo "          ├── mobile/"
echo "          └── ..."