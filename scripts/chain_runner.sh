#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Chain Runner - Execute multi-step chains with proper handoffs
set -euo pipefail

# Bash version guard (macOS default bash is 3.2). Re-exec with Homebrew bash if available.
req_major=4
cur_major=${BASH_VERSINFO[0]:-0}
if [ "$cur_major" -lt "$req_major" ]; then
  for brew_bash in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    if [ -x "$brew_bash" ]; then
      exec "$brew_bash" "$0" "$@"
    fi
  done
  echo "Error: bash >= ${req_major} required. Install with 'brew install bash' and retry." >&2
  exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHAINS_DIR="${CHAINS_DIR:-chains}"
CHAIN_TYPE="${1:-}"
TASK_NAME="${2:-task-$(date +%Y%m%d-%H%M%S)}"
STEP="${3:-1}"

# Show usage
usage() {
  cat <<EOF
Chain Runner - Execute structured multi-step workflows

Usage: $0 <chain-type> [task-name] [starting-step]

Chain Types:
  backend     - 5-step backend feature implementation
  security    - 4-step security audit and fixes
  refactor    - 3-step code refactoring
  document    - 3-step document/contract analysis
  ml-pipeline - 5-step ML model development

Task Name:
  Optional identifier for organizing outputs (default: task-TIMESTAMP)

Starting Step:
  Resume from specific step (default: 1)

Examples:
  $0 backend feature-auth
  $0 security audit-2024
  $0 refactor cleanup-utils 2  # Resume from step 2

Outputs:
  chains/<task-name>/
    ├── step1_<name>.md
    ├── step2_<name>.md
    └── ...

Environment:
  CHAINS_DIR    - Output directory (default: chains)
  AUTO_PROCEED  - Skip confirmations between steps (default: no)
EOF
  exit 0
}

# Validate arguments
[[ -z "$CHAIN_TYPE" || "$CHAIN_TYPE" == "--help" || "$CHAIN_TYPE" == "-h" ]] && usage

# Chain definitions
declare -A CHAIN_STEPS
CHAIN_STEPS[backend]="spec tests code verify pr"
CHAIN_STEPS[security]="scan prioritize fix report"
CHAIN_STEPS[refactor]="analyze refactor validate"
CHAIN_STEPS[document]="extract email tone"
CHAIN_STEPS[ml-pipeline]="profile features model evaluate errors"

# Validate chain type
if [[ -z "${CHAIN_STEPS[$CHAIN_TYPE]:-}" ]]; then
  echo -e "${RED}Error: Unknown chain type '$CHAIN_TYPE'${NC}"
  echo "Valid types: ${!CHAIN_STEPS[*]}"
  exit 1
fi

# Setup workspace
TASK_DIR="$CHAINS_DIR/$TASK_NAME"
mkdir -p "$TASK_DIR"

# Get steps for this chain
IFS=' ' read -ra STEPS <<< "${CHAIN_STEPS[$CHAIN_TYPE]}"
TOTAL_STEPS=${#STEPS[@]}

# Helper functions
log_step() {
  echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}► Chain: $CHAIN_TYPE | Step $1/$TOTAL_STEPS: ${STEPS[$1-1]}${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

save_output() {
  local step_num=$1
  local step_name=${STEPS[$step_num-1]}
  local output_file="$TASK_DIR/step${step_num}_${step_name}.md"

  cat > "$output_file" <<EOF
# Chain: $CHAIN_TYPE - Step $step_num/$TOTAL_STEPS - ${step_name^^}
**Task**: $TASK_NAME
**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Input from Previous Step
$(if [[ $step_num -gt 1 ]]; then
    prev_step=$((step_num - 1))
    prev_file="$TASK_DIR/step${prev_step}_${STEPS[$prev_step-1]}.md"
    if [[ -f "$prev_file" ]]; then
      echo '```'
      grep -A 1000 "^<handoff>" "$prev_file" 2>/dev/null || echo "No handoff found"
      echo '```'
    fi
  else
    echo "N/A - First step"
  fi)

## Work for This Step
$2

## Handoff to Next Step
<handoff>
$3
</handoff>
EOF

  echo -e "${GREEN}✓ Output saved to: $output_file${NC}"
}

check_proceed() {
  if [[ "${AUTO_PROCEED:-}" != "yes" ]]; then
    echo -e "\n${YELLOW}Ready to proceed to next step?${NC}"
    read -p "Press Enter to continue or Ctrl+C to stop: "
  fi
}

show_command() {
  local step_num=$1
  local step_name=${STEPS[$step_num-1]}
  local cmd_file=".claude/commands/chains/${CHAIN_TYPE}-${step_num}-${step_name}.md"

  if [[ -f "$cmd_file" ]]; then
    echo -e "${BLUE}Command template available:${NC}"
    echo "  $cmd_file"
    echo ""
    echo "Quick preview:"
    grep -E "^<goal>|^<plan>" "$cmd_file" | head -10
  else
    echo -e "${YELLOW}No command template found at: $cmd_file${NC}"
  fi
}

# Main execution loop
echo -e "${GREEN}Starting chain: $CHAIN_TYPE${NC}"
echo -e "Task: $TASK_NAME"
echo -e "Output directory: $TASK_DIR"
echo ""

for ((i=STEP; i<=TOTAL_STEPS; i++)); do
  log_step $i

  # Show available command
  show_command $i

  # Wait for user to indicate completion
  echo -e "\n${YELLOW}Complete step $i (${STEPS[$i-1]}) using the command template.${NC}"
  echo "When done, paste the output below (end with 'END' on its own line):"

  # Collect output
  output=""
  handoff=""
  while IFS= read -r line; do
    [[ "$line" == "END" ]] && break
    output="${output}${line}"$'\n'
  done

  # Extract handoff if present
  if echo "$output" | grep -q "<handoff>"; then
    handoff=$(echo "$output" | sed -n '/<handoff>/,/<\/handoff>/p')
  fi

  # Save step output
  save_output $i "$output" "$handoff"

  # Check if we should continue
  if [[ $i -lt $TOTAL_STEPS ]]; then
    check_proceed
  fi
done

# Final summary
echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Chain Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Summary:"
echo "  Chain: $CHAIN_TYPE"
echo "  Task: $TASK_NAME"
echo "  Steps completed: $TOTAL_STEPS"
echo ""
echo "Outputs:"
ls -la "$TASK_DIR"
echo ""
echo "Next steps:"
echo "  1. Review outputs in: $TASK_DIR"
echo "  2. Create PR/commit if applicable"
echo "  3. Archive successful chains for reference"
