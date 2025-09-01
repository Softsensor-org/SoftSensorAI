#!/usr/bin/env bash
set -euo pipefail
source .migration/scripts/logger.sh

MIGRATION_MAP=".migration/state/migration-map.json"
TARGET_ROOT="devpilot-new"

ensure_prereqs() {
  [[ -f "$MIGRATION_MAP" ]] || { log_error "Missing $MIGRATION_MAP"; exit 1; }
  command -v jq >/dev/null 2>&1 || { log_error "jq is required"; exit 1; }
}

apply_transformations() {
  local src="$1"; shift
  local -a transforms=("$@")
  # Stub: no-op for now, placeholder for future scripted transforms
  for t in "${transforms[@]}"; do
    log_info "Applying transform '$t' to $src (stub)"
  done
}

copy_item() {
  local source_path="$1"
  local dest_rel="$2"
  local transforms_json="$3"

  local dest_path="$TARGET_ROOT/$dest_rel"
  if [[ -d "$source_path" ]]; then
    mkdir -p "$dest_path"
    rsync -a --exclude ".git" "$source_path" "$dest_path/.." >/dev/null 2>&1 || cp -r "$source_path" "$dest_path/.."
    log_success "Directory migrated: $source_path -> $dest_path"
  else
    mkdir -p "$(dirname "$dest_path")"
    cp "$source_path" "$dest_path"
    log_success "File migrated: $source_path -> $dest_path"
  fi

  # Apply transformations (names only; actual scripts TBD)
  mapfile -t transforms < <(echo "$transforms_json" | jq -r '.[]?')
  if [[ ${#transforms[@]} -gt 0 ]]; then
    apply_transformations "$source_path" "${transforms[@]}"
  fi
}

create_checkpoint() {
  local name="$1"
  local checkpoint_dir=".migration/rollback/checkpoint_$name"
  log_info "Creating checkpoint: $name"
  mkdir -p "$checkpoint_dir"
  cp -r "$TARGET_ROOT" "$checkpoint_dir/" 2>/dev/null || true
  cp .migration/state/*.json "$checkpoint_dir/" 2>/dev/null || true
  echo "$name" >> .migration/state/checkpoints.txt
  log_success "Checkpoint created: $name"
}

main() {
  ensure_prereqs
  log_info "Starting migration executor"

  local total items
  total=$(jq '.migrations | length' "$MIGRATION_MAP")
  log_info "Items to migrate: $total"

  for i in $(seq 0 $((total-1))); do
    local src dst transforms
    src=$(jq -r ".migrations[$i].source" "$MIGRATION_MAP")
    dst=$(jq -r ".migrations[$i].destination" "$MIGRATION_MAP")
    transforms=$(jq -c ".migrations[$i].transform // []" "$MIGRATION_MAP")

    if [[ -e "$src" ]]; then
      copy_item "$src" "$dst" "$transforms"
    else
      log_warn "Source not found, skipping: $src"
    fi
  done

  create_checkpoint "phase3_post_migrate"
  log_success "Migration executor finished"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

