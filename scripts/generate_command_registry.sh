#!/usr/bin/env bash
set -euo pipefail

# Generate command registry from .claude/commands/*.md files
# Creates docs/agent-commands.md with categorized command reference

COMMANDS_DIR=".claude/commands"
OUTPUT_FILE="docs/agent-commands.md"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if commands directory exists
if [[ ! -d "$COMMANDS_DIR" ]]; then
    echo -e "${RED}Error: Commands directory $COMMANDS_DIR not found${NC}"
    exit 1
fi

# Initialize the registry document
cat > "$OUTPUT_FILE" << 'EOF'
# 🤖 AI Agent Commands Registry

Auto-generated index of all available AI assistant commands.

> **Note:** This file is auto-generated. Do not edit manually.
> Run `scripts/generate_command_registry.sh` to update.

## Command Categories

- [🧠 Thinking & Analysis](#-thinking--analysis)
- [🔒 Security](#-security)
- [📋 Ticket Management](#-ticket-management)
- [🔍 Code Auditing](#-code-auditing)
- [🔄 Processing & Workflows](#-processing--workflows)

---

EOF

# Function to extract command metadata from markdown file
extract_metadata() {
    local file="$1"
    local command_name=$(basename "$file" .md)

    # Extract first line as description (after removing # if present)
    local description=$(head -n 1 "$file" | sed 's/^#\+ *//')

    # Categorize based on command name patterns first, then content
    local category="Other"

    case "$command_name" in
        think-*|cot-*)
            category="Thinking & Analysis"
            ;;
        security-*|secure-*)
            category="Security"
            ;;
        ticket-*|tickets-*)
            category="Ticket Management"
            ;;
        audit-*)
            category="Code Auditing"
            ;;
        chain-*|parallel-*)
            category="Processing & Workflows"
            ;;
        *)
            # Fallback to content-based categorization
            if grep -qi "security\|secure\|vulnerability" "$file"; then
                category="Security"
            elif grep -qi "ticket\|issue\|backlog\|sprint" "$file"; then
                category="Ticket Management"
            elif grep -qi "audit\|review\|quality\|scan" "$file"; then
                category="Code Auditing"
            elif grep -qi "think\|analyze\|reasoning\|analysis" "$file"; then
                category="Thinking & Analysis"
            elif grep -qi "parallel\|process\|workflow\|chain\|step" "$file"; then
                category="Processing & Workflows"
            fi
            ;;
    esac

    echo "$category|/$command_name|$description"
}

# Collect all commands with metadata
declare -a commands=()
echo -e "${YELLOW}Scanning commands in $COMMANDS_DIR...${NC}"

for file in "$COMMANDS_DIR"/*.md; do
    [[ -f "$file" ]] || continue
    metadata=$(extract_metadata "$file")
    commands+=("$metadata")
    echo -e "${GREEN}✓${NC} Processed: $(basename "$file")"
done

# Sort commands by category and name
mapfile -t sorted_commands < <(printf '%s\n' "${commands[@]}" | sort -t'|' -k1,1 -k2,2)

# Group commands by category
declare -A categories
for cmd in "${sorted_commands[@]}"; do
    IFS='|' read -r category name description <<< "$cmd"
    if [[ ! -v "categories[$category]" ]]; then
        categories[$category]=""
    fi
    categories[$category]+="| \`$name\` | $description |"$'\n'
done

# Write sections for each category
write_section() {
    local title="$1"
    local anchor="$2"
    local category="$3"

    cat >> "$OUTPUT_FILE" << EOF
## $title

| Command | Description |
|---------|-------------|
EOF

    if [[ -v "categories[$category]" ]] && [[ -n "${categories[$category]}" ]]; then
        echo -n "${categories[$category]}" >> "$OUTPUT_FILE"
    else
        echo "| *No commands in this category* | - |" >> "$OUTPUT_FILE"
    fi

    echo "" >> "$OUTPUT_FILE"
}

# Write each category section
write_section "🧠 Thinking & Analysis" "thinking--analysis" "Thinking & Analysis"
write_section "🔒 Security" "security" "Security"
write_section "📋 Ticket Management" "ticket-management" "Ticket Management"
write_section "🔍 Code Auditing" "code-auditing" "Code Auditing"
write_section "🔄 Processing & Workflows" "processing--workflows" "Processing & Workflows"

# Add other/uncategorized if exists
if [[ -v "categories[Other]" ]] && [[ -n "${categories[Other]}" ]]; then
    cat >> "$OUTPUT_FILE" << EOF
## 📦 Other Commands

| Command | Description |
|---------|-------------|
EOF
    echo -n "${categories[Other]}" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Add command details section
cat >> "$OUTPUT_FILE" << 'EOF'
---

## Command Details

### Using Commands

Commands are invoked by typing the slash command in your AI assistant:

```
/command-name
```

Some commands accept parameters or context:

```
/tickets-from-diff HEAD~3
/security-review path/to/file.py
```

### Command Files

Each command is defined in a markdown file under `.claude/commands/`. The file structure:

1. **Description** - First line describes the command
2. **Instructions** - Detailed steps for the AI to follow
3. **Examples** - Usage examples (optional)
4. **Parameters** - Accepted parameters (optional)

### Adding New Commands

1. Create a new `.md` file in `.claude/commands/`
2. Follow the existing command structure
3. Run `scripts/generate_command_registry.sh` to update this registry

### Command Naming Convention

- Use kebab-case: `think-hard`, `security-review`
- Be descriptive but concise
- Group related commands with common prefixes:
  - `tickets-*` for ticket operations
  - `audit-*` for code auditing
  - `think-*` for analysis modes

---

*Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")*
EOF

# Summary
total_commands=${#commands[@]}
echo ""
echo -e "${GREEN}✅ Registry generated successfully!${NC}"
echo -e "   📁 Output: $OUTPUT_FILE"
echo -e "   📊 Total commands: $total_commands"
echo -e "   🏷️  Categories: $(echo "${!categories[@]}" | wc -w)"
echo ""
echo "View the registry:"
echo "  cat $OUTPUT_FILE"
