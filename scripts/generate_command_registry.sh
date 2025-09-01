#!/usr/bin/env bash
# Generate Command Registry from Justfile and scripts
# Creates a searchable command palette for DevPilot
set -euo pipefail

OUTPUT="${1:-commands.md}"
JSON_OUTPUT="${2:-commands.json}"

# Header for markdown
cat > "$OUTPUT" <<'EOF'
# DevPilot Command Registry

Quick reference for all available commands. Use `dp palette` or `just palette` to search interactively.

## Commands

| Command | Description | Category | Source |
|---------|-------------|----------|--------|
EOF

# JSON array start
echo '{"commands": [' > "$JSON_OUTPUT"
FIRST=true

# Parse Justfile targets
if [[ -f "Justfile" ]] || [[ -f "justfile" ]]; then
  JUSTFILE=$(ls Just* just* 2>/dev/null | head -1)

  # Extract recipes with descriptions
  awk '
    /^[a-z][a-z0-9_-]*:/ {
      # Found a recipe
      recipe = $1
      sub(/:.*/, "", recipe)

      # Look for comment on previous line
      if (prev_line ~ /^# /) {
        desc = prev_line
        sub(/^# /, "", desc)
        printf "| `just %s` | %s | build | Justfile |\n", recipe, desc
        printf "JSON:{\"command\":\"just %s\",\"description\":\"%s\",\"category\":\"build\",\"source\":\"Justfile\"}\n", recipe, desc
      } else {
        # No description, use recipe name
        printf "| `just %s` | Run %s | build | Justfile |\n", recipe, recipe
        printf "JSON:{\"command\":\"just %s\",\"description\":\"Run %s\",\"category\":\"build\",\"source\":\"Justfile\"}\n", recipe, recipe
      }
    }
    { prev_line = $0 }
  ' "$JUSTFILE" | while IFS= read -r line; do
    if [[ "$line" =~ ^JSON: ]]; then
      # JSON output
      json_line="${line#JSON:}"
      if [[ "$FIRST" == "false" ]]; then
        echo "," >> "$JSON_OUTPUT"
      fi
      echo -n "  $json_line" >> "$JSON_OUTPUT"
      FIRST=false
    else
      # Markdown output
      echo "$line" >> "$OUTPUT"
    fi
  done
fi

# Parse dp commands
if [[ -f "bin/dp" ]]; then
  echo "" >> "$OUTPUT"
  echo "| \`dp init\` | Initialize project with doctor, profile, and system build | setup | dp |" >> "$OUTPUT"
  echo "| \`dp tickets\` | Generate structured backlog (JSON/CSV) | planning | dp |" >> "$OUTPUT"
  echo "| \`dp review\` | AI review of local diff | review | dp |" >> "$OUTPUT"
  echo "| \`dp review --preview\` | AI review with preview logs | review | dp |" >> "$OUTPUT"
  echo "| \`dp project\` | Create/show project profile | config | dp |" >> "$OUTPUT"
  echo "| \`dp palette\` | Open command palette | meta | dp |" >> "$OUTPUT"

  # Add to JSON
  for cmd in "init:Initialize project with doctor, profile, and system build:setup" \
             "tickets:Generate structured backlog (JSON/CSV):planning" \
             "review:AI review of local diff:review" \
             "review --preview:AI review with preview logs:review" \
             "project:Create/show project profile:config" \
             "palette:Open command palette:meta"; do
    IFS=: read -r c d cat <<< "$cmd"
    if [[ "$FIRST" == "false" ]]; then
      echo "," >> "$JSON_OUTPUT"
    fi
    echo -n "  {\"command\":\"dp $c\",\"description\":\"$d\",\"category\":\"$cat\",\"source\":\"dp\"}" >> "$JSON_OUTPUT"
    FIRST=false
  done
fi

# Parse scripts directory
if [[ -d "scripts" ]]; then
  echo "" >> "$OUTPUT"
  echo "## Scripts" >> "$OUTPUT"
  echo "" >> "$OUTPUT"

  for script in scripts/*.sh; do
    [[ -f "$script" ]] || continue
    basename="${script##*/}"
    name="${basename%.sh}"

    # Extract description from script header
    desc=$(grep -m1 "^# " "$script" 2>/dev/null | sed 's/^# //' || echo "Run $name")

    echo "| \`./scripts/$basename\` | $desc | script | scripts |" >> "$OUTPUT"

    # Add to JSON
    if [[ "$FIRST" == "false" ]]; then
      echo "," >> "$JSON_OUTPUT"
    fi
    echo -n "  {\"command\":\"./scripts/$basename\",\"description\":\"$desc\",\"category\":\"script\",\"source\":\"scripts\"}" >> "$JSON_OUTPUT"
    FIRST=false
  done
fi

# Parse tools directory
if [[ -d "tools" ]]; then
  echo "" >> "$OUTPUT"
  echo "## Tools" >> "$OUTPUT"
  echo "" >> "$OUTPUT"

  for tool in tools/*.sh; do
    [[ -f "$tool" ]] || continue
    basename="${tool##*/}"
    name="${basename%.sh}"

    # Extract description from tool header
    desc=$(grep -m1 "^# " "$tool" 2>/dev/null | sed 's/^# //' || echo "Run $name")

    echo "| \`./tools/$basename\` | $desc | tool | tools |" >> "$OUTPUT"

    # Add to JSON
    if [[ "$FIRST" == "false" ]]; then
      echo "," >> "$JSON_OUTPUT"
    fi
    echo -n "  {\"command\":\"./tools/$basename\",\"description\":\"$desc\",\"category\":\"tool\",\"source\":\"tools\"}" >> "$JSON_OUTPUT"
    FIRST=false
  done
fi

# Close JSON array
echo "" >> "$JSON_OUTPUT"
echo "]}" >> "$JSON_OUTPUT"

# Add footer to markdown
cat >> "$OUTPUT" <<'EOF'

## Categories

- **build**: Build, test, and development commands
- **setup**: Project initialization and configuration
- **planning**: Ticket generation and project planning
- **review**: Code review and analysis
- **config**: Configuration management
- **script**: Utility scripts
- **tool**: Development tools
- **meta**: Meta commands and navigation

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
