#!/usr/bin/env bash
# Add teach_mode configuration to profiles
set -euo pipefail

VERSION="1.1.0"
DESCRIPTION="Add teach_mode configuration for learning assistance"
REQUIRES_VERSION="1.0.0"

validate() {
  local current_version=$(get_current_version)

  if ! version_compare "$REQUIRES_VERSION" "$current_version"; then
    error "This migration requires version $REQUIRES_VERSION or higher"
    return 1
  fi

  # Check if skill files exist
  if [[ ! -f "profiles/skills/permissions-l1.json" ]]; then
    warning "Skill files not found, will be created"
  fi

  return 0
}

migrate_up() {
  info "Adding teach_mode configuration"

  # Update all skill level files to include teach_mode
  for level in l1 l2 l3; do
    local file="profiles/skills/permissions-${level}.json"

    if [[ -f "$file" ]]; then
      # Add teach_mode to existing file
      jq --arg teach "$([[ "$level" == "l1" ]] && echo "true" || echo "false")" \
        '.teach_mode = ($teach == "true")' "$file" > tmp.json
      mv tmp.json "$file"
      info "Updated $file with teach_mode"
    else
      # Create new file with teach_mode
      local teach_value="false"
      [[ "$level" == "l1" ]] && teach_value="true"

      cat > "$file" <<EOF
{
  "level": "$level",
  "teach_mode": $teach_value,
  "permissions": {
    "file_write": $([[ "$level" == "l3" ]] && echo "true" || echo "false"),
    "shell_execute": $([[ "$level" != "l1" ]] && echo "true" || echo "false"),
    "system_modify": false
  }
}
EOF
      info "Created $file with teach_mode"
    fi
  done

  # Update schema
  cat > profiles/schemas/v1.1.0.json <<'EOF'
{
  "version": "1.1.0",
  "description": "Added teach_mode configuration",
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
      "teach_mode": {
        "type": "boolean",
        "description": "Enable teaching explanations for learning"
      },
      "permissions": {
        "type": "object"
      }
    },
    "required": ["skill", "phase"]
  }
}
EOF

  # Update current schema link
  ln -sf v1.1.0.json profiles/schemas/current.json

  success "teach_mode configuration added"
  return 0
}

migrate_down() {
  info "Removing teach_mode configuration"

  # Remove teach_mode from skill files
  for level in l1 l2 l3; do
    local file="profiles/skills/permissions-${level}.json"

    if [[ -f "$file" ]]; then
      jq 'del(.teach_mode)' "$file" > tmp.json
      mv tmp.json "$file"
      info "Removed teach_mode from $file"
    fi
  done

  # Restore previous schema link
  ln -sf v1.0.0.json profiles/schemas/current.json

  # Remove new schema file
  rm -f profiles/schemas/v1.1.0.json

  success "Rolled back teach_mode changes"
  return 0
}
