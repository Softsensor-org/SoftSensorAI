#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Multi-persona manager - allows combining multiple personas per repository
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")"

# Check if in a repository
check_repository() {
  if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "requirements.txt" ]; then
    echo -e "${RED}Error: Not in a repository directory${NC}"
    echo "Please run this from your project root"
    exit 1
  fi
}

# Initialize persona system
init_personas() {
  mkdir -p .claude/personas

  # Create active personas file if not exists
  if [ ! -f ".claude/personas/active.json" ]; then
    echo '{"personas": [], "combined": true}' > .claude/personas/active.json
  fi
}

# List available personas
list_available_personas() {
  echo -e "${CYAN}Available Personas:${NC}"
  echo
  echo -e "${BOLD}1) data-scientist${NC} 🧬"
  echo "   • GPU optimization insights"
  echo "   • Process impact analysis"
  echo "   • Parallel computing explanations"
  echo
  echo -e "${BOLD}2) software-architect${NC} 🏗️"
  echo "   • System design reviews"
  echo "   • Performance audits"
  echo "   • Scalability analysis"
  echo
  echo -e "${BOLD}3) backend-developer${NC} 🔧"
  echo "   • API development"
  echo "   • Database optimization"
  echo "   • Testing focus"
  echo
  echo -e "${BOLD}4) frontend-developer${NC} 🎨"
  echo "   • UI/UX implementation"
  echo "   • Performance optimization"
  echo "   • Accessibility"
  echo
  echo -e "${BOLD}5) devops-engineer${NC} 🚀"
  echo "   • CI/CD pipelines"
  echo "   • Infrastructure as code"
  echo "   • Monitoring & observability"
  echo
  echo -e "${BOLD}6) security-specialist${NC} 🔒"
  echo "   • Security audits"
  echo "   • Vulnerability scanning"
  echo "   • Secure coding practices"
}

# Show currently active personas
show_active_personas() {
  if [ -f ".claude/personas/active.json" ]; then
    echo -e "${CYAN}Currently Active Personas:${NC}"
    active=$(jq -r '.personas[]' .claude/personas/active.json 2>/dev/null || echo "none")
    if [ "$active" = "none" ] || [ -z "$active" ]; then
      echo "  None active"
    else
      echo "$active" | while read -r persona; do
        echo "  • $persona ✓"
      done
    fi
    echo
  fi
}

# Add a persona
add_persona() {
  local persona="$1"

  echo -e "${BLUE}Adding persona: $persona${NC}"

  # Check if persona files exist
  local persona_config="$SETUP_SCRIPTS_DIR/profiles/personas/${persona}.json"
  if [ ! -f "$persona_config" ]; then
    # Create basic persona config if not exists
    create_persona_config "$persona"
  else
    # Copy persona config
    cp "$persona_config" ".claude/personas/${persona}.json"
  fi

  # Copy persona-specific commands for Claude
  if [ -d "$SETUP_SCRIPTS_DIR/.claude/commands/sets/${persona}" ]; then
    mkdir -p ".claude/commands/personas/${persona}"
    cp -r "$SETUP_SCRIPTS_DIR/.claude/commands/sets/${persona}"/* ".claude/commands/personas/${persona}/" 2>/dev/null || true
  fi

  # Copy persona-specific commands for Codex
  if [ -d "$SETUP_SCRIPTS_DIR/.codex/commands/${persona}" ]; then
    mkdir -p ".codex/commands/personas/${persona}"
    cp -r "$SETUP_SCRIPTS_DIR/.codex/commands/${persona}"/* ".codex/commands/personas/${persona}/" 2>/dev/null || true
  fi

  # Add to active personas
  if [ -f ".claude/personas/active.json" ]; then
    jq --arg p "$persona" '.personas += [$p] | .personas |= unique' .claude/personas/active.json > .claude/personas/active.tmp
    mv .claude/personas/active.tmp .claude/personas/active.json
  fi

  echo -e "${GREEN}✓ Added $persona persona${NC}"
}

# Remove a persona
remove_persona() {
  local persona="$1"

  echo -e "${YELLOW}Removing persona: $persona${NC}"

  # Remove from active list
  if [ -f ".claude/personas/active.json" ]; then
    jq --arg p "$persona" '.personas -= [$p]' .claude/personas/active.json > .claude/personas/active.tmp
    mv .claude/personas/active.tmp .claude/personas/active.json
  fi

  # Remove persona files
  rm -f ".claude/personas/${persona}.json"
  rm -rf ".claude/commands/personas/${persona}"
  rm -rf ".codex/commands/personas/${persona}"

  echo -e "${GREEN}✓ Removed $persona persona${NC}"
}

# Create basic persona config
create_persona_config() {
  local persona="$1"
  local config_file=".claude/personas/${persona}.json"

  case "$persona" in
    "backend-developer")
      cat > "$config_file" <<'EOF'
{
  "persona": "backend-developer",
  "display_name": "Backend Developer",
  "focus": ["API development", "Database optimization", "Testing", "Performance"],
  "permissions": {
    "allow": ["Bash(npm test:*)", "Bash(jest:*)", "Bash(pytest:*)", "Bash(curl:*)", "Bash(httpie:*)"]
  },
  "commands": ["api-design", "database-optimize", "test-coverage", "load-test"]
}
EOF
      ;;
    "frontend-developer")
      cat > "$config_file" <<'EOF'
{
  "persona": "frontend-developer",
  "display_name": "Frontend Developer",
  "focus": ["UI/UX", "React/Vue/Angular", "Performance", "Accessibility"],
  "permissions": {
    "allow": ["Bash(npm run build:*)", "Bash(webpack:*)", "Bash(lighthouse:*)"]
  },
  "commands": ["component-create", "accessibility-audit", "bundle-analyze", "responsive-test"]
}
EOF
      ;;
    "devops-engineer")
      cat > "$config_file" <<'EOF'
{
  "persona": "devops-engineer",
  "display_name": "DevOps Engineer",
  "focus": ["CI/CD", "Infrastructure", "Monitoring", "Automation"],
  "permissions": {
    "allow": ["Bash(docker:*)", "Bash(kubectl:*)", "Bash(terraform plan:*)", "Bash(ansible:*)"]
  },
  "commands": ["pipeline-create", "infrastructure-audit", "monitoring-setup", "deployment-check"]
}
EOF
      ;;
    "security-specialist")
      cat > "$config_file" <<'EOF'
{
  "persona": "security-specialist",
  "display_name": "Security Specialist",
  "focus": ["Security audits", "Vulnerability scanning", "Secure coding", "Compliance"],
  "permissions": {
    "allow": ["Bash(semgrep:*)", "Bash(trivy:*)", "Bash(gitleaks:*)", "Bash(bandit:*)"]
  },
  "commands": ["security-scan", "dependency-audit", "secret-scan", "compliance-check"]
}
EOF
      ;;
    *)
      cat > "$config_file" <<EOF
{
  "persona": "$persona",
  "display_name": "$persona",
  "focus": ["Custom configuration"],
  "permissions": {
    "allow": []
  },
  "commands": []
}
EOF
      ;;
  esac
}

# Combine active personas
combine_personas() {
  echo -e "${BLUE}Combining active personas...${NC}"

  local combined_file=".claude/combined_persona.json"
  local combined_perms='{"allow": [], "deny": []}'
  local combined_commands=()
  local combined_focus=()

  # Read all active personas
  if [ -f ".claude/personas/active.json" ]; then
    while IFS= read -r persona; do
      if [ -f ".claude/personas/${persona}.json" ]; then
        # Merge permissions
        local perms
        perms=$(jq -r '.permissions.allow[]?' ".claude/personas/${persona}.json" 2>/dev/null)
        if [ -n "$perms" ]; then
          combined_perms=$(echo "$combined_perms" | jq --arg p "$perms" '.allow += [$p]')
        fi

        # Collect commands
        local cmds
        cmds=$(jq -r '.commands[]?' ".claude/personas/${persona}.json" 2>/dev/null)
        if [ -n "$cmds" ]; then
          while IFS= read -r cmd; do
            combined_commands+=("$cmd")
          done <<< "$cmds"
        fi

        # Collect focus areas
        local focus
        focus=$(jq -r '.focus[]?' ".claude/personas/${persona}.json" 2>/dev/null)
        if [ -n "$focus" ]; then
          while IFS= read -r f; do
            combined_focus+=("$f")
          done <<< "$focus"
        fi

        # Copy command files
        if [ -d ".claude/commands/personas/${persona}" ]; then
          mkdir -p .claude/commands/active
          cp -r ".claude/commands/personas/${persona}"/* .claude/commands/active/ 2>/dev/null || true
        fi
      fi
    done < <(jq -r '.personas[]' .claude/personas/active.json 2>/dev/null)
  fi

  # Create combined configuration
  cat > "$combined_file" <<EOF
{
  "active_personas": $(jq '.personas' .claude/personas/active.json),
  "combined": true,
  "focus": $(printf '%s\n' "${combined_focus[@]}" | jq -R . | jq -s 'unique'),
  "commands": $(printf '%s\n' "${combined_commands[@]}" | jq -R . | jq -s 'unique'),
  "permissions": $(echo "$combined_perms" | jq '.allow |= unique')
}
EOF

  # Update main settings
  if [ -f ".claude/settings.json" ]; then
    # Merge permissions into main settings
    local new_perms
    new_perms=$(jq '.permissions.allow' "$combined_file")

    jq --argjson np "$new_perms" '.permissions.allow += $np | .permissions.allow |= unique' .claude/settings.json > .claude/settings.tmp
    mv .claude/settings.tmp .claude/settings.json
  fi

  echo -e "${GREEN}✓ Combined ${#combined_focus[@]} focus areas from active personas${NC}"
}

# Quick switch between persona sets
quick_switch() {
  echo -e "${CYAN}Quick Persona Switch:${NC}"
  echo
  echo "1) Data Science Mode (DS + Backend)"
  echo "2) Full Stack Mode (Frontend + Backend)"
  echo "3) Platform Mode (Backend + DevOps + Security)"
  echo "4) Architecture Mode (Architect + Backend + DevOps)"
  echo "5) ML Engineering Mode (DS + Backend + DevOps)"
  echo "6) Custom combination"
  echo
  read -p "Select mode (1-6): " mode

  # Clear current personas
  echo '{"personas": [], "combined": true}' > .claude/personas/active.json
  rm -rf .claude/commands/active
  mkdir -p .claude/commands/active

  case "$mode" in
    1)
      add_persona "data-scientist"
      add_persona "backend-developer"
      echo -e "${GREEN}Switched to Data Science Mode${NC}"
      ;;
    2)
      add_persona "frontend-developer"
      add_persona "backend-developer"
      echo -e "${GREEN}Switched to Full Stack Mode${NC}"
      ;;
    3)
      add_persona "backend-developer"
      add_persona "devops-engineer"
      add_persona "security-specialist"
      echo -e "${GREEN}Switched to Platform Mode${NC}"
      ;;
    4)
      add_persona "software-architect"
      add_persona "backend-developer"
      add_persona "devops-engineer"
      echo -e "${GREEN}Switched to Architecture Mode${NC}"
      ;;
    5)
      add_persona "data-scientist"
      add_persona "backend-developer"
      add_persona "devops-engineer"
      echo -e "${GREEN}Switched to ML Engineering Mode${NC}"
      ;;
    6)
      custom_combination
      ;;
    *)
      echo -e "${RED}Invalid selection${NC}"
      ;;
  esac

  # Combine all active personas
  combine_personas
}

# Custom combination
custom_combination() {
  echo -e "${CYAN}Select personas to combine (space-separated numbers):${NC}"
  echo
  echo "1) data-scientist"
  echo "2) software-architect"
  echo "3) backend-developer"
  echo "4) frontend-developer"
  echo "5) devops-engineer"
  echo "6) security-specialist"
  echo
  read -p "Enter selections: " selections

  # Map numbers to personas
  declare -A persona_map=(
    [1]="data-scientist"
    [2]="software-architect"
    [3]="backend-developer"
    [4]="frontend-developer"
    [5]="devops-engineer"
    [6]="security-specialist"
  )

  # Clear and add selected
  echo '{"personas": [], "combined": true}' > .claude/personas/active.json

  for num in $selections; do
    if [ -n "${persona_map[$num]}" ]; then
      add_persona "${persona_map[$num]}"
    fi
  done

  combine_personas
}

# Interactive menu
interactive_menu() {
  while true; do
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              ${BOLD}🎭 Persona Manager 🎭${NC}${CYAN}                        ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo

    show_active_personas

    echo -e "${BOLD}Options:${NC}"
    echo "1) Quick switch (preset combinations)"
    echo "2) Add persona"
    echo "3) Remove persona"
    echo "4) Custom combination"
    echo "5) View available personas"
    echo "6) Show current configuration"
    echo "7) Exit"
    echo
    read -p "Select option (1-7): " option

    case "$option" in
      1) quick_switch ;;
      2)
        list_available_personas
        read -p "Enter persona name: " persona
        add_persona "$persona"
        combine_personas
        ;;
      3)
        show_active_personas
        read -p "Enter persona to remove: " persona
        remove_persona "$persona"
        combine_personas
        ;;
      4) custom_combination ;;
      5) list_available_personas; read -p "Press Enter to continue..." ;;
      6)
        if [ -f ".claude/combined_persona.json" ]; then
          echo -e "${CYAN}Current Configuration:${NC}"
          jq . .claude/combined_persona.json
        fi
        read -p "Press Enter to continue..."
        ;;
      7) exit 0 ;;
      *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
    esac
  done
}

# Main execution
main() {
  check_repository
  init_personas

  # Parse command line arguments
  if [ $# -eq 0 ]; then
    interactive_menu
  else
    case "$1" in
      add)
        shift
        for persona in "$@"; do
          add_persona "$persona"
        done
        combine_personas
        ;;
      remove)
        shift
        for persona in "$@"; do
          remove_persona "$persona"
        done
        combine_personas
        ;;
      list)
        list_available_personas
        ;;
      show)
        show_active_personas
        if [ -f ".claude/combined_persona.json" ]; then
          echo -e "${CYAN}Combined Configuration:${NC}"
          jq -r '.focus[]' .claude/combined_persona.json | sed 's/^/  • /'
        fi
        ;;
      switch)
        quick_switch
        ;;
      clear)
        echo '{"personas": [], "combined": true}' > .claude/personas/active.json
        rm -rf .claude/commands/active
        echo -e "${GREEN}Cleared all personas${NC}"
        ;;
      help|--help|-h)
        cat <<EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
  add <persona>...     Add one or more personas
  remove <persona>...  Remove one or more personas
  list                 List available personas
  show                 Show active personas
  switch               Quick switch to preset combinations
  clear                Clear all active personas
  help                 Show this help

Without arguments, launches interactive menu.

Examples:
  $0 add data-scientist backend-developer
  $0 switch  # Quick mode selection
  $0 show    # See current configuration
EOF
        ;;
      *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
    esac
  fi
}

main "$@"
