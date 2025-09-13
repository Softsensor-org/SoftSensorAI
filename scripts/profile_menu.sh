#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Interactive profile configuration menu
set -euo pipefail

# Load shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/sh/common.sh"

# Function to display header
show_header() {
  clear
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║           ${BOLD}🚀 Repository Profile Configuration 🚀${NC}${CYAN}            ║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo
}

# Function to show current profile
show_current_profile() {
  echo -e "${YELLOW}Current Profile:${NC}"
  if [ -f "PROFILE.md" ]; then
    echo -e "${GREEN}✓ Profile configured${NC}"
    grep "^- \*\*" PROFILE.md | head -3 | sed 's/- /  /'
  else
    echo -e "${RED}✗ No profile configured yet${NC}"
  fi
  echo
}

# Function to select persona
select_persona() {
  echo -e "${BLUE}${BOLD}Select Your Persona(s):${NC}"
  echo -e "${YELLOW}Note: You can combine multiple personas for this repository${NC}"
  echo
  echo -e "${CYAN}═══ Developer Personas ═══${NC}"
  echo
  echo -e "${MAGENTA}1)${NC} ${BOLD}Software Developer${NC} 💻"
  echo "   For: General software development"
  echo "   Focus: Code quality, testing, debugging"
  echo
  echo -e "${MAGENTA}2)${NC} ${BOLD}Software Architect${NC} 🏗️"
  echo "   For: System design and architecture"
  echo "   Focus: Scalability, patterns, performance"
  echo
  echo -e "${MAGENTA}3)${NC} ${BOLD}Data Scientist${NC} 🧬"
  echo "   For: ML/AI and data analysis"
  echo "   Focus: GPU optimization, parallel computing"
  echo "   Special: Process impact analysis, hardware explanations"
  echo
  echo -e "${CYAN}═══ Other Personas ═══${NC}"
  echo
  echo -e "${MAGENTA}4)${NC} ${BOLD}Product Manager${NC} 📊"
  echo "   For: Product planning and documentation"
  echo "   Focus: Requirements, user stories, roadmaps"
  echo
  echo -e "${MAGENTA}5)${NC} ${BOLD}Designer${NC} 🎨"
  echo "   For: UI/UX design and prototyping"
  echo "   Focus: Mockups, user flows, accessibility"
  echo
  echo -e "${MAGENTA}6)${NC} ${BOLD}Multiple Personas${NC} 🎭"
  echo "   Combine multiple roles (e.g., DS + Backend)"
  echo
  echo -e "${MAGENTA}7)${NC} ${BOLD}Custom${NC} ⚙️"
  echo "   Configure your own combination"
  echo
  read -p "Enter choice (1-7): " persona_choice

  case $persona_choice in
    1) PERSONA="developer"; select_developer_level ;;
    2) PERSONA="architect"; SKILL="expert" ;;
    3) PERSONA="data-scientist"; SKILL="l2" ;;
    4) PERSONA="product-manager"; SKILL="vibe" ;;
    5) PERSONA="designer"; SKILL="vibe" ;;
    6)
      # Launch persona manager for multiple personas
      echo -e "${CYAN}Launching Persona Manager for multiple roles...${NC}"
      "$SCRIPT_DIR/persona_manager.sh"
      PERSONA="multiple"
      SKILL="custom"
      ;;
    7) PERSONA="custom"; select_custom_config ;;
    *)
      echo -e "${RED}Invalid choice. Using 'developer' as default.${NC}"
      PERSONA="developer"
      select_developer_level
      ;;
  esac
  echo
}

# Function to select developer skill level
select_developer_level() {
  echo -e "${BLUE}${BOLD}Select Your Skill Level:${NC}"
  echo
  echo -e "${MAGENTA}1)${NC} ${BOLD}Beginner${NC} 🌱"
  echo "   New to the codebase and AI tools"
  echo
  echo -e "${MAGENTA}2)${NC} ${BOLD}Level 1 (L1)${NC} ⚡"
  echo "   Junior developer comfortable with basics"
  echo
  echo -e "${MAGENTA}3)${NC} ${BOLD}Level 2 (L2)${NC} 🔥"
  echo "   Intermediate developer"
  echo
  echo -e "${MAGENTA}4)${NC} ${BOLD}Expert${NC} 🏆"
  echo "   Senior developer or tech lead"
  echo
  read -p "Enter choice (1-4): " level_choice

  case $level_choice in
    1) SKILL="beginner" ;;
    2) SKILL="l1" ;;
    3) SKILL="l2" ;;
    4) SKILL="expert" ;;
    *) SKILL="beginner" ;;
  esac
}

# Function to select custom configuration
select_custom_config() {
  select_skill_level_original
}

# Original skill level function (for custom mode)
select_skill_level_original() {
  echo -e "${BLUE}${BOLD}Select Your Skill Level:${NC}"
  echo
  echo -e "${MAGENTA}1)${NC} ${BOLD}Vibe Check${NC} 🎨"
  echo "   For: Product managers, designers, non-engineers"
  echo "   Can: Read code, generate mockups, write docs"
  echo
  echo -e "${MAGENTA}2)${NC} ${BOLD}Beginner${NC} 🌱"
  echo "   For: Developers new to the codebase and AI tools"
  echo "   Can: Basic development with guidance"
  echo
  echo -e "${MAGENTA}3)${NC} ${BOLD}Level 1 (L1)${NC} ⚡"
  echo "   For: Junior developers comfortable with basics"
  echo "   Can: Testing, linting, security scans"
  echo
  echo -e "${MAGENTA}4)${NC} ${BOLD}Level 2 (L2)${NC} 🔥"
  echo "   For: Intermediate developers"
  echo "   Can: Migrations, performance testing, security tools"
  echo
  echo -e "${MAGENTA}5)${NC} ${BOLD}Expert${NC} 🏆"
  echo "   For: Senior developers and technical leads"
  echo "   Can: Full tool access, architecture decisions"
  echo
  read -p "Enter choice (1-5): " skill_choice

  case $skill_choice in
    1) SKILL="vibe" ;;
    2) SKILL="beginner" ;;
    3) SKILL="l1" ;;
    4) SKILL="l2" ;;
    5) SKILL="expert" ;;
    *)
      echo -e "${RED}Invalid choice. Using 'beginner' as default.${NC}"
      SKILL="beginner"
      ;;
  esac
  echo
}

# Function to select project phase
select_project_phase() {
  echo -e "${BLUE}${BOLD}Select Your Project Phase:${NC}"
  echo
  echo -e "${MAGENTA}1)${NC} ${BOLD}Proof of Concept (POC)${NC} 💡"
  echo "   Goal: Prove feasibility quickly"
  echo "   CI/CD: Minimal - tests advisory only"
  echo
  echo -e "${MAGENTA}2)${NC} ${BOLD}Minimum Viable Product (MVP)${NC} 🚢"
  echo "   Goal: First usable version"
  echo "   CI/CD: Basic - linting, type checking, unit tests"
  echo
  echo -e "${MAGENTA}3)${NC} ${BOLD}Beta${NC} 🎯"
  echo "   Goal: Production-ready for early adopters"
  echo "   CI/CD: Comprehensive - 60% coverage, security scans"
  echo
  echo -e "${MAGENTA}4)${NC} ${BOLD}Scale${NC} 🚀"
  echo "   Goal: Full production with SLOs"
  echo "   CI/CD: Production-grade - 80% coverage, all gates"
  echo
  read -p "Enter choice (1-4): " phase_choice

  case $phase_choice in
    1) PHASE="poc" ;;
    2) PHASE="mvp" ;;
    3) PHASE="beta" ;;
    4) PHASE="scale" ;;
    *)
      echo -e "${RED}Invalid choice. Using 'mvp' as default.${NC}"
      PHASE="mvp"
      ;;
  esac
  echo
}

# Function to select teach mode
select_teach_mode() {
  echo -e "${BLUE}${BOLD}Enable Teaching Mode?${NC}"
  echo
  echo "Teaching mode provides detailed explanations during operations."
  echo
  echo -e "${MAGENTA}1)${NC} Yes - Explain what you're doing (recommended for beginners)"
  echo -e "${MAGENTA}2)${NC} No - Just execute commands"
  echo -e "${MAGENTA}3)${NC} Auto - Based on skill level"
  echo
  read -p "Enter choice (1-3): " teach_choice

  case $teach_choice in
    1) TEACH_MODE="on" ;;
    2) TEACH_MODE="off" ;;
    3)
      case "$SKILL" in
        vibe|beginner) TEACH_MODE="on" ;;
        *) TEACH_MODE="off" ;;
      esac
      ;;
    *)
      echo -e "${RED}Invalid choice. Using 'auto' mode.${NC}"
      case "$SKILL" in
        vibe|beginner) TEACH_MODE="on" ;;
        *) TEACH_MODE="off" ;;
      esac
      ;;
  esac
  echo
}

# Function to show summary and confirm
show_summary() {
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Configuration Summary:${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  if [ -n "${PERSONA:-}" ]; then
    echo -e "  ${BOLD}Persona:${NC}        ${GREEN}$PERSONA${NC}"
  fi
  echo -e "  ${BOLD}Skill Level:${NC}    ${GREEN}$SKILL${NC}"
  echo -e "  ${BOLD}Project Phase:${NC}  ${GREEN}$PHASE${NC}"
  echo -e "  ${BOLD}Teach Mode:${NC}     ${GREEN}$TEACH_MODE${NC}"

  # Show persona-specific features
  if [ "$PERSONA" = "data-scientist" ]; then
    echo
    echo -e "  ${BOLD}Special Features:${NC}"
    echo -e "    • GPU optimization explanations"
    echo -e "    • Process impact analysis"
    echo -e "    • Parallelization deep-dives"
    echo -e "    • Hardware-level insights"
  elif [ "$PERSONA" = "architect" ]; then
    echo
    echo -e "  ${BOLD}Special Features:${NC}"
    echo -e "    • Architecture reviews"
    echo -e "    • Performance audits"
    echo -e "    • Scalability analysis"
    echo -e "    • System design patterns"
  fi

  echo
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  echo -e "${YELLOW}This will configure:${NC}"
  echo "  • Permission settings for your skill level"
  echo "  • Available AI commands"
  echo "  • CI/CD workflow for your project phase"
  echo "  • Create/update PROFILE.md documentation"
  echo
}

# Function to display quick mode options
show_quick_mode() {
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Quick Setup Commands:${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
  echo -e "${BOLD}Common Configurations:${NC}"
  echo
  echo -e "${GREEN}# Beginner starting an MVP:${NC}"
  echo "  ./scripts/apply_profile.sh --skill beginner --phase mvp --teach-mode on"
  echo
  echo -e "${GREEN}# Experienced dev on production app:${NC}"
  echo "  ./scripts/apply_profile.sh --skill l2 --phase scale --teach-mode off"
  echo
  echo -e "${GREEN}# Designer exploring the codebase:${NC}"
  echo "  ./scripts/apply_profile.sh --skill vibe --phase poc --teach-mode on"
  echo
  echo -e "${GREEN}# Junior dev working on beta features:${NC}"
  echo "  ./scripts/apply_profile.sh --skill l1 --phase beta --teach-mode on"
  echo
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo
}

# Main menu
main_menu() {
  show_header
  show_current_profile

  echo -e "${BOLD}Choose Setup Mode:${NC}"
  echo
  echo -e "${MAGENTA}1)${NC} ${BOLD}Interactive Setup${NC} - Step-by-step configuration wizard"
  echo -e "${MAGENTA}2)${NC} ${BOLD}View Quick Commands${NC} - Show command-line examples"
  echo -e "${MAGENTA}3)${NC} ${BOLD}View Current Profile${NC} - Show detailed current settings"
  echo -e "${MAGENTA}4)${NC} ${BOLD}Exit${NC}"
  echo
  read -p "Enter choice (1-4): " main_choice
  echo

  case $main_choice in
    1)
      # Interactive mode
      show_header
      select_persona
      select_project_phase

      # Auto-set teach mode based on persona
      case "$PERSONA" in
        "data-scientist")
          TEACH_MODE="on"
          echo -e "${GREEN}Teaching mode enabled for data science explanations${NC}"
          ;;
        "architect")
          TEACH_MODE="on"
          echo -e "${GREEN}Architecture explanations enabled${NC}"
          ;;
        *)
          select_teach_mode
          ;;
      esac

      show_summary

      read -p "Apply this configuration? (y/n): " confirm
      if [[ $confirm =~ ^[Yy] ]]; then
        echo
        echo -e "${GREEN}Applying profile...${NC}"
        echo
        "$SCRIPT_DIR/apply_profile.sh" --skill "$SKILL" --phase "$PHASE" --teach-mode "$TEACH_MODE"
        echo
        echo -e "${GREEN}✓ Profile applied successfully!${NC}"
        echo
        echo -e "${YELLOW}Next steps:${NC}"
        echo "  1. Review PROFILE.md for your capabilities"
        echo "  2. Try commands in .claude/commands/"
        echo "  3. Run 'scripts/profile_show.sh' to see status"
      else
        echo -e "${YELLOW}Configuration cancelled.${NC}"
      fi
      ;;

    2)
      # Show quick commands
      show_header
      show_quick_mode
      read -p "Press Enter to return to main menu..."
      main_menu
      ;;

    3)
      # View current profile
      show_header
      if [ -f "PROFILE.md" ]; then
        echo -e "${GREEN}Current Profile Details:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        head -n 30 PROFILE.md | sed 's/^/  /'
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        echo -e "${YELLOW}Run 'cat PROFILE.md' to see the full profile${NC}"
      else
        echo -e "${RED}No profile configured yet.${NC}"
        echo "Please run the interactive setup first."
      fi
      echo
      read -p "Press Enter to return to main menu..."
      main_menu
      ;;

    4)
      echo -e "${GREEN}Goodbye!${NC}"
      exit 0
      ;;

    *)
      echo -e "${RED}Invalid choice. Please try again.${NC}"
      sleep 2
      main_menu
      ;;
  esac
}

# Check if running with arguments (non-interactive mode)
if [ $# -gt 0 ]; then
  # Pass through to apply_profile.sh
  "$SCRIPT_DIR/apply_profile.sh" "$@"
else
  # Run interactive menu
  main_menu
fi
