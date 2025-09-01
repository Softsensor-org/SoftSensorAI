#!/usr/bin/env bash
# Display current profile status and progress toward graduation
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Icons
CHECK="✓"
CROSS="✗"
ARROW="→"
STAR="★"

# Extract current profile from PROFILE.md or settings
get_current_profile() {
  if [ -f "PROFILE.md" ]; then
    CURRENT_SKILL=$(grep "^\*\*Skill Level\*\*:" PROFILE.md | cut -d: -f2 | tr -d ' ' || echo "unknown")
    CURRENT_PHASE=$(grep "^\*\*Project Phase\*\*:" PROFILE.md | cut -d: -f2 | tr -d ' ' || echo "unknown")
    TEACH_MODE=$(grep "^\*\*Teach Mode\*\*:" PROFILE.md | cut -d: -f2 | tr -d ' ' || echo "unknown")
  else
    CURRENT_SKILL="not configured"
    CURRENT_PHASE="not configured"
    TEACH_MODE="not configured"
  fi
}

# Display skill level progress bar
show_skill_progress() {
  local current="$1"
  local skills=("vibe" "beginner" "l1" "l2" "expert")
  local labels=("Vibe" "Beginner" "Level 1" "Level 2" "Expert")
  
  echo -e "${BLUE}Skill Level Progress:${NC}"
  echo -n "  "
  
  local found=0
  for i in "${!skills[@]}"; do
    if [ "${skills[$i]}" = "$current" ]; then
      echo -ne "${GREEN}[${labels[$i]}]${NC}"
      found=1
    elif [ $found -eq 0 ]; then
      echo -ne "${GREEN}${CHECK}${NC} ${ARROW} "
    else
      echo -ne " ${ARROW} ${labels[$i]}"
    fi
  done
  echo ""
}

# Display phase progress bar
show_phase_progress() {
  local current="$1"
  local phases=("poc" "mvp" "beta" "scale")
  local labels=("POC" "MVP" "Beta" "Scale")
  
  echo -e "${BLUE}Project Phase Progress:${NC}"
  echo -n "  "
  
  local found=0
  for i in "${!phases[@]}"; do
    if [ "${phases[$i]}" = "$current" ]; then
      echo -ne "${GREEN}[${labels[$i]}]${NC}"
      found=1
    elif [ $found -eq 0 ]; then
      echo -ne "${GREEN}${CHECK}${NC} ${ARROW} "
    else
      echo -ne " ${ARROW} ${labels[$i]}"
    fi
  done
  echo ""
}

# Check capabilities based on skill level
show_capabilities() {
  local skill="$1"
  
  echo -e "${BLUE}Current Capabilities:${NC}"
  
  case "$skill" in
    vibe)
      echo "  ${CHECK} Read and explore code"
      echo "  ${CHECK} Generate documentation"
      echo "  ${CHECK} Create mockups"
      echo "  ${CROSS} Direct code execution"
      echo "  ${CROSS} Database operations"
      ;;
    beginner)
      echo "  ${CHECK} Edit code with guidance"
      echo "  ${CHECK} Run tests and lints"
      echo "  ${CHECK} Basic git operations"
      echo "  ${CROSS} Security tools"
      echo "  ${CROSS} Infrastructure changes"
      ;;
    l1)
      echo "  ${CHECK} Security scanning"
      echo "  ${CHECK} Performance testing"
      echo "  ${CHECK} API development"
      echo "  ${CROSS} Database migrations"
      echo "  ${CROSS} Production deployments"
      ;;
    l2)
      echo "  ${CHECK} Database migrations"
      echo "  ${CHECK} Docker operations"
      echo "  ${CHECK} Observability setup"
      echo "  ${CROSS} Terraform changes"
      echo "  ${CROSS} Force push to main"
      ;;
    expert)
      echo "  ${CHECK} Full tool access"
      echo "  ${CHECK} Architecture decisions"
      echo "  ${CHECK} Production deployments"
      echo "  ${CHECK} Infrastructure as Code"
      echo "  ${STAR} Mentor mode available"
      ;;
    *)
      echo "  Profile not configured - run: scripts/apply_profile.sh"
      ;;
  esac
}

# Show phase requirements
show_phase_requirements() {
  local phase="$1"
  
  echo -e "${BLUE}Phase Requirements:${NC}"
  
  case "$phase" in
    poc)
      echo "  ○ Tests: Optional"
      echo "  ○ Coverage: None"
      echo "  ○ Security: Advisory only"
      echo "  ○ CI/CD: Minimal"
      ;;
    mvp)
      echo "  ● Tests: Required"
      echo "  ○ Coverage: Tracked"
      echo "  ○ Security: Advisory"
      echo "  ● CI/CD: Basic gates"
      ;;
    beta)
      echo "  ● Tests: Unit + Integration"
      echo "  ● Coverage: ≥60%"
      echo "  ● Security: Blocking HIGH/CRITICAL"
      echo "  ● CI/CD: Comprehensive"
      ;;
    scale)
      echo "  ● Tests: Full suite + Load"
      echo "  ● Coverage: ≥80%"
      echo "  ● Security: All enforced"
      echo "  ● CI/CD: Production-grade"
      echo "  ● SLOs: Monitored"
      ;;
    *)
      echo "  Phase not configured"
      ;;
  esac
}

# Check graduation readiness
check_graduation() {
  if [ ! -f "PROFILE.md" ]; then
    return
  fi
  
  echo -e "${BLUE}Graduation Checklist:${NC}"
  
  # Extract and display checklist items
  awk '/^### To Next.*Level/,/^###|^##/ { 
    if (/^- \[.\]/) print "  " $0
  }' PROFILE.md | head -10
  
  # Count completed items
  local total=$(grep -c "^- \[.\]" PROFILE.md 2>/dev/null || echo 0)
  local completed=$(grep -c "^- \[x\]" PROFILE.md 2>/dev/null || echo 0)
  
  if [ "$total" -gt 0 ]; then
    local percent=$((completed * 100 / total))
    echo ""
    echo -e "  Progress: ${GREEN}$completed/$total${NC} ($percent%)"
    
    if [ "$percent" -ge 80 ]; then
      echo -e "  ${GREEN}${STAR} Ready for graduation!${NC}"
    fi
  fi
}

# Show recent activity
show_activity() {
  echo -e "${BLUE}Recent Activity:${NC}"
  
  # Check for recent git commits
  if [ -d .git ]; then
    local commits=$(git log --oneline -5 2>/dev/null | wc -l)
    echo "  Recent commits: $commits"
  fi
  
  # Check for test results
  if [ -f "coverage/coverage-summary.json" ]; then
    local coverage=$(grep -oP '"pct":\K[0-9.]+' coverage/coverage-summary.json | head -1)
    echo "  Test coverage: ${coverage}%"
  fi
  
  # Check CI status
  if [ -f ".github/workflows/ci.yml" ]; then
    local ci_phase=$(grep "^name:" .github/workflows/ci.yml | grep -oP 'CI - \K\w+' | tr '[:upper:]' '[:lower:]')
    echo "  CI configured for: $ci_phase phase"
  fi
}

# Main display
clear
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║             ${CYAN}Repository Profile Status${MAGENTA}                  ║${NC}"  
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

get_current_profile

# Current configuration
echo -e "${GREEN}Current Configuration:${NC}"
echo -e "  Skill Level: ${CYAN}$CURRENT_SKILL${NC}"
echo -e "  Project Phase: ${CYAN}$CURRENT_PHASE${NC}"
echo -e "  Teach Mode: ${CYAN}$TEACH_MODE${NC}"
echo ""

# Progress bars
show_skill_progress "$CURRENT_SKILL"
echo ""
show_phase_progress "$CURRENT_PHASE"
echo ""

# Capabilities and requirements
show_capabilities "$CURRENT_SKILL"
echo ""
show_phase_requirements "$CURRENT_PHASE"
echo ""

# Graduation status
check_graduation
echo ""

# Activity
show_activity
echo ""

# Quick actions
echo -e "${BLUE}Quick Actions:${NC}"
echo "  • Advance skill:  scripts/apply_profile.sh --skill <next_level>"
echo "  • Advance phase:  scripts/apply_profile.sh --phase <next_phase>"
echo "  • Toggle teaching: scripts/apply_profile.sh --teach-mode on|off"
echo "  • View details:   cat PROFILE.md"
echo ""

# Tips based on current level
echo -e "${YELLOW}Tips for Your Level:${NC}"
case "$CURRENT_SKILL" in
  vibe)
    echo "  💡 Start with /explain-this-file to understand the codebase"
    echo "  💡 Use /mock-a-screen to visualize your ideas"
    ;;
  beginner)
    echo "  💡 Always use /explore-plan-code-test for structured development"
    echo "  💡 Run tests before committing: pnpm test"
    ;;
  l1)
    echo "  💡 Try /secure-fix to find and fix security issues"
    echo "  💡 Use parallel tool calls for faster results"
    ;;
  l2)
    echo "  💡 Plan migrations carefully with /migration-plan"
    echo "  💡 Add observability before scaling"
    ;;
  expert)
    echo "  💡 Use /architect-spike for major decisions"
    echo "  💡 Document architectural decisions in ADRs"
    ;;
  *)
    echo "  💡 Configure your profile: scripts/apply_profile.sh --skill beginner --phase mvp"
    ;;
esac

echo ""
echo -e "${MAGENTA}════════════════════════════════════════════════════════${NC}"