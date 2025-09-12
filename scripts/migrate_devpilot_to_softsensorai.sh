#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Migrate DevPilot → SoftSensorAI (brand, env, paths, entrypoints)
# - Dry-run by default. Use --execute to apply.
# - BSD/macOS & GNU safe. Requires: bash, sed, git (optional).
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

DRY=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --execute) DRY=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help)
      cat <<H
Usage: $0 [--dry-run|--execute]
Actions (idempotent):
  • Add brand compat shim (lib/sh/brand_compat.sh)
  • Add SoftSensorAI entrypoints: bin/ss, bin/ss-agent, bin/ss-apiize, bin/ss-testgen
  • Update bin/dp to source brand_compat.sh
  • Create multi-user symlinks /opt/devpilot ⇄ /opt/softsensorai (if permitted)
  • Update docs branding (safe-scope replacements in docs/*.md only)
H
      exit 0
      ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
done

say(){ printf "• %s\n" "$*"; }
do_or_echo(){ if [ "$DRY" -eq 1 ]; then echo "DRY: $*"; else "$@"; fi; }

ensure_file(){
  local path="$1" content="$2"
  if [ -f "$path" ]; then say "exists: $path"; return; fi
  say "create: $path"
  if [ "$DRY" -eq 0 ]; then mkdir -p "$(dirname "$path")"; printf "%s" "$content" > "$path"; chmod +x "$path"; fi
}

# 1) Brand compat shim ----------------------------------------------------------
COMPAT="$ROOT/lib/sh/brand_compat.sh"
COMPAT_CONTENT='#!/usr/bin/env bash
# Brand compatibility: DevPilot ↔ SoftSensorAI
# Always source this early inside bin/dp and other entrypoints.
# Env mapping (new takes precedence; old kept for compat):
: "${SOFTSENSORAI_ROOT:=${DEVPILOT_ROOT:-}}"
: "${SOFTSENSORAI_USER_DIR:=${DEVPILOT_USER_DIR:-}}"
: "${SOFTSENSORAI_ARTIFACTS:=${DEVPILOT_ARTIFACTS:-}}"

# Back-fill old envs if only new is set (for callers that still read DEVPILOT_*):
export DEVPILOT_ROOT="${DEVPILOT_ROOT:-$SOFTSENSORAI_ROOT}"
export DEVPILOT_USER_DIR="${DEVPILOT_USER_DIR:-$SOFTSENSORAI_USER_DIR}"
export DEVPILOT_ARTIFACTS="${DEVPILOT_ARTIFACTS:-$SOFTSENSORAI_ARTIFACTS}"

# Resolve brand root (repo-local vs multi-user)
brand_resolve_root() {
  if [ -f "/opt/devpilot/etc/devpilot.conf" ] || [ -f "/opt/softsensorai/etc/softsensorai.conf" ]; then
    # Prefer SoftSensorAI conf if present
    if [ -f "/opt/softsensorai/etc/softsensorai.conf" ]; then
      # shellcheck disable=SC1091
      . /opt/softsensorai/etc/softsensorai.conf
      echo "${SOFTSENSORAI_ROOT:-/opt/softsensorai}"
    else
      # shellcheck disable=SC1091
      . /opt/devpilot/etc/devpilot.conf
      echo "${DEVPILOT_ROOT:-/opt/devpilot}"
    fi
  else
    git rev-parse --show-toplevel 2>/dev/null || pwd
  fi
}

brand_resolve_artifacts() {
  local root_user="${SOFTSENSORAI_USER_DIR:-$DEVPILOT_USER_DIR}"
  if [ -n "$root_user" ]; then
    echo "${SOFTSENSORAI_ARTIFACTS:-$DEVPILOT_ARTIFACTS:-$root_user/artifacts}"
  else
    echo "./artifacts"
  fi
}
'
ensure_file "$COMPAT" "$COMPAT_CONTENT"

# 2) Patch bin/dp to source compat shim ----------------------------------------
if grep -q 'brand_compat.sh' "$ROOT/bin/dp" 2>/dev/null; then
  say "bin/dp already sources brand_compat.sh"
else
  say "patch: bin/dp (source brand_compat.sh)"
  if [ "$DRY" -eq 0 ]; then
    # insert after shebang
    awk 'NR==1{print; print ". \"$(dirname \"$0\")/../lib/sh/brand_compat.sh\""; next}1' "$ROOT/bin/dp" > "$ROOT/bin/dp.tmp"
    mv "$ROOT/bin/dp.tmp" "$ROOT/bin/dp"
    chmod +x "$ROOT/bin/dp"
  fi
fi

# 3) Add new SoftSensorAI entrypoints (thin wrappers) --------------------------
WRAP='#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Prefer new brand if present; fallback to dp
if [ -x "$DIR/dp-${0##*/ss}" ]; then exec "$DIR/dp-${0##*/ss}" "$@"; fi
if [ -x "$DIR/dp" ] && [ "${0##*/}" = "ss" ]; then exec "$DIR/dp" "$@"; fi
echo "error: dp not found near $DIR"; exit 127
'
ensure_file "$ROOT/bin/ss"         "$WRAP"
ensure_file "$ROOT/bin/ss-agent"   "$WRAP"
ensure_file "$ROOT/bin/ss-apiize"  "$WRAP"
ensure_file "$ROOT/bin/ss-testgen" "$WRAP"

# 4) Multi-user symlinks (best effort; may require sudo) -----------------------
link_safe(){
  local src="$1" dst="$2"
  [ -e "$src" ] || return 0
  if [ -L "$dst" ] || [ -e "$dst" ]; then return 0; fi
  do_or_echo "ln -snf \"$src\" \"$dst\""
}

say "Multi-user symlinks (best effort):"
# /opt/devpilot → /opt/softsensorai and vice versa (non-destructive)
link_safe "/opt/devpilot" "/opt/softsensorai"
link_safe "/opt/softsensorai" "/opt/devpilot"

# 5) Docs safe-scope replacements (brand only in docs/) ------------------------
say "Docs brand updates (DevPilot → SoftSensorAI) in docs/*.md"
if [ "$DRY" -eq 0 ]; then
  # Use portable sed for both BSD and GNU
  find docs -type f -name "*.md" 2>/dev/null | while read -r file; do
    if grep -q "DevPilot" "$file"; then
      sed 's/\bDevPilot\b/SoftSensorAI/g' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      say "  updated: $file"
    fi
  done
fi

say "Done. $( [ $DRY -eq 1 ] && echo "DRY RUN: no changes written" || echo "Changes applied" )"
