#!/usr/bin/env bash
set -euo pipefail
say(){ printf "\033[1;36m==> %s\033[0m\n" "$*"; }
warn(){ printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err(){ printf "\033[1;31m[err]\033[0m %s\n" "$*"; }
has(){ command -v "$1" >/dev/null 2>&1; }

LITE=0; NO_HOOKS=0; NO_SCRIPTS=0; NO_BOOTSTRAP=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lite) LITE=1; NO_HOOKS=1; NO_SCRIPTS=1; shift;;
    --no-hooks) NO_HOOKS=1; shift;;
    --no-scripts) NO_SCRIPTS=1; shift;;
    --no-bootstrap) NO_BOOTSTRAP=1; shift;;
    *) break;;
  esac
done

require_tools(){ local m=(); for t in git gh curl jq; do has "$t" || m+=("$t"); done; ((${#m[@]})) && { err "Missing: ${m[*]}"; exit 1; }; }
ensure_dir(){ mkdir -p "$1"; }
to_ssh_url(){ local u="$1"; if [[ "$u" =~ ^https?://github\.com/([^/]+)/([^/]+?)(\.git)?$ ]]; then echo "git@github.com:${BASH_REMATCH[1]}/${BASH_REMATCH[2]}.git"; else echo "$u"; fi; }
select_menu(){ local PS3="Select a number: "; select opt in "$@"; do [[ -n "$opt" ]] && { echo "$opt"; return; }; echo "Invalid. Try again."; done; }

seed_defaults(){ ~/setup/agent_init_repo.sh --force 2>/dev/null || bash ~/setup/agent_init_repo.sh --force || true; }

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
    if command -v pnpm >/dev/null 2>&1 && [ -f pnpm-lock.yaml ]; then pnpm install; else npm ci || npm install; fi
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
mapfile -t ORGS < <(find "$BASE" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | sort)
if ((${#ORGS[@]}==0)); then warn "No orgs under $BASE."; read -rp "Enter new org slug (e.g., org1): " ORG
else say "Choose an org"; ORG=$(select_menu "${ORGS[@]}" "Create new…"); [[ "$ORG" == "Create new…" ]] && read -rp "Enter new org slug: " ORG; fi
SUBS=(backend frontend mobile infra ml ops data docs sandbox playground)
for s in "${SUBS[@]}"; do ensure_dir "$BASE/$ORG/$s"; done
say "Choose a category"; CAT=$(select_menu "${SUBS[@]}" "other")
[[ "$CAT" == "other" ]] && read -rp "Custom category: " CAT && ensure_dir "$BASE/$ORG/$CAT"

read -rp "GitHub URL (SSH or HTTPS): " GHURL_IN
URL="$(to_ssh_url "$GHURL_IN")"
DEF_NAME="$(basename -s .git "${URL##*:}")"
read -rp "Local repo folder name [${DEF_NAME}]: " RNAME; RNAME="${RNAME:-$DEF_NAME}"
read -rp "Branch to clone (optional): " BRANCH || true

TARGET="$BASE/$ORG/$CAT/$RNAME"
[ -e "$TARGET" ] && { warn "Path exists: $TARGET"; read -rp "Use anyway? (y/N): " C; [[ "${C,,}" == "y" ]] || { err "Abort."; exit 1; }; } || ensure_dir "$(dirname "$TARGET")"

say "Cloning → $TARGET"
if [ -n "${BRANCH:-}" ]; then git clone --branch "$BRANCH" --single-branch "$URL" "$TARGET"; else git clone "$URL" "$TARGET"; fi
cd "$TARGET"

say "Seeding repo defaults"
# Use new unified repo agent setup script if available
if [ -x ~/setup/setup_agents_repo.sh ]; then
  ~/setup/setup_agents_repo.sh --force
else
  # Fallback to old method if new script not found
  seed_defaults
fi
[[ "$LITE" -eq 1 || "$NO_HOOKS" -eq 1 ]] || { say "Installing commit sanitizer hook"; install_commit_sanitizer; }
[[ "$LITE" -eq 1 || "$NO_SCRIPTS" -eq 1 ]] || { say "Dropping helper scripts"; seed_helper_scripts; }
[[ "$NO_BOOTSTRAP" -eq 1 ]] || { say "Bootstrapping deps"; bootstrap_env; }

say "Done."
echo "Open in VS Code: code \"$TARGET\""
echo "Try: scripts/repo_analysis.sh  ·  scripts/run_checks.sh  ·  scripts/open_pr.sh"
