#!/usr/bin/env bash
# Main setup entry point - guides users to the right setup path
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_header() {
  clear
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║          ${BOLD}🚀 AI-Powered Development Setup 🚀${NC}${CYAN}               ║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo
  echo -e "${BOLD}Welcome to the AI Development Environment Setup!${NC}"
  echo
}

check_current_dir() {
  # Check if current directory is a project
  if [ -d ".git" ] || [ -f "package.json" ] || [ -f "requirements.txt" ] || \
     [ -f "pyproject.toml" ] || [ -f "Makefile" ] || [ -f "go.mod" ]; then
    return 0
  fi
  return 1
}

main_menu() {
  show_header

  # Check if we're in a project directory
  if check_current_dir; then
    echo -e "${GREEN}✓ Current directory appears to be a project${NC}"
    echo -e "  Path: $(pwd)"
    echo
  fi

  echo -e "${BLUE}${BOLD}What would you like to do?${NC}"
  echo
  echo -e "${MAGENTA}1)${NC} ${BOLD}Setup EXISTING project${NC} 📁"
  echo "   Add AI assistant configs to your current repository"
  echo
  echo -e "${MAGENTA}2)${NC} ${BOLD}Clone NEW repository${NC} 🔄"
  echo "   Clone from GitHub and setup AI configurations"
  echo
  echo -e "${MAGENTA}3)${NC} ${BOLD}Configure AI Profile${NC} 🎯"
  echo "   Set skill level and project phase (existing projects only)"
  echo
  echo -e "${MAGENTA}4)${NC} ${BOLD}Quick Setup Guide${NC} 📖"
  echo "   Show examples and documentation"
  echo
  echo -e "${MAGENTA}5)${NC} ${BOLD}Exit${NC} 👋"
  echo

  read -p "Enter choice (1-5): " choice
  echo

  case "$choice" in
    1)
      # Setup existing project
      if [ -f "$SCRIPT_DIR/setup/existing_repo_setup.sh" ]; then
        exec "$SCRIPT_DIR/setup/existing_repo_setup.sh"
      else
        echo -e "${RED}Error: existing_repo_setup.sh not found${NC}"
        exit 1
      fi
      ;;

    2)
      # Clone new repository
      if [ -f "$SCRIPT_DIR/setup/repo_wizard.sh" ]; then
        exec "$SCRIPT_DIR/setup/repo_wizard.sh"
      else
        echo -e "${RED}Error: repo_wizard.sh not found${NC}"
        exit 1
      fi
      ;;

    3)
      # Configure profile
      if check_current_dir; then
        if [ -f "$SCRIPT_DIR/scripts/profile_menu.sh" ]; then
          exec "$SCRIPT_DIR/scripts/profile_menu.sh"
        else
          echo -e "${RED}Error: profile_menu.sh not found${NC}"
          exit 1
        fi
      else
        echo -e "${YELLOW}Please run this from within a project directory${NC}"
        echo "Or use option 1 to setup an existing project first."
        echo
        read -p "Press Enter to continue..."
        main_menu
      fi
      ;;

    4)
      # Show quick guide
      clear
      echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo -e "${BOLD}Quick Setup Guide${NC}"
      echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo
      echo -e "${GREEN}For Existing Projects:${NC}"
      echo "  1. Navigate to your project: cd /path/to/your/project"
      echo "  2. Run: $0"
      echo "  3. Choose option 1 (Setup EXISTING project)"
      echo
      echo -e "${GREEN}For New Projects (cloning from GitHub):${NC}"
      echo "  1. Run: $0"
      echo "  2. Choose option 2 (Clone NEW repository)"
      echo "  3. Follow the wizard to clone and setup"
      echo
      echo -e "${GREEN}Quick Commands:${NC}"
      echo
      echo "  # Setup existing project in current directory"
      echo "  ./setup/existing_repo_setup.sh"
      echo
      echo "  # Clone new repo with full setup"
      echo "  ./setup/repo_wizard.sh"
      echo
      echo "  # Configure AI profile interactively"
      echo "  ./scripts/profile_menu.sh"
      echo
      echo "  # Apply specific profile"
      echo "  ./scripts/apply_profile.sh --skill beginner --phase mvp"
      echo
      echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo
      read -p "Press Enter to return to main menu..."
      main_menu
      ;;

    5)
      echo -e "${GREEN}Goodbye! Happy coding with AI! 🚀${NC}"
      exit 0
      ;;

    *)
      echo -e "${RED}Invalid choice. Please try again.${NC}"
      sleep 2
      main_menu
      ;;
  esac
}

# Check for command line arguments
if [ $# -gt 0 ]; then
  case "$1" in
    --existing|existing)
      exec "$SCRIPT_DIR/setup/existing_repo_setup.sh"
      ;;
    --new|new|clone)
      exec "$SCRIPT_DIR/setup/repo_wizard.sh"
      ;;
    --profile|profile)
      exec "$SCRIPT_DIR/scripts/profile_menu.sh"
      ;;
    --help|-h|help)
      echo "Usage: $0 [OPTION]"
      echo
      echo "Options:"
      echo "  existing    Setup existing project"
      echo "  new/clone   Clone and setup new repository"
      echo "  profile     Configure AI profile"
      echo "  help        Show this help"
      echo
      echo "Run without arguments for interactive menu"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run '$0 --help' for usage"
      exit 1
      ;;
  esac
else
  # Run interactive menu
  main_menu
fi
