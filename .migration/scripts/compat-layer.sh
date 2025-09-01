#!/usr/bin/env bash
set -euo pipefail
source .migration/scripts/logger.sh

OUT_DIR=".migration/wrappers"
IN_PLACE=0

usage() {
  cat <<EOF
Usage: $0 [--in-place]

Generate backward-compatibility wrappers for legacy commands.
By default, writes wrappers under .migration/wrappers/. Use --in-place to overwrite originals.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --in-place) IN_PLACE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

target_path_for() {
  local p="$1"
  if [[ $IN_PLACE -eq 1 ]]; then
    echo "$p"
  else
    echo "$OUT_DIR/$p"
  fi
}

create_wrapper() {
  local old_script="$1"; shift
  local new_command="$1"; shift || true

  local target
  target="$(target_path_for "$old_script")"
  mkdir -p "$(dirname "$target")"
  cat > "$target" << EOF
#!/usr/bin/env bash
# Compatibility wrapper for $(basename "$old_script")
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "⚠️  DEPRECATION NOTICE" >&2
echo "This command has been moved to: devpilot $new_command" >&2
echo "Please update your scripts and workflows." >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
exec ./devpilot-new/devpilot $new_command "$@"
EOF
  chmod +x "$target"
  log_success "Wrapper created: $old_script -> devpilot $new_command (${IN_PLACE:+in-place} ${IN_PLACE==1:+'in-place'})"
}

create_all_wrappers() {
  create_wrapper "setup_all.sh" "install"
  create_wrapper "setup/repo_wizard.sh" "create project"
  create_wrapper "validation/validate_agents.sh" "audit"
  create_wrapper "setup/agents_global.sh" "pilot setup"

  for script in install/*.sh; do
    [[ -f "$script" ]] || continue
    local name
    name=$(basename "$script" .sh)
    create_wrapper "$script" "install --component $name"
  done

  for script in scripts/*.sh; do
    [[ -f "$script" ]] || continue
    local name
    name=$(basename "$script" .sh)
    create_wrapper "$script" "utils $name"
  done
}

main() {
  [[ $IN_PLACE -eq 1 ]] || mkdir -p "$OUT_DIR"
  create_all_wrappers
  if [[ $IN_PLACE -eq 1 ]]; then
    log_warn "In-place wrappers written. Review deprecation notices before committing."
  else
    log_info "Wrappers written to $OUT_DIR (non-destructive)."
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

