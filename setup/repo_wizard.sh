#!/usr/bin/env bash
set -euo pipefail
 say(){ printf "\033[1;36m==> %s\033[0m\n" "$*"; }
 warn(){ printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
 err(){ printf "\033[1;31m[err]\033[0m %s\n" "$*"; }
has(){ command -v "$1" >/dev/null 2>&1; }

# Script directory (portable)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command-line arguments
LITE=0; NO_HOOKS=0; NO_SCRIPTS=0; NO_BOOTSTRAP=0; NON_INTERACTIVE=0; WITH_CODEX=0
ORG=""; CAT=""; GHURL_IN=""; BRANCH=""; RNAME=""
P_SKILL=""; P_PHASE=""; P_TEACH=""
# New planning flags
BASE_DEFAULT="$HOME/projects"
BASE="$BASE_DEFAULT"
YES=0
DRY=0

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Interactive wizard for cloning and setting up repositories with agent configurations.

Options:
  --non-interactive     Run without prompts (requires --org, --category, --url)
  --org ORG            Organization name
  --category CAT       Category (backend/frontend/mobile/infra/ml/ops/data/docs)
  --cat CAT            Alias for --category
  --url URL            GitHub repository URL (SSH or HTTPS)
  --branch BRANCH      Branch to clone (optional)
  --name NAME          Local repository name (optional, defaults to repo name)
  --lite               Skip hooks, scripts, and bootstrap
  --no-hooks           Skip git hooks installation
  --no-scripts         Skip helper scripts
  --no-bootstrap       Skip dependency installation
  --with-codex         Add Codex CLI integration (sandbox + Makefile targets)
  --skill LEVEL        Apply profile skill (vibe|beginner|l1|l2|expert)
  --phase PHASE        Apply project phase (poc|mvp|beta|scale)
  --teach-mode MODE    Beginner teach mode: on|off (overrides default)
  --base PATH          Base directory for repositories (default: ~/projects)
  --yes, -y            Skip confirmation prompts
  --dry-run, --plan-only Show plan without making changes
  --help               Show this help message

Examples:
  # Interactive mode
  $0

  # Non-interactive clone
  $0 --non-interactive --org myorg --category backend --url git@github.com:user/repo.git

  # Plan only (preview without changes)
  $0 --plan-only --org myorg --category backend --url git@github.com:user/repo.git

  # Custom base directory with auto-confirm
  $0 --base ~/work --org acme --category frontend \\
     --url https://github.com/acme/webapp --branch develop --name webapp-dev --yes

  # With all options
  $0 --non-interactive --org acme --category frontend \\
     --url https://github.com/acme/webapp --branch develop --name webapp-dev --lite
EOF
  exit 0
}

# Ensure option has a following value
need_value() {
  local opt="$1"; shift || true
  if [[ $# -lt 1 ]]; then
    err "Missing value for ${opt}"
    echo "Run with --help for usage"
    exit 2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lite) LITE=1; NO_HOOKS=1; NO_SCRIPTS=1; shift;;
    --no-hooks) NO_HOOKS=1; shift;;
    --no-scripts) NO_SCRIPTS=1; shift;;
    --no-bootstrap) NO_BOOTSTRAP=1; shift;;
    --with-codex) WITH_CODEX=1; shift;;
    --non-interactive) NON_INTERACTIVE=1; shift;;
    --org) need_value "$1" ${2-}; ORG="$2"; shift 2;;
    --category|--cat) need_value "$1" ${2-}; CAT="$2"; shift 2;;
    --url) need_value "$1" ${2-}; GHURL_IN="$2"; shift 2;;
    --branch) need_value "$1" ${2-}; BRANCH="$2"; shift 2;;
    --name) need_value "$1" ${2-}; RNAME="$2"; shift 2;;
    --skill) need_value "$1" ${2-}; P_SKILL="$2"; shift 2;;
    --phase) need_value "$1" ${2-}; P_PHASE="$2"; shift 2;;
    --teach-mode) need_value "$1" ${2-}; P_TEACH="$2"; shift 2;;
    --base) need_value "$1" ${2-}; BASE="${2:-$BASE_DEFAULT}"; shift 2;;
    --yes|-y) YES=1; shift;;
    --dry-run|--plan-only) DRY=1; shift;;
    --help|-h) show_help;;
    *) err "Unknown option: $1"; show_help;;
  esac
done

# Validate non-interactive mode
if [[ $NON_INTERACTIVE -eq 1 ]]; then
  if [[ -z "$ORG" || -z "$CAT" || -z "$GHURL_IN" ]]; then
    err "Non-interactive mode requires --org, --category, and --url"
    exit 1
  fi
fi

require_tools(){
  # In plan-only mode, only git is required; full run needs gh, curl, jq as well
  local tools=()
  if [[ "${DRY:-0}" -eq 1 ]]; then
    tools=(git)
  else
    tools=(git gh curl jq)
  fi
  local m=(); local t
  for t in "${tools[@]}"; do has "$t" || m+=("$t"); done
  if ((${#m[@]})); then
    err "Missing required tools: ${m[*]}"
    echo "Install with: ./install/key_software_linux.sh (Linux/WSL) or ./install/key_software_macos.sh (macOS)"
    exit 1
  fi
}
ensure_dir(){ mkdir -p "$1"; }
to_ssh_url(){ local u="$1"; if [[ "$u" =~ ^https?://github\.com/([^/]+)/([^/]+?)/?$ ]]; then local repo="${BASH_REMATCH[2]}"; repo="${repo%.git}"; echo "git@github.com:${BASH_REMATCH[1]}/${repo}.git"; else echo "$u"; fi; }
select_menu(){ local PS3="Select a number: "; select opt in "$@"; do [[ -n "$opt" ]] && { echo "$opt"; return; }; echo "Invalid. Try again."; done; }

seed_defaults(){ "$SCRIPT_DIR/agents_repo.sh" --force || true; }

# Planning helper functions
plan_tree() {
  # prints the org/category/name path relative to BASE
  printf "%s\n" "${BASE}/${ORG}/${CAT}/${RNAME}" | sed "s|^${HOME}|~|"
}

plan_files() {
  # list of files the wizard/seeder will write
  cat <<EOF
- CLAUDE.md
- .claude/settings.json
- .mcp.json
- .claude/commands/* (seeded)
- AGENTS.md
- .envrc (if enabled)
- .gitignore (appends common entries)
- .githooks/commit-msg (commit sanitizer) + hooksPath config
- scripts/repo_analysis.sh, scripts/run_checks.sh, scripts/open_pr.sh
EOF
  [[ "$WITH_CODEX" -eq 1 ]] && echo "- Makefile (Codex targets) or scripts/codex_sandbox.sh"
  return 0
}

plan_actions() {
  cat <<EOF
- Ensure base/org/category directories exist
- Clone repository (branch: ${BRANCH:-default})
- Seed agent guardrails and commands
EOF
  [[ "$LITE" -eq 0 && "$NO_HOOKS" -eq 0 ]] && echo "- Install commit-message sanitizer hook"
  [[ "$LITE" -eq 0 && "$NO_SCRIPTS" -eq 0 ]] && echo "- Drop helper scripts"
  [[ "$WITH_CODEX" -eq 1 ]] && echo "- Add Codex CLI integration"
  [[ "$NO_BOOTSTRAP" -eq 0 ]] && cat <<EOF
- Bootstrap dependencies:
  • Node: pnpm install (or npm ci)
  • Python: create .venv and install requirements/pyproject (if present)
EOF
  return 0
}

confirm_or_exit() {
  local target_rel
  target_rel="$(echo "${TARGET}" | sed "s|^${HOME}|~|")"

  echo "================= PLAN SUMMARY ================="
  echo "Base folder    : ${BASE}"
  echo "Repo URL       : ${URL}"
  echo "Org/Category   : ${ORG} / ${CAT}"
  echo "Repo name      : ${RNAME}"
  echo "Target path    : ${target_rel}"
  echo
  echo "It will perform:"
  plan_actions
  echo
  echo "It will write/modify:"
  plan_files
  echo "================================================"

  if [[ "$DRY" -eq 1 ]]; then
    echo "[DRY-RUN] No changes will be made."
    exit 0
  fi

  if [[ "$YES" -eq 1 ]]; then
    return 0
  fi

  read -rp "Type the repo name (${RNAME}) to proceed, or anything else to cancel: " confirm
  if [[ "$confirm" != "$RNAME" ]]; then
    echo "Aborted."
    exit 1
  fi
}

install_commit_sanitizer(){
  mkdir -p .githooks
  cat > .githooks/commit-msg <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
MSG="$1"
sed -i 's/\r$//' "$MSG" || true
awk 'BEGIN{IGNORECASE=1}
  /Generated with \[Claude Code\]\(https?:\/\/claude\.ai\/code\)/ {next}
  /^Co-Authored-By:[[:space:]]*Claude\b/ {next}
  /^Co-Authored-By:.*anthropic\.com/ {next}
  /^[[:space:]]*Create frontend commit[[:space:]]*$/ {next}
  {print}
' "$MSG" > "$MSG.tmp" && mv "$MSG.tmp" "$MSG"
sed -i 's/[[:space:]]\+$//' "$MSG"
awk 'NR==1{pb=0}{if($0~/^[[:space:]]*$/){if(pb)next;pb=1}else pb=0;print}' "$MSG" > "$MSG.tmp" && mv "$MSG.tmp" "$MSG"
exit 0
HOOK
  chmod +x .githooks/commit-msg
  git config --local core.hooksPath .githooks
}

seed_helper_scripts(){
  mkdir -p scripts && chmod 755 scripts
  cat > scripts/repo_analysis.sh <<'SC'
#!/usr/bin/env bash
set -euo pipefail
echo "== repo summary =="; git remote -v | sed 's/^/remote: /'
echo "branch: $(git rev-parse --abbrev-ref HEAD)"
echo "last commit: $(git log -1 --pretty="format:%h %ad %an — %s" --date=short)"
echo; echo "== file counts (top 10 extensions) =="
git ls-files | awk -F. 'NF>1{print $NF}' | sort | uniq -c | sort -nr | head
echo; echo "== TODO/FIXME/BUG =="; rg -n "TODO|FIXME|BUG" || true
echo; echo "== package managers =="
[ -f package.json ] && echo "- node: $(jq -r .name package.json)"
[ -f pnpm-lock.yaml ] && echo "- pnpm lock present"
[ -f requirements.txt ] && echo "- python: requirements.txt"
[ -f pyproject.toml ] && echo "- python: pyproject.toml"
SC
  chmod +x scripts/repo_analysis.sh

  cat > scripts/run_checks.sh <<'SC'
#!/usr/bin/env bash
set -euo pipefail
status=0
if [ -f package.json ]; then
  if jq -e '.scripts.lint' package.json >/dev/null 2>&1; then pnpm run lint || status=$?; fi
  if jq -e '.scripts.typecheck' package.json >/dev/null 2>&1; then pnpm run typecheck || status=$?; fi
  if jq -e '.scripts.test' package.json >/dev/null 2>&1; then pnpm run test --if-present || status=$?; fi
fi
if [ -d .venv ] && [ -f pyproject.toml -o -f requirements.txt ]; then
  if [ -f .venv/bin/pytest ]; then . .venv/bin/activate && pytest -q || status=$?; deactivate || true; fi
fi
exit $status
SC
  chmod +x scripts/run_checks.sh

  cat > scripts/open_pr.sh <<'SC'
#!/usr/bin/env bash
set -euo pipefail
BR="${1:-feature/quick-change}"
git checkout -b "$BR" || git checkout "$BR"
git add -A
git commit -m "${2:-chore: small change}" || true
gh pr create -f || { echo "PR creation failed"; exit 1; }
SC
  chmod +x scripts/open_pr.sh
}

bootstrap_env(){
  if [ -f package.json ]; then
    say "Found package.json - Installing Node dependencies..."
    if [ -f pnpm-lock.yaml ]; then
      if command -v pnpm >/dev/null 2>&1; then pnpm install; else err "pnpm required by pnpm-lock.yaml but not installed"; exit 1; fi
    else
      if command -v pnpm >/dev/null 2>&1; then pnpm install; else npm ci || npm install; fi
    fi
  fi
  if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    say "Found Python project - Setting up virtual environment (.venv)..."
    if command -v uv >/dev/null 2>&1; then
      uv venv .venv; . .venv/bin/activate
      { [ -f requirements.txt ] && uv pip install -r requirements.txt || uv pip install -e . || true; }
      deactivate
    else
      python3 -m venv .venv; . .venv/bin/activate
      python -m pip install -U pip setuptools wheel
      { [ -f requirements.txt ] && pip install -r requirements.txt || pip install -e . || true; }
      deactivate
    fi
    if command -v direnv >/dev/null 2>&1; then
      cat > .envrc <<'RC'
if [ -d .venv ]; then
  source .venv/bin/activate
fi
[ -f .envrc.local ] && source .envrc.local
RC
      echo ".envrc.local" >> .gitignore 2>/dev/null || true
      direnv allow || true
    fi
  fi
  if [ -f .pre-commit-config.yaml ] && command -v pre-commit >/dev/null 2>&1; then
    pre-commit install || true
  fi
}

# Function to check if we're in an existing repo
check_existing_repo() {
  if [ -d ".git" ] || [ -f "package.json" ] || [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    return 0
  fi
  return 1
}

# main
say "Repo Setup Wizard"

# Check if we're in an existing repository
if check_existing_repo && [ "$NON_INTERACTIVE" -eq 0 ]; then
  warn "You appear to be in an existing project directory"
  echo "Current directory: $(pwd)"
  echo ""
  echo "Options:"
  echo "  1) Setup agent configs for THIS existing project"
  echo "  2) Clone a NEW repository (continue with wizard)"
  echo "  3) Exit"
  echo ""
  read -p "Choose option (1-3): " existing_choice

  case "$existing_choice" in
    1)
      # Launch existing repo setup
      if [ -f "$SCRIPT_DIR/existing_repo_setup.sh" ]; then
        exec "$SCRIPT_DIR/existing_repo_setup.sh"
      else
        err "Existing repo setup script not found"
        exit 1
      fi
      ;;
    2)
      # Continue with normal flow
      say "Continuing with new repository setup..."
      ;;
    3)
      say "Exiting..."
      exit 0
      ;;
    *)
      err "Invalid choice"
      exit 1
      ;;
  esac
fi

say "Checking required tools..."
require_tools
say "✓ All required tools found"

# Ensure/ask base location if not provided
if [[ -z "${BASE:-}" || "${BASE}" = "/" ]]; then BASE="${BASE_DEFAULT}"; fi
if [[ "$DRY" -eq 0 ]]; then
  if [[ ! -d "$BASE" ]]; then
    warn "Base folder does not exist: $BASE"
    if [[ "$YES" -eq 1 || "$NON_INTERACTIVE" -eq 1 ]]; then
      mkdir -p "$BASE"
    else
      read -rp "Create it now? [y/N]: " mkb
      [[ "${mkb,,}" == "y" ]] && mkdir -p "$BASE" || { echo "Aborted."; exit 1; }
    fi
  fi
  ensure_dir "$BASE"
fi
if [[ -z "$ORG" && "$DRY" -eq 0 ]]; then
  say "Scanning for existing organizations..."
  if [ -d "$BASE" ]; then
    mapfile -t ORGS < <(find "$BASE" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort)
  else
    ORGS=()
  fi

  # Add option for existing directory setup
  if ((${#ORGS[@]}==0)); then
    warn "No orgs under $BASE."
    echo "Options:"
    echo "  1) Enter new organization name"
    echo "  2) Setup existing project (different location)"
    read -p "Choose (1-2): " org_choice

    if [ "$org_choice" = "2" ]; then
      if [ -f "$SCRIPT_DIR/existing_repo_setup.sh" ]; then
        exec "$SCRIPT_DIR/existing_repo_setup.sh"
      fi
    else
      read -rp "Enter new org slug (e.g., org1): " ORG
    fi
  else
    say "Choose an org"
    ORG=$(select_menu "${ORGS[@]}" "Create new…" "Setup existing repo")
    if [[ "$ORG" == "Setup existing repo" ]]; then
      if [ -f "$SCRIPT_DIR/existing_repo_setup.sh" ]; then
        exec "$SCRIPT_DIR/existing_repo_setup.sh"
      fi
    elif [[ "$ORG" == "Create new…" ]]; then
      read -rp "Enter new org slug: " ORG
    fi
  fi
fi
[[ -z "$ORG" ]] && ORG="testorg"  # Default for dry-run

SUBS=(backend frontend mobile infra ml ops data docs sandbox playground)
if [[ "$DRY" -eq 0 ]]; then
  say "Setting up category directories..."
  for s in "${SUBS[@]}"; do ensure_dir "$BASE/$ORG/$s"; done
  say "✓ Category directories ready"
fi

if [[ -z "$CAT" && "$DRY" -eq 0 ]]; then
  say "Choose a category"; CAT=$(select_menu "${SUBS[@]}" "other")
  [[ "$CAT" == "other" ]] && read -rp "Custom category: " CAT && ensure_dir "$BASE/$ORG/$CAT"
else
  [[ -z "$CAT" ]] && CAT="backend"  # Default for dry-run
  [[ "$DRY" -eq 0 ]] && ensure_dir "$BASE/$ORG/$CAT"
fi

if [[ -z "$GHURL_IN" && "$DRY" -eq 0 ]]; then
  read -rp "GitHub URL (SSH or HTTPS): " GHURL_IN
fi
[[ -z "$GHURL_IN" ]] && GHURL_IN="git@github.com:test/repo.git"  # Default for dry-run
URL="$(to_ssh_url "$GHURL_IN")"
DEF_NAME="$(basename -s .git "${URL##*:}")"
if [[ -z "$RNAME" && "$DRY" -eq 0 ]]; then
  read -rp "Local repo folder name [${DEF_NAME}]: " RNAME; RNAME="${RNAME:-$DEF_NAME}"
fi
[[ -z "$RNAME" ]] && RNAME="${RNAME:-$DEF_NAME}"
if [[ -z "${BRANCH:-}" && "$DRY" -eq 0 ]]; then
  read -rp "Branch to clone (optional): " BRANCH || true
fi

TARGET="$BASE/$ORG/$CAT/$RNAME"
if [[ "$DRY" -eq 0 ]]; then
  if [ -e "$TARGET" ]; then
    if [[ $NON_INTERACTIVE -eq 1 ]]; then
      err "Path exists: $TARGET (use --name to specify a different name)"
      exit 1
    else
      warn "Path exists: $TARGET"
      read -rp "Use anyway? (y/N): " C
      [[ "${C,,}" == "y" ]] || { err "Abort."; exit 1; }
    fi
  else
    ensure_dir "$(dirname "$TARGET")"
  fi
fi

# show the plan and confirm before any change
confirm_or_exit

say "Cloning repository → $TARGET"
if [ -n "${BRANCH:-}" ]; then
  say "  Branch: $BRANCH"
  git clone --branch "$BRANCH" --single-branch "$URL" "$TARGET"
else
  git clone "$URL" "$TARGET"
fi
say "✓ Repository cloned successfully"
cd "$TARGET"

say "Seeding repo defaults (CLAUDE.md, settings, commands)..."
seed_defaults
say "✓ Agent configuration seeded"
[[ "$LITE" -eq 1 || "$NO_HOOKS" -eq 1 ]] || { say "Installing commit sanitizer hook..."; install_commit_sanitizer; say "✓ Commit hooks installed"; }
[[ "$LITE" -eq 1 || "$NO_SCRIPTS" -eq 1 ]] || { say "Creating helper scripts (repo_analysis, run_checks, open_pr)..."; seed_helper_scripts; say "✓ Helper scripts created"; }

# Add Codex integration if requested
if [[ "$WITH_CODEX" -eq 1 ]]; then
  say "Adding Codex CLI integration..."

  # Copy sandbox script if available
  if [ -f "$SCRIPT_DIR/../scripts/codex_sandbox.sh" ]; then
    mkdir -p scripts
    cp "$SCRIPT_DIR/../scripts/codex_sandbox.sh" scripts/
    chmod +x scripts/codex_sandbox.sh
    say "  ✓ Added scripts/codex_sandbox.sh"
  fi

  # Add Codex targets to Makefile
  if [ -f Makefile ]; then
    if ! grep -q "codex-fix:" Makefile; then
      cat >> Makefile <<'MAKEFILE'

# --- Codex CLI Integration ---
codex-fix:
	@if [ -f scripts/codex_sandbox.sh ]; then \
		scripts/codex_sandbox.sh exec "lint, typecheck, unit tests; fix failures" --approval-mode auto-edit; \
	elif command -v codex >/dev/null 2>&1; then \
		codex exec "lint, typecheck, unit tests; fix failures" --approval-mode auto-edit; \
	else \
		echo "Codex not available. Install with: npm i -g @openai/codex"; \
		exit 1; \
	fi

codex-refactor:
	@codex exec "refactor for readability and performance" --approval-mode suggest

.PHONY: codex-fix codex-refactor
MAKEFILE
      say "  ✓ Added Codex targets to Makefile"
    fi
  else
    # Create minimal Makefile with Codex targets
    cat > Makefile <<'MAKEFILE'
.PHONY: codex-fix codex-refactor

codex-fix:
	@if [ -f scripts/codex_sandbox.sh ]; then \
		scripts/codex_sandbox.sh exec "lint, typecheck, unit tests; fix failures" --approval-mode auto-edit; \
	elif command -v codex >/dev/null 2>&1; then \
		codex exec "lint, typecheck, unit tests; fix failures" --approval-mode auto-edit; \
	else \
		echo "Codex not available. Install with: npm i -g @openai/codex"; \
		exit 1; \
	fi

codex-refactor:
	@codex exec "refactor for readability and performance" --approval-mode suggest
MAKEFILE
    say "  ✓ Created Makefile with Codex targets"
  fi

  # Update Claude permissions to include Codex
  if [ -f .claude/settings.json ]; then
    # Add Codex permissions if not already present
    if ! grep -q "codex exec" .claude/settings.json; then
      jq '.permissions.allow += ["Bash(codex exec:*)", "Bash(scripts/codex_sandbox.sh:*)"]' .claude/settings.json > .claude/settings.json.tmp && \
        mv .claude/settings.json.tmp .claude/settings.json
      say "  ✓ Updated Claude permissions for Codex"
    fi
  fi
fi

if [[ "$NO_BOOTSTRAP" -ne 1 ]]; then
  say "Bootstrapping project dependencies..."

  # Track what we find and install
  deps_found=()
  deps_installed=()

  if [ -f package.json ]; then
    deps_found+=("Node.js (package.json)")
    if [ -f pnpm-lock.yaml ]; then
      deps_found+=("pnpm lockfile")
    fi
  fi

  if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    if [ -f requirements.txt ]; then
      deps_found+=("Python (requirements.txt)")
    fi
    if [ -f pyproject.toml ]; then
      deps_found+=("Python (pyproject.toml)")
    fi
  fi

  if [ ${#deps_found[@]} -gt 0 ]; then
    say "  Found: ${deps_found[*]}"
  else
    say "  No dependency files found (package.json, requirements.txt, pyproject.toml)"
  fi

  # Run the bootstrap
  bootstrap_env

  # Report what was installed
  if [ -f package.json ]; then
    if [ -f node_modules/.package-lock.json ] || [ -f node_modules/.modules.yaml ]; then
      deps_installed+=("Node modules")
    fi
  fi

  if [ -d .venv ]; then
    deps_installed+=("Python venv")
    if [ -f .envrc ]; then
      deps_installed+=("direnv config")
    fi
  fi

  if [ ${#deps_installed[@]} -gt 0 ]; then
    say "✓ Dependencies installed: ${deps_installed[*]}"
  else
    say "✓ Dependencies check complete (no installations needed)"
  fi
fi

# Apply profile (with Beginner teach-mode prompt in interactive mode)
apply_profile_now="no"
if [[ $NON_INTERACTIVE -eq 1 ]]; then
  apply_profile_now="yes"
else
  read -rp "Apply a profile now? (Y/n): " ans
  [[ -z "$ans" || "${ans,,}" == "y" ]] && apply_profile_now="yes"
fi

if [[ "$apply_profile_now" == "yes" ]]; then
  # Use provided values or prompt interactively
  skill="${P_SKILL:-}"
  phase="${P_PHASE:-}"
  teach="${P_TEACH:-}"

  if [[ $NON_INTERACTIVE -eq 0 ]]; then
    # Interactive mode: prompt for skill if not provided
    if [[ -z "$skill" ]]; then
      echo ""
      say "Select skill level:"
      echo "  1) vibe      - Vibecoding: minimal structure, maximum freedom"
      echo "  2) beginner  - Learning mode with detailed guidance"
      echo "  3) l1        - Junior developer level"
      echo "  4) l2        - Mid-level developer"
      echo "  5) expert    - Senior developer, minimal hand-holding"
      read -rp "Enter choice (1-5) [2]: " choice
      case "${choice:-2}" in
        1) skill="vibe";;
        2) skill="beginner";;
        3) skill="l1";;
        4) skill="l2";;
        5) skill="expert";;
        *) skill="beginner"; warn "Invalid choice, defaulting to beginner";;
      esac
    fi

    # Interactive mode: prompt for phase if not provided
    if [[ -z "$phase" ]]; then
      echo ""
      say "Select project phase:"
      echo "  1) poc    - Proof of concept, rapid prototyping"
      echo "  2) mvp    - Minimum viable product"
      echo "  3) beta   - Beta testing, stabilization"
      echo "  4) scale  - Production, scaling focus"
      read -rp "Enter choice (1-4) [2]: " choice
      case "${choice:-2}" in
        1) phase="poc";;
        2) phase="mvp";;
        3) phase="beta";;
        4) phase="scale";;
        *) phase="mvp"; warn "Invalid choice, defaulting to mvp";;
      esac
    fi

    # If not specified, ask beginner teach-mode preference
    if [[ -z "$teach" && "$skill" == "beginner" ]]; then
      read -rp "Beginner teach mode (guided, verbose CoT)? (Y/n): " t
      if [[ -z "$t" || "${t,,}" == "y" ]]; then teach="on"; else teach="off"; fi
    fi
  else
    # Non-interactive defaults
    skill="${skill:-beginner}"
    phase="${phase:-mvp}"
    if [[ -z "$teach" && "$skill" == "beginner" ]]; then teach="on"; fi
  fi

  cmd=("$SCRIPT_DIR/../scripts/apply_profile.sh" --skill "$skill" --phase "$phase")
  [[ -n "$teach" ]] && cmd+=(--teach-mode "$teach")
  say "Applying profile: skill=$skill phase=$phase teach=${teach:-auto}..."
  "${cmd[@]}"
  say "✓ Profile applied"
fi

# Secrets guidance (print instructions and optional gh setup)
MISSING_SECRETS=()
for key in ANTHROPIC_API_KEY OPENAI_API_KEY GEMINI_API_KEY XAI_API_KEY GROQ_API_KEY; do
  if [[ -z "${!key:-}" ]]; then MISSING_SECRETS+=("$key"); fi
done
if (( ${#MISSING_SECRETS[@]} > 0 )); then
  echo ""
  say "Checking for API keys..."
  warn "Missing API keys: ${MISSING_SECRETS[*]}"
  echo "Add GitHub repo secrets (recommended for CI and agents):"
  echo "Repo: $(git config --get remote.origin.url | sed 's#.*/##;s/.git$//')"
  echo "Commands:"
  for s in "${MISSING_SECRETS[@]}"; do
    echo "  gh secret set $s    # then paste the value when prompted"
  done
  echo "GitHub UI: Settings → Secrets and variables → Actions"
  # Offer to run gh commands interactively
  if has gh && [[ $NON_INTERACTIVE -eq 0 ]]; then
    read -rp "Run gh secret set for these now? (y/N): " g
    if [[ "${g,,}" == "y" ]]; then
      for s in "${MISSING_SECRETS[@]}"; do
        gh secret set "$s"
      done
    fi
  fi
  # Append to local example for reference
  if [[ -d . ]]; then
    if [[ ! -f .envrc.local.example ]]; then : > .envrc.local.example; fi
    {
      echo "# API keys (not committed)"
      for s in "${MISSING_SECRETS[@]}"; do echo "export $s=..."; done
    } >> .envrc.local.example
    say "  ✓ Added placeholders to .envrc.local.example"
  fi
fi

say "✓ Repository setup complete!"
echo ""
echo "📂 Repository location: $TARGET"
echo "💻 Open in VS Code: code \"$TARGET\""
echo ""
echo "📝 Available helper scripts:"
echo "  - scripts/repo_analysis.sh - Analyze repository structure"
echo "  - scripts/run_checks.sh - Run lint/typecheck/tests"
echo "  - scripts/open_pr.sh - Quick PR creation"
