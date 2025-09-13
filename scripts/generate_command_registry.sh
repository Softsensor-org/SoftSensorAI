#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Generate Command Registry from Justfile and scripts
# Creates a searchable command palette for SoftSensorAI
set -euo pipefail

# Parse arguments
SHOW_INTERNAL=false
OUTPUT="commands.md"
JSON_OUTPUT="commands.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --internal)
      SHOW_INTERNAL=true
      shift
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    --json)
      JSON_OUTPUT="$2"
      shift 2
      ;;
    *)
      OUTPUT="${1:-commands.md}"
      JSON_OUTPUT="${2:-commands.json}"
      break
      ;;
  esac
done

FIRST_JSON=true

# Extract description from file header comment
extract_description() {
  local file="$1"
  local name="$2"
  grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //' || echo "Run $name"
}

# Add JSON separator if needed
add_json_separator() {
  if [[ "$FIRST_JSON" == "false" ]]; then
    echo "," >> "$JSON_OUTPUT"
  fi
  FIRST_JSON=false
}

# Add command to both outputs
add_command() {
  local command="$1"
  local description="$2"
  local category="$3"
  local source="$4"

  # Generate documentation link
  local doc_link=""
  if [[ "$command" =~ ^dp[[:space:]] ]]; then
    # dp commands
    local cmd_name="${command#dp }"
    cmd_name="${cmd_name%% *}"  # Remove options
    doc_link="[📖](docs/commands/dp/${cmd_name}.md)"
  elif [[ "$command" =~ ^./scripts/ ]]; then
    # Script commands
    local script_name="${command#./scripts/}"
    script_name="${script_name%.sh}"
    doc_link="[📖](docs/commands/scripts/${script_name}.md)"
  elif [[ "$command" =~ ^./tools/ ]]; then
    # Tool commands
    local tool_name="${command#./tools/}"
    tool_name="${tool_name%.sh}"
    doc_link="[📖](docs/commands/tools/${tool_name}.md)"
  fi

  # Markdown output with link
  echo "| \`$command\` | $description | $category | $source | $doc_link |" >> "$OUTPUT"

  # JSON output
  add_json_separator
  printf '  {"command":"%s","description":"%s","category":"%s","source":"%s"}' \
    "$command" "$description" "$category" "$source" >> "$JSON_OUTPUT"
}

# Process shell scripts in a directory
# Only shown when --internal flag is used
process_directory() {
  local dir="$1"
  local category="$2"
  local header="$3"

  # Skip unless --internal flag is set
  if [[ "$SHOW_INTERNAL" != "true" ]]; then
    return 0
  fi

  if [[ ! -d "$dir" ]]; then
    return 0
  fi

  for script in "$dir"/*.sh; do
    [[ -f "$script" ]] || continue
    local basename="${script##*/}"
    local name="${basename%.sh}"
    local desc=$(extract_description "$script" "$name")
    add_command "./$dir/$basename" "$desc" "$category" "$dir"
  done
}

# Parse Justfile targets
parse_justfile() {
  local justfile
  if [[ -f "Justfile" ]] || [[ -f "justfile" ]]; then
    justfile=$(ls Just* just* 2>/dev/null | head -1 || true)
  else
    return 0
  fi

  # Extract recipes with descriptions
  awk '
    /^[a-z][a-z0-9_-]*:/ {
      recipe = $1
      sub(/:.*/, "", recipe)

      if (prev_line ~ /^# /) {
        desc = prev_line
        sub(/^# /, "", desc)
        printf "%s|%s\n", recipe, desc
      } else {
        printf "%s|Run %s\n", recipe, recipe
      }
    }
    { prev_line = $0 }
  ' "$justfile" | while IFS='|' read -r recipe desc; do
    add_command "just $recipe" "$desc" "build" "Justfile"
  done
}

# Parse dp commands
parse_dp_commands() {
  if [[ ! -f "bin/dp" ]]; then
    return 0
  fi

  local -a dp_commands=(
    "setup:Smart project setup (new or existing):setup"
    "doctor:System health check and diagnostics:setup"
    "init:Initialize project with doctor, profile, and system build:setup"
    "project:View/modify project configuration:config"
    "profile:Change skill level and project phase:config"
    "persona:Manage AI personas for specialized help:config"
    "review:AI review of local changes before commit:review"
    "review --preview:AI review with preview logs:review"
    "tickets:Generate structured backlog (JSON/CSV):planning"
    "score:SoftSensorAI Readiness Score (DPRS):diagnostics"
    "detect:Detect technology stack in repository:analysis"
    "plan:Preview what setup would create (dry run):planning"
    "palette:Open command palette:meta"
    "ai:Unified AI CLI interface:ai"
    "sandbox:Sandboxed code execution environment:ai"
    "chain:Execute multi-step command chains:automation"
    "patterns:Browse and apply design patterns:development"
    "worktree:Manage git worktrees for parallel work:git"
    "release-check:Assess release readiness:deployment"
    "help:Show help and documentation:meta"
  )

  for cmd_spec in "${dp_commands[@]}"; do
    IFS=: read -r cmd desc cat <<< "$cmd_spec"
    add_command "dp $cmd" "$desc" "$cat" "dp"
  done
}

# Initialize output files
cat > "$OUTPUT" <<'EOF'
# SoftSensorAI Command Registry

Quick reference for all available commands. Use `dp palette` or `just palette` to search interactively.

📚 **[Full Command Documentation](docs/commands/README.md)** - Detailed guides with examples for every command

## Commands

| Command | Description | Category | Source | Doc |
|---------|-------------|----------|--------|-----|
EOF

echo '{"commands": [' > "$JSON_OUTPUT"

# Generate registry
parse_justfile
parse_dp_commands
process_directory "scripts" "script" "Scripts"
process_directory "tools" "tool" "Tools"

# Finalize outputs
echo "" >> "$JSON_OUTPUT"
echo "]}" >> "$JSON_OUTPUT"

# Add note if internal commands are shown
if [[ "$SHOW_INTERNAL" == "true" ]]; then
  echo "" >> "$OUTPUT"
  echo "**Note**: Internal scripts and tools are shown. These are implementation details - use \`dp\` commands for standard operations." >> "$OUTPUT"
fi

# Add footer to markdown
cat >> "$OUTPUT" <<'EOF'

## Categories

- **setup**: Project initialization and configuration
- **config**: Profile, persona, and project settings
- **diagnostics**: Health checks and scoring
- **review**: Code review and analysis
- **planning**: Tickets, backlogs, and planning
- **analysis**: Stack detection and code analysis
- **ai**: AI assistants and sandboxing
- **automation**: Chains and workflow automation
- **development**: Patterns and development tools
- **git**: Version control utilities
- **deployment**: Release and production readiness
- **meta**: Help and command discovery

## Quick Access

```bash
# Interactive command palette
dp palette

# Or use just
just palette

# Search for specific commands
dp palette test
dp palette review
```

---
*Generated by generate_command_registry.sh*
EOF

echo "✅ Generated $OUTPUT and $JSON_OUTPUT"
