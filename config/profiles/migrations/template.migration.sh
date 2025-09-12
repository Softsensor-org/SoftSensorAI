#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Migration template - copy this file to create new migrations
set -euo pipefail

# REQUIRED: Version this migration upgrades to
VERSION="0.0.0"

# REQUIRED: Description of what this migration does
DESCRIPTION="Template migration - update this description"

# Optional: Dependencies or requirements
REQUIRES_VERSION="0.0.0"  # Minimum version required before this migration

# Validation function - runs before migration
# Return 0 if ready to migrate, 1 if not
validate() {
  local current_version=$(get_current_version)

  # Check minimum version requirement
  if [[ -n "${REQUIRES_VERSION:-}" ]]; then
    if ! version_compare "$REQUIRES_VERSION" "$current_version"; then
      error "This migration requires version $REQUIRES_VERSION or higher"
      return 1
    fi
  fi

  # Add your validation logic here
  # Example: Check if required files exist
  # if [[ ! -f "profiles/skills/permissions-l1.json" ]]; then
  #   error "Required file not found"
  #   return 1
  # fi

  return 0
}

# Forward migration function
# Transforms profiles from previous version to VERSION
migrate_up() {
  info "Running migration: $DESCRIPTION"

  # Add your migration logic here
  # Examples:

  # 1. Update JSON files
  # if [[ -f "profiles/skills/permissions-l1.json" ]]; then
  #   jq '.new_field = "default_value"' profiles/skills/permissions-l1.json > tmp.json
  #   mv tmp.json profiles/skills/permissions-l1.json
  # fi

  # 2. Rename files
  # if [[ -f "profiles/old_name.yml" ]]; then
  #   mv profiles/old_name.yml profiles/new_name.yml
  # fi

  # 3. Create new directories
  # mkdir -p profiles/new_feature

  # 4. Update YAML files
  # for file in profiles/phases/*.yml; do
  #   # Add new configuration
  #   echo "new_setting: true" >> "$file"
  # done

  success "Migration complete"
  return 0
}

# Rollback function
# Reverts changes made by migrate_up
migrate_down() {
  info "Rolling back: $DESCRIPTION"

  # Add your rollback logic here
  # This should undo everything migrate_up did

  # Examples:

  # 1. Revert JSON changes
  # if [[ -f "profiles/skills/permissions-l1.json" ]]; then
  #   jq 'del(.new_field)' profiles/skills/permissions-l1.json > tmp.json
  #   mv tmp.json profiles/skills/permissions-l1.json
  # fi

  # 2. Restore renamed files
  # if [[ -f "profiles/new_name.yml" ]]; then
  #   mv profiles/new_name.yml profiles/old_name.yml
  # fi

  # 3. Remove created directories (if empty)
  # rmdir profiles/new_feature 2>/dev/null || true

  # 4. Remove added configuration
  # for file in profiles/phases/*.yml; do
  #   sed -i '/^new_setting:/d' "$file"
  # done

  success "Rollback complete"
  return 0
}

# Post-migration hook (optional)
# Runs after successful migration
post_migrate() {
  # Optional: Run any cleanup or notification tasks
  # Example: Clear caches, notify users, etc.
  return 0
}

# Post-rollback hook (optional)
# Runs after successful rollback
post_rollback() {
  # Optional: Run any cleanup after rollback
  return 0
}
