#!/usr/bin/env bash
# Track and manage graduation criteria for skill levels and project phases
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECK="✓"
CROSS="✗"
STAR="★"

# Action mode
ACTION="${1:-check}"
ITEM_NUM="${2:-}"

# Usage
usage() {
  cat <<EOF
Graduate - Track progress toward skill and phase advancement

Usage: $0 [ACTION] [ITEM_NUMBER]

Actions:
  check           Show current graduation progress (default)
  complete NUM    Mark criteria item NUM as complete
  reset NUM       Mark criteria item NUM as incomplete
  ready           Check if ready to graduate
  advance         Graduate to next level (if ready)
  
Examples:
  $0                      # Show progress
  $0 complete 1           # Mark first item complete
  $0 ready               # Check graduation readiness
  $0 advance             # Graduate to next level

Current Status:
EOF
  
  if [ -f "PROFILE.md" ]; then
    echo -n "  Skill: "
    grep "^\*\*Skill Level\*\*:" PROFILE.md | cut -d: -f2 | tr -d ' '
    echo -n "  Phase: "
    grep "^\*\*Project Phase\*\*:" PROFILE.md | cut -d: -f2 | tr -d ' '
  else
    echo "  No profile configured - run: scripts/apply_profile.sh"
  fi
  
  exit 0
}

# Check if profile exists
check_profile() {
  if [ ! -f "PROFILE.md" ]; then
    echo -e "${RED}No profile found. Run: scripts/apply_profile.sh${NC}"
    exit 1
  fi
}

# Extract current levels
get_current_levels() {
  CURRENT_SKILL=$(grep "^\*\*Skill Level\*\*:" PROFILE.md | cut -d: -f2 | tr -d ' ')
  CURRENT_PHASE=$(grep "^\*\*Project Phase\*\*:" PROFILE.md | cut -d: -f2 | tr -d ' ')
}

# Show progress
show_progress() {
  check_profile
  get_current_levels
  
  echo -e "${BLUE}=== Graduation Progress ===${NC}"
  echo ""
  
  # Skill level progress
  echo -e "${CYAN}Skill Level: $CURRENT_SKILL${NC}"
  echo "To advance to next skill level:"
  
  local skill_items=0
  local skill_complete=0
  
  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ \[(.)\]\ (.*)$ ]]; then
      skill_items=$((skill_items + 1))
      local status="${BASH_REMATCH[1]}"
      local task="${BASH_REMATCH[2]}"
      
      if [ "$status" = "x" ]; then
        skill_complete=$((skill_complete + 1))
        echo -e "  ${GREEN}[$skill_items] $CHECK $task${NC}"
      else
        echo -e "  [$skill_items] $CROSS $task"
      fi
    fi
  done < <(awk '/^### To Next.*Level/,/^### To Next.*Phase|^##[^#]/ {print}' PROFILE.md)
  
  if [ "$skill_items" -gt 0 ]; then
    local skill_percent=$((skill_complete * 100 / skill_items))
    echo -e "\nSkill Progress: ${GREEN}$skill_complete/$skill_items${NC} ($skill_percent%)"
    
    if [ "$skill_percent" -ge 80 ]; then
      echo -e "${GREEN}$STAR Ready to advance skill level!${NC}"
    fi
  fi
  
  echo ""
  
  # Project phase progress
  echo -e "${CYAN}Project Phase: $CURRENT_PHASE${NC}"
  echo "To advance to next project phase:"
  
  local phase_items=0
  local phase_complete=0
  
  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ \[(.)\]\ (.*)$ ]]; then
      phase_items=$((phase_items + 1))
      local status="${BASH_REMATCH[1]}"
      local task="${BASH_REMATCH[2]}"
      
      if [ "$status" = "x" ]; then
        phase_complete=$((phase_complete + 1))
        echo -e "  ${GREEN}[$phase_items] $CHECK $task${NC}"
      else
        echo -e "  [$phase_items] $CROSS $task"
      fi
    fi
  done < <(awk '/^### To Next.*Phase/,/^##[^#]|$/ {print}' PROFILE.md)
  
  if [ "$phase_items" -gt 0 ]; then
    local phase_percent=$((phase_complete * 100 / phase_items))
    echo -e "\nPhase Progress: ${GREEN}$phase_complete/$phase_items${NC} ($phase_percent%)"
    
    if [ "$phase_percent" -ge 80 ]; then
      echo -e "${GREEN}$STAR Ready to advance project phase!${NC}"
    fi
  fi
}

# Mark item complete
mark_complete() {
  local item_num=$1
  check_profile
  
  # Count items in both sections
  local current_line=0
  local found=0
  
  # Create temp file
  cp PROFILE.md PROFILE.md.tmp
  
  # Process skill level items
  while IFS= read -r line_num; do
    current_line=$((current_line + 1))
    if [ "$current_line" -eq "$item_num" ]; then
      sed -i "${line_num}s/\[.\]/[x]/" PROFILE.md.tmp
      found=1
      break
    fi
  done < <(grep -n "^- \[.\]" PROFILE.md | grep -A100 "To Next.*Level" | grep -B100 "To Next.*Phase" | cut -d: -f1)
  
  # If not found in skill items, check phase items  
  if [ "$found" -eq 0 ]; then
    current_line=0
    while IFS= read -r line_num; do
      current_line=$((current_line + 1))
      if [ "$current_line" -eq "$item_num" ]; then
        sed -i "${line_num}s/\[.\]/[x]/" PROFILE.md.tmp
        found=1
        break
      fi
    done < <(grep -n "^- \[.\]" PROFILE.md | grep -A100 "To Next.*Phase" | cut -d: -f1)
  fi
  
  if [ "$found" -eq 1 ]; then
    mv PROFILE.md.tmp PROFILE.md
    echo -e "${GREEN}$CHECK Item $item_num marked complete${NC}"
    
    # Show updated progress
    echo ""
    show_progress
  else
    rm PROFILE.md.tmp
    echo -e "${RED}Item $item_num not found${NC}"
  fi
}

# Mark item incomplete
mark_incomplete() {
  local item_num=$1
  check_profile
  
  # Similar to mark_complete but reverse
  cp PROFILE.md PROFILE.md.tmp
  
  local current_line=0
  local found=0
  
  # Process all checklist items
  while IFS= read -r line_num; do
    current_line=$((current_line + 1))
    if [ "$current_line" -eq "$item_num" ]; then
      sed -i "${line_num}s/\[x\]/[ ]/" PROFILE.md.tmp
      found=1
      break
    fi
  done < <(grep -n "^- \[.\]" PROFILE.md | cut -d: -f1)
  
  if [ "$found" -eq 1 ]; then
    mv PROFILE.md.tmp PROFILE.md
    echo -e "${YELLOW}Item $item_num marked incomplete${NC}"
    
    # Show updated progress
    echo ""
    show_progress
  else
    rm PROFILE.md.tmp
    echo -e "${RED}Item $item_num not found${NC}"
  fi
}

# Check readiness
check_ready() {
  check_profile
  get_current_levels
  
  local ready_skill=0
  local ready_phase=0
  
  # Check skill readiness
  local skill_total=$(grep -c "^- \[.\]" PROFILE.md 2>/dev/null | head -1 || echo 0)
  local skill_complete=$(awk '/To Next.*Level/,/To Next.*Phase/ {print}' PROFILE.md | grep -c "^- \[x\]" || echo 0)
  
  if [ "$skill_total" -gt 0 ]; then
    local skill_percent=$((skill_complete * 100 / skill_total))
    if [ "$skill_percent" -ge 80 ]; then
      ready_skill=1
    fi
  fi
  
  # Check phase readiness
  local phase_total=$(awk '/To Next.*Phase/,/^##[^#]|$/ {print}' PROFILE.md | grep -c "^- \[.\]" || echo 0)
  local phase_complete=$(awk '/To Next.*Phase/,/^##[^#]|$/ {print}' PROFILE.md | grep -c "^- \[x\]" || echo 0)
  
  if [ "$phase_total" -gt 0 ]; then
    local phase_percent=$((phase_complete * 100 / phase_total))
    if [ "$phase_percent" -ge 80 ]; then
      ready_phase=1
    fi
  fi
  
  echo -e "${BLUE}=== Graduation Readiness ===${NC}"
  echo ""
  
  if [ "$ready_skill" -eq 1 ]; then
    echo -e "${GREEN}$STAR Skill Level: READY TO ADVANCE${NC}"
    
    # Suggest next level
    case "$CURRENT_SKILL" in
      vibe) echo "  Next: beginner" ;;
      beginner) echo "  Next: l1" ;;
      l1) echo "  Next: l2" ;;
      l2) echo "  Next: expert" ;;
      expert) echo "  Already at highest level" ;;
    esac
  else
    echo -e "${YELLOW}Skill Level: Not ready (need 80% completion)${NC}"
  fi
  
  if [ "$ready_phase" -eq 1 ]; then
    echo -e "${GREEN}$STAR Project Phase: READY TO ADVANCE${NC}"
    
    # Suggest next phase
    case "$CURRENT_PHASE" in
      poc) echo "  Next: mvp" ;;
      mvp) echo "  Next: beta" ;;
      beta) echo "  Next: scale" ;;
      scale) echo "  Already at highest phase" ;;
    esac
  else
    echo -e "${YELLOW}Project Phase: Not ready (need 80% completion)${NC}"
  fi
  
  echo ""
  echo "To advance when ready:"
  
  if [ "$ready_skill" -eq 1 ]; then
    echo "  scripts/graduate.sh advance"
  fi
  
  if [ "$ready_phase" -eq 1 ]; then
    echo "  scripts/graduate.sh advance"
  fi
}

# Advance to next level
advance() {
  check_profile
  get_current_levels
  check_ready
  
  local next_skill=""
  local next_phase=""
  
  # Determine next levels
  case "$CURRENT_SKILL" in
    vibe) next_skill="beginner" ;;
    beginner) next_skill="l1" ;;
    l1) next_skill="l2" ;;
    l2) next_skill="expert" ;;
  esac
  
  case "$CURRENT_PHASE" in
    poc) next_phase="mvp" ;;
    mvp) next_phase="beta" ;;
    beta) next_phase="scale" ;;
  esac
  
  echo ""
  echo -e "${BLUE}Select advancement:${NC}"
  echo "  1) Advance skill to: $next_skill"
  echo "  2) Advance phase to: $next_phase"
  echo "  3) Cancel"
  echo ""
  read -p "Choice [1-3]: " choice
  
  case "$choice" in
    1)
      if [ -n "$next_skill" ]; then
        echo -e "${GREEN}Advancing to skill level: $next_skill${NC}"
        scripts/apply_profile.sh --skill "$next_skill" --phase "$CURRENT_PHASE"
      else
        echo -e "${YELLOW}Already at highest skill level${NC}"
      fi
      ;;
    2)
      if [ -n "$next_phase" ]; then
        echo -e "${GREEN}Advancing to project phase: $next_phase${NC}"
        scripts/apply_profile.sh --skill "$CURRENT_SKILL" --phase "$next_phase"
      else
        echo -e "${YELLOW}Already at highest phase${NC}"
      fi
      ;;
    *)
      echo "Cancelled"
      ;;
  esac
}

# Main logic
case "$ACTION" in
  check)
    show_progress
    ;;
  complete)
    if [ -z "$ITEM_NUM" ]; then
      echo -e "${RED}Please specify item number${NC}"
      usage
    fi
    mark_complete "$ITEM_NUM"
    ;;
  reset)
    if [ -z "$ITEM_NUM" ]; then
      echo -e "${RED}Please specify item number${NC}"
      usage
    fi
    mark_incomplete "$ITEM_NUM"
    ;;
  ready)
    check_ready
    ;;
  advance)
    advance
    ;;
  --help|-h|help)
    usage
    ;;
  *)
    echo -e "${RED}Unknown action: $ACTION${NC}"
    usage
    ;;
esac
