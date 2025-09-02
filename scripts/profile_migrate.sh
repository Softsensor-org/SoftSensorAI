#!/usr/bin/env bash
# Profile migration system - handles versioning and migrations for profiles
set -euo pipefail

# Configuration
PROFILES_DIR="${PROFILES_DIR:-profiles}"
MIGRATIONS_DIR="$PROFILES_DIR/migrations"
VERSION_FILE="$PROFILES_DIR/.version"
BACKUP_DIR="$PROFILES_DIR/.backups"
LOCK_FILE="$PROFILES_DIR/.migration.lock"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
say() { echo -e "${1:-}${2:-}${NC}"; }
info() { say "$BLUE" "ℹ️  $1"; }
success() { say "$GREEN" "✅ $1"; }
warning() { say "$YELLOW" "⚠️  $1"; }
error() { say "$RED" "❌ $1"; }

# Get current version
get_current_version() {
  if [[ -f "$VERSION_FILE" ]]; then
    cat "$VERSION_FILE"
  else
    echo "0.0.0"
  fi
}

# Set current version
set_current_version() {
  local version="$1"
  echo "$version" > "$VERSION_FILE"
  success "Set profile version to $version"
}

# Compare versions (returns 0 if v1 <= v2)
version_compare() {
  local v1="$1"
  local v2="$2"

  # Convert versions to comparable format
  IFS='.' read -ra v1_parts <<< "$v1"
  IFS='.' read -ra v2_parts <<< "$v2"

  for i in {0..2}; do
    local p1="${v1_parts[$i]:-0}"
    local p2="${v2_parts[$i]:-0}"

    if [[ "$p1" -lt "$p2" ]]; then
      return 0
    elif [[ "$p1" -gt "$p2" ]]; then
      return 1
    fi
  done

  return 0
}

# List available migrations
list_migrations() {
  find "$MIGRATIONS_DIR" -name "*.sh" -type f | grep -v template | sort
}

# Get migration version
get_migration_version() {
  local migration_file="$1"
  # shellcheck source=/dev/null
  source "$migration_file"
  echo "${VERSION:-unknown}"
}

# Create backup
create_backup() {
  local version="$1"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_name="${version}_${timestamp}"

  mkdir -p "$BACKUP_DIR"

  info "Creating backup: $backup_name"

  # Backup current profiles
  tar -czf "$BACKUP_DIR/${backup_name}.tar.gz" \
    --exclude=".backups" \
    --exclude=".migration.lock" \
    -C "$PROFILES_DIR" . 2>/dev/null || true

  success "Backup created: $BACKUP_DIR/${backup_name}.tar.gz"
}

# Restore backup
restore_backup() {
  local backup_file="$1"

  if [[ ! -f "$backup_file" ]]; then
    error "Backup file not found: $backup_file"
    return 1
  fi

  info "Restoring from backup: $backup_file"

  # Clear current profiles (except backups)
  find "$PROFILES_DIR" -mindepth 1 -maxdepth 1 \
    -not -name ".backups" \
    -not -name ".migration.lock" \
    -exec rm -rf {} + 2>/dev/null || true

  # Restore from backup
  tar -xzf "$backup_file" -C "$PROFILES_DIR"

  success "Restored from backup"
}

# Acquire migration lock
acquire_lock() {
  local max_wait=30
  local waited=0

  while [[ -f "$LOCK_FILE" ]] && [[ $waited -lt $max_wait ]]; do
    warning "Waiting for migration lock..."
    sleep 1
    ((waited++))
  done

  if [[ -f "$LOCK_FILE" ]]; then
    error "Could not acquire migration lock after ${max_wait}s"
    exit 1
  fi

  echo "$$" > "$LOCK_FILE"
}

# Release migration lock
release_lock() {
  rm -f "$LOCK_FILE"
}

# Run migration up
migrate_up() {
  local target_version="${1:-latest}"
  local dry_run="${2:-false}"
  local current_version=$(get_current_version)

  info "Current version: $current_version"

  # Get applicable migrations
  local migrations=()
  for migration in $(list_migrations); do
    local mig_version=$(get_migration_version "$migration")

    if version_compare "$current_version" "$mig_version" && \
       [[ "$current_version" != "$mig_version" ]]; then

      if [[ "$target_version" == "latest" ]] || \
         version_compare "$mig_version" "$target_version"; then
        migrations+=("$migration")
      fi
    fi
  done

  if [[ ${#migrations[@]} -eq 0 ]]; then
    success "Already at target version"
    return 0
  fi

  info "Found ${#migrations[@]} migration(s) to apply"

  if [[ "$dry_run" == "true" ]]; then
    warning "DRY RUN - No changes will be made"
  fi

  for migration in "${migrations[@]}"; do
    local mig_version=$(get_migration_version "$migration")
    local mig_name=$(basename "$migration")

    echo ""
    info "Applying migration: $mig_name (→ $mig_version)"

    if [[ "$dry_run" == "false" ]]; then
      # Create backup before migration
      create_backup "$current_version"

      # Source and run migration
      # shellcheck source=/dev/null
      source "$migration"

      # Validate before running
      if declare -f validate >/dev/null; then
        if ! validate; then
          error "Migration validation failed"
          return 1
        fi
      fi

      # Run migration
      if declare -f migrate_up >/dev/null; then
        if migrate_up; then
          success "Migration applied successfully"
          set_current_version "$mig_version"
          current_version="$mig_version"
        else
          error "Migration failed - restoring from backup"
          restore_backup "$BACKUP_DIR/$(ls -t "$BACKUP_DIR" | head -1)"
          return 1
        fi
      else
        error "No migrate_up function in migration"
        return 1
      fi
    else
      echo "  Would apply: ${DESCRIPTION:-No description}"
    fi
  done

  echo ""
  success "Migration complete! New version: $(get_current_version)"
}

# Run migration down (rollback)
migrate_down() {
  local target_version="${1:-previous}"
  local dry_run="${2:-false}"
  local current_version=$(get_current_version)

  info "Current version: $current_version"

  # Get applicable migrations (in reverse)
  local migrations=()
  for migration in $(list_migrations | sort -r); do
    local mig_version=$(get_migration_version "$migration")

    if version_compare "$mig_version" "$current_version" && \
       [[ "$current_version" != "$mig_version" ]]; then
      continue
    fi

    if [[ "$target_version" == "previous" ]]; then
      migrations+=("$migration")
      break
    elif version_compare "$target_version" "$mig_version"; then
      migrations+=("$migration")
    fi
  done

  if [[ ${#migrations[@]} -eq 0 ]]; then
    warning "No migrations to rollback"
    return 0
  fi

  info "Found ${#migrations[@]} migration(s) to rollback"

  if [[ "$dry_run" == "true" ]]; then
    warning "DRY RUN - No changes will be made"
  fi

  for migration in "${migrations[@]}"; do
    local mig_version=$(get_migration_version "$migration")
    local mig_name=$(basename "$migration")

    echo ""
    info "Rolling back migration: $mig_name (← $mig_version)"

    if [[ "$dry_run" == "false" ]]; then
      # Create backup before rollback
      create_backup "$current_version"

      # Source and run rollback
      # shellcheck source=/dev/null
      source "$migration"

      if declare -f migrate_down >/dev/null; then
        if migrate_down; then
          success "Rollback successful"

          # Find previous version
          local prev_version="0.0.0"
          for m in $(list_migrations | sort); do
            local v=$(get_migration_version "$m")
            if version_compare "$v" "$mig_version" && [[ "$v" != "$mig_version" ]]; then
              prev_version="$v"
            fi
          done

          set_current_version "$prev_version"
          current_version="$prev_version"
        else
          error "Rollback failed"
          return 1
        fi
      else
        error "No migrate_down function in migration"
        return 1
      fi
    else
      echo "  Would rollback: ${DESCRIPTION:-No description}"
    fi
  done

  echo ""
  success "Rollback complete! New version: $(get_current_version)"
}

# Show migration status
show_status() {
  local current_version=$(get_current_version)

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  PROFILE MIGRATION STATUS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Current Version: $current_version"
  echo ""
  echo "  Available Migrations:"
  echo "  ────────────────────"

  for migration in $(list_migrations); do
    local mig_version=$(get_migration_version "$migration")
    local mig_name=$(basename "$migration" .sh)

    # shellcheck source=/dev/null
    source "$migration"
    local desc="${DESCRIPTION:-No description}"

    if version_compare "$current_version" "$mig_version" && \
       [[ "$current_version" != "$mig_version" ]]; then
      echo "  ⬜ $mig_version - $desc"
    elif [[ "$current_version" == "$mig_version" ]]; then
      echo "  ✅ $mig_version - $desc (current)"
    else
      echo "  ✅ $mig_version - $desc"
    fi
  done

  echo ""
  echo "  Backups:"
  echo "  ────────"
  if [[ -d "$BACKUP_DIR" ]]; then
    local backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
    echo "  📦 $backup_count backup(s) available"
    if [[ $backup_count -gt 0 ]]; then
      echo ""
      ls -lh "$BACKUP_DIR" | tail -n +2 | head -5 | awk '{print "     " $NF " (" $5 ")"}'
    fi
  else
    echo "  No backups yet"
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Main command handler
main() {
  local command="${1:-status}"
  shift || true

  # Ensure migrations directory exists
  mkdir -p "$MIGRATIONS_DIR"

  case "$command" in
    up)
      acquire_lock
      trap release_lock EXIT

      local target="latest"
      local dry_run="false"

      # Parse arguments
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --dry-run)
            dry_run="true"
            shift
            ;;
          *)
            target="$1"
            shift
            ;;
        esac
      done

      migrate_up "$target" "$dry_run"
      ;;

    down)
      acquire_lock
      trap release_lock EXIT

      local target="previous"
      local dry_run="false"

      # Parse arguments
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --dry-run)
            dry_run="true"
            shift
            ;;
          *)
            target="$1"
            shift
            ;;
        esac
      done

      migrate_down "$target" "$dry_run"
      ;;

    status)
      show_status
      ;;

    create)
      local name="${1:-}"
      if [[ -z "$name" ]]; then
        error "Migration name required"
        echo "Usage: $0 create <name>"
        exit 1
      fi

      # Create new migration from template
      local number=$(printf "%03d" $(($(ls -1 "$MIGRATIONS_DIR" | wc -l) + 1)))
      local filename="${number}_${name}.sh"

      cp "$MIGRATIONS_DIR/template.migration.sh" "$MIGRATIONS_DIR/$filename"
      success "Created migration: $MIGRATIONS_DIR/$filename"
      echo "Edit the file to implement your migration"
      ;;

    list)
      echo "Available migrations:"
      for migration in $(list_migrations); do
        local mig_version=$(get_migration_version "$migration")
        local mig_name=$(basename "$migration")
        echo "  $mig_version - $mig_name"
      done
      ;;

    help|--help|-h)
      cat <<EOF
Profile Migration System

Usage: $0 <command> [options]

Commands:
  status          Show current version and available migrations
  up [version]    Migrate up to version (default: latest)
  down [version]  Migrate down to version (default: previous)
  create <name>   Create new migration from template
  list            List all available migrations
  help            Show this help message

Options:
  --dry-run       Show what would be done without making changes

Examples:
  $0 status                    # Show current status
  $0 up                        # Migrate to latest version
  $0 up 1.2.0                  # Migrate to specific version
  $0 down                      # Rollback one version
  $0 down 1.0.0                # Rollback to specific version
  $0 up --dry-run              # Preview migration without changes
  $0 create add_new_feature    # Create new migration
EOF
      ;;

    *)
      error "Unknown command: $command"
      echo "Run '$0 help' for usage"
      exit 1
      ;;
  esac
}

# Run main function
main "$@"
