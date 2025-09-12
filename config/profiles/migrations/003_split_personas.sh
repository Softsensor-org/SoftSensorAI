#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Split monolithic personas into individual files
set -euo pipefail

VERSION="1.2.0"
DESCRIPTION="Split personas into separate configurable files"
REQUIRES_VERSION="1.1.0"

validate() {
  local current_version=$(get_current_version)

  if ! version_compare "$REQUIRES_VERSION" "$current_version"; then
    error "This migration requires version $REQUIRES_VERSION or higher"
    return 1
  fi

  return 0
}

migrate_up() {
  info "Splitting personas into individual files"

  # Create personas directory structure
  mkdir -p profiles/personas/{individual,combined}

  # Check if monolithic personas file exists
  if [[ -f "profiles/personas.json" ]]; then
    # Split existing personas file
    jq -r '.personas | keys[]' profiles/personas.json | while read persona; do
      jq ".personas[\"$persona\"]" profiles/personas.json > "profiles/personas/individual/${persona}.json"
      info "Created individual persona: ${persona}.json"
    done

    # Backup original file
    mv profiles/personas.json profiles/personas/.personas.json.backup
  else
    # Create default personas
    cat > profiles/personas/individual/pragmatic-coder.json <<'EOF'
{
  "name": "pragmatic-coder",
  "description": "Balanced, production-focused developer",
  "traits": [
    "Focus on working solutions",
    "Prefer established patterns",
    "Value maintainability"
  ],
  "guidelines": {
    "code_style": "clean and readable",
    "testing": "practical coverage",
    "documentation": "essential only"
  }
}
EOF

    cat > profiles/personas/individual/software-architect.json <<'EOF'
{
  "name": "software-architect",
  "description": "System design and architecture focus",
  "traits": [
    "Think in systems",
    "Design for scale",
    "Consider trade-offs"
  ],
  "guidelines": {
    "code_style": "modular and extensible",
    "testing": "integration and contract",
    "documentation": "architecture decisions"
  }
}
EOF

    cat > profiles/personas/individual/data-scientist.json <<'EOF'
{
  "name": "data-scientist",
  "description": "Data analysis and ML focus",
  "traits": [
    "Data-driven decisions",
    "Statistical rigor",
    "Reproducible research"
  ],
  "guidelines": {
    "code_style": "notebook-friendly",
    "testing": "data validation",
    "documentation": "methodology and results"
  }
}
EOF
    info "Created default personas"
  fi

  # Create persona combiner script
  cat > profiles/personas/combine.sh <<'EOF'
#!/usr/bin/env bash
# Combine selected personas into active profile
set -euo pipefail

selected_personas=("$@")
output="profiles/personas/combined/active.json"

mkdir -p profiles/personas/combined

echo '{"personas": [' > "$output"
first=true
for persona in "${selected_personas[@]}"; do
  if [[ -f "profiles/personas/individual/${persona}.json" ]]; then
    [[ "$first" == "false" ]] && echo "," >> "$output"
    cat "profiles/personas/individual/${persona}.json" >> "$output"
    first=false
  fi
done
echo ']}' >> "$output"

echo "Combined personas: ${selected_personas[*]}"
EOF
  chmod +x profiles/personas/combine.sh

  # Update schema
  cat > profiles/schemas/v1.2.0.json <<'EOF'
{
  "version": "1.2.0",
  "description": "Split personas into individual files",
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
        "type": "boolean"
      },
      "personas": {
        "type": "array",
        "items": {
          "type": "string"
        },
        "description": "List of active personas"
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
  ln -sf v1.2.0.json profiles/schemas/current.json

  success "Personas split into individual files"
  return 0
}

migrate_down() {
  info "Reverting persona split"

  # Reconstruct monolithic personas file
  if [[ -d "profiles/personas/individual" ]]; then
    echo '{"personas": {' > profiles/personas.json

    first=true
    for persona_file in profiles/personas/individual/*.json; do
      if [[ -f "$persona_file" ]]; then
        persona_name=$(basename "$persona_file" .json)
        [[ "$first" == "false" ]] && echo "," >> profiles/personas.json
        echo "\"$persona_name\":" >> profiles/personas.json
        cat "$persona_file" >> profiles/personas.json
        first=false
      fi
    done

    echo '}}' >> profiles/personas.json
    info "Reconstructed monolithic personas.json"
  elif [[ -f "profiles/personas/.personas.json.backup" ]]; then
    # Restore from backup
    mv profiles/personas/.personas.json.backup profiles/personas.json
    info "Restored original personas.json from backup"
  fi

  # Remove split structure
  rm -rf profiles/personas/individual
  rm -rf profiles/personas/combined
  rm -f profiles/personas/combine.sh

  # Restore previous schema
  ln -sf v1.1.0.json profiles/schemas/current.json
  rm -f profiles/schemas/v1.2.0.json

  success "Reverted to monolithic personas"
  return 0
}
