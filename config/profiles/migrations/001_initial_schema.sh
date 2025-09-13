#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Initial profile schema setup
set -euo pipefail

VERSION="1.0.0"
DESCRIPTION="Initial profile schema with skills and phases"

validate() {
  # Check if profiles directory exists
  if [[ ! -d "profiles" ]]; then
    error "Profiles directory not found"
    return 1
  fi
  return 0
}

migrate_up() {
  info "Setting up initial profile schema v1.0.0"

  # Create directory structure
  mkdir -p profiles/{skills,phases,personas,schemas}

  # Create version marker
  echo "1.0.0" > profiles/.version

  # Create initial schema file
  cat > profiles/schemas/v1.0.0.json <<'EOF'
{
  "version": "1.0.0",
  "description": "Initial SoftSensorAI profile schema",
  "profile": {
    "type": "object",
    "properties": {
      "skill": {
        "type": "string",
        "enum": ["l1", "l2", "l3"]
      },
      "phase": {
        "type": "string",
        "enum": ["poc", "mvp", "beta", "scale"]
      },
      "permissions": {
        "type": "object"
      }
    },
    "required": ["skill", "phase"]
  }
}
EOF

  # Link as current schema
  ln -sf v1.0.0.json profiles/schemas/current.json

  success "Initial schema created"
  return 0
}

migrate_down() {
  info "Removing initial schema"

  # This is the first migration, so rollback means removing everything
  rm -f profiles/.version
  rm -f profiles/schemas/v1.0.0.json
  rm -f profiles/schemas/current.json

  # Remove directories if empty
  rmdir profiles/schemas 2>/dev/null || true
  rmdir profiles/personas 2>/dev/null || true
  rmdir profiles/phases 2>/dev/null || true
  rmdir profiles/skills 2>/dev/null || true

  warning "Rolled back to pre-migration state"
  return 0
}
