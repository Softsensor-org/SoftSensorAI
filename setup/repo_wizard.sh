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
  --help               Show this help message

Examples:
  # Interactive mode
  $0

  # Non-interactive clone
  $0 --non-interactive --org myorg --category backend --url git@github.com:user/repo.git

  # With all options
  $0 --non-interactive --org acme --category frontend \\
     --url https://github.com/acme/webapp --branch develop --name webapp-dev --lite
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lite) LITE=1; NO_HOOKS=1; NO_SCRIPTS=1; shift;;
    --no-hooks) NO_HOOKS=1; shift;;
    --no-scripts) NO_SCRIPTS=1; shift;;
    --no-bootstrap) NO_BOOTSTRAP=1; shift;;
    --with-codex) WITH_CODEX=1; shift;;
    --non-interactive) NON_INTERACTIVE=1; shift;;
    --org) ORG="$2"; shift 2;;
    --category|--cat) CAT="$2"; shift 2;;
    --url) GHURL_IN="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    --name) RNAME="$2"; shift 2;;
    --skill) P_SKILL="$2"; shift 2;;
    --phase) P_PHASE="$2"; shift 2;;
    --teach-mode) P_TEACH="$2"; shift 2;;
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
  local m=(); for t in git gh curl jq; do has "$t" || m+=("$t"); done
  ((${#m[@]})) && { err "Missing required tools: ${m[*]}"; echo "Install with: ./install_key_software_wsl.sh"; exit 1; }
}
ensure_dir(){ mkdir -p "$1"; }
to_ssh_url(){ local u="$1"; if [[ "$u" =~ ^https?://github\.com/([^/]+)/([^/]+?)(\.git)?$ ]]; then echo "git@github.com:${BASH_REMATCH[1]}/${BASH_REMATCH[2]}.git"; else echo "$u"; fi; }
select_menu(){ local PS3="Select a number: "; select opt in "$@"; do [[ -n "$opt" ]] && { echo "$opt"; return; }; echo "Invalid. Try again."; done; }

seed_defaults(){ "$SCRIPT_DIR/setup/agents_repo.sh" --force || true; }

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
    say "Installing Node deps"
    if [ -f pnpm-lock.yaml ]; then
      if command -v pnpm >/dev/null 2>&1; then pnpm install; else err "pnpm required by pnpm-lock.yaml but not installed"; exit 1; fi
    else
      if command -v pnpm >/dev/null 2>&1; then pnpm install; else npm ci || npm install; fi
    fi
  fi
  if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    say "Setting up Python venv (.venv)"
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

# main
require_tools
BASE="$HOME/projects"; ensure_dir "$BASE"
if [[ -z "$ORG" ]]; then
  mapfile -t ORGS < <(find "$BASE" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort)
  if ((${#ORGS[@]}==0)); then warn "No orgs under $BASE."; read -rp "Enter new org slug (e.g., org1): " ORG
  else say "Choose an org"; ORG=$(select_menu "${ORGS[@]}" "Create new…"); [[ "$ORG" == "Create new…" ]] && read -rp "Enter new org slug: " ORG; fi
fi
SUBS=(backend frontend mobile infra ml ops data docs sandbox playground)
for s in "${SUBS[@]}"; do ensure_dir "$BASE/$ORG/$s"; done
if [[ -z "$CAT" ]]; then
  say "Choose a category"; CAT=$(select_menu "${SUBS[@]}" "other")
  [[ "$CAT" == "other" ]] && read -rp "Custom category: " CAT && ensure_dir "$BASE/$ORG/$CAT"
else
  ensure_dir "$BASE/$ORG/$CAT"
fi

if [[ -z "$GHURL_IN" ]]; then
  read -rp "GitHub URL (SSH or HTTPS): " GHURL_IN
fi
URL="$(to_ssh_url "$GHURL_IN")"
DEF_NAME="$(basename -s .git "${URL##*:}")"
if [[ -z "$RNAME" ]]; then
  read -rp "Local repo folder name [${DEF_NAME}]: " RNAME; RNAME="${RNAME:-$DEF_NAME}"
fi
if [[ -z "${BRANCH:-}" ]]; then
  read -rp "Branch to clone (optional): " BRANCH || true
fi

TARGET="$BASE/$ORG/$CAT/$RNAME"
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

say "Cloning → $TARGET"
if [ -n "${BRANCH:-}" ]; then git clone --branch "$BRANCH" --single-branch "$URL" "$TARGET"; else git clone "$URL" "$TARGET"; fi
cd "$TARGET"

say "Seeding repo defaults"
seed_defaults
[[ "$LITE" -eq 1 || "$NO_HOOKS" -eq 1 ]] || { say "Installing commit sanitizer hook"; install_commit_sanitizer; }
[[ "$LITE" -eq 1 || "$NO_SCRIPTS" -eq 1 ]] || { say "Dropping helper scripts"; seed_helper_scripts; }

# Add Codex integration if requested
if [[ "$WITH_CODEX" -eq 1 ]]; then
  say "Adding Codex CLI integration"
  
  # Copy sandbox script if available
  if [ -f "$SCRIPT_DIR/scripts/codex_sandbox.sh" ]; then
    mkdir -p scripts
    cp "$SCRIPT_DIR/scripts/codex_sandbox.sh" scripts/
    chmod +x scripts/codex_sandbox.sh
    echo "  ✓ Added scripts/codex_sandbox.sh"
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
      echo "  ✓ Added Codex targets to Makefile"
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
    echo "  ✓ Created Makefile with Codex targets"
  fi
  
  # Update Claude permissions to include Codex
  if [ -f .claude/settings.json ]; then
    # Add Codex permissions if not already present
    if ! grep -q "codex exec" .claude/settings.json; then
      jq '.permissions.allow += ["Bash(codex exec:*)", "Bash(scripts/codex_sandbox.sh:*)"]' .claude/settings.json > .claude/settings.json.tmp && \
        mv .claude/settings.json.tmp .claude/settings.json
      echo "  ✓ Updated Claude permissions for Codex"
    fi
  fi
fi

[[ "$NO_BOOTSTRAP" -eq 1 ]] || { say "Bootstrapping deps"; bootstrap_env; }

# Apply profile (with Beginner teach-mode prompt in interactive mode)
apply_profile_now="no"
if [[ $NON_INTERACTIVE -eq 1 ]]; then
  apply_profile_now="yes"
else
  read -rp "Apply a profile now? (Y/n): " ans
  [[ -z "$ans" || "${ans,,}" == "y" ]] && apply_profile_now="yes"
fi

if [[ "$apply_profile_now" == "yes" ]]; then
  skill="${P_SKILL:-beginner}"
  phase="${P_PHASE:-mvp}"
  teach="${P_TEACH:-}"

  if [[ $NON_INTERACTIVE -eq 0 ]]; then
    # If not specified, ask beginner teach-mode preference
    if [[ -z "$teach" && "$skill" == "beginner" ]]; then
      read -rp "Beginner teach mode (guided, verbose CoT)? (Y/n): " t
      if [[ -z "$t" || "${t,,}" == "y" ]]; then teach="on"; else teach="off"; fi
    fi
  else
    # Non-interactive default for beginner: teach on
    if [[ -z "$teach" && "$skill" == "beginner" ]]; then teach="on"; fi
  fi

  cmd=(scripts/apply_profile.sh --skill "$skill" --phase "$phase")
  [[ -n "$teach" ]] && cmd+=(--teach-mode "$teach")
  say "Applying profile: skill=$skill phase=$phase teach=${teach:-auto}"
  "${cmd[@]}"
fi

# Secrets guidance (print instructions and optional gh setup)
MISSING_SECRETS=()
for key in ANTHROPIC_API_KEY OPENAI_API_KEY GEMINI_API_KEY XAI_API_KEY GROQ_API_KEY; do
  if [[ -z "${!key:-}" ]]; then MISSING_SECRETS+=("$key"); fi
done
if (( ${#MISSING_SECRETS[@]} > 0 )); then
  say "Detected missing API keys: ${MISSING_SECRETS[*]}"
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
    echo "  ✓ Added placeholders to .envrc.local.example"
  fi
fi

say "Done."
echo "Open in VS Code: code \"$TARGET\""
echo "Try: scripts/repo_analysis.sh  ·  scripts/run_checks.sh  ·  scripts/open_pr.sh"
