#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Release readiness assessment - aggregates critical metrics for go/no-go decision
set -euo pipefail

# Configuration
TICKETS_CSV="${1:-artifacts/tickets.csv}"
PHASE="${2:-${PROJECT_PHASE:-mvp}}"
COVERAGE_FILE="${3:-coverage/coverage-summary.json}"
SECURITY_FILE="${4:-artifacts/security-report.json}"

# Color codes (minimal, professional)
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper functions
say() { printf "%s\n" "$*"; }
metric() { printf "  %-20s %s\n" "$1:" "$2"; }

# Detect project info
PROJECT_NAME=$(basename "$PWD")
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Count P0 tickets from CSV
count_p0_tickets() {
  if [[ -f "$TICKETS_CSV" ]]; then
    # Count lines with "P0" or "critical" in priority column (usually column 4)
    awk -F',' '$4 ~ /P0|critical/ {count++} END {print count+0}' "$TICKETS_CSV"
  else
    echo "0"
  fi
}

# Get test coverage
get_coverage() {
  if [[ -f "$COVERAGE_FILE" ]]; then
    # Try to extract total coverage from common formats
    if command -v jq >/dev/null 2>&1; then
      jq -r '.total.lines.pct // .total.statements.pct // 0' "$COVERAGE_FILE" 2>/dev/null || echo "0"
    else
      grep -oE '"pct":[0-9.]+' "$COVERAGE_FILE" | head -1 | cut -d: -f2 || echo "0"
    fi
  elif [[ -f "coverage.xml" ]]; then
    # Try cobertura format
    grep -oE 'line-rate="[0-9.]+"' coverage.xml | head -1 | cut -d'"' -f2 | awk '{print $1*100}' || echo "0"
  elif command -v npm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
    # Try to run coverage command
    npm run test:coverage --silent 2>/dev/null | grep -oE '[0-9.]+%' | head -1 | tr -d '%' || echo "0"
  elif command -v pytest >/dev/null 2>&1 && [[ -d "tests" ]]; then
    # Try Python coverage
    pytest --cov=. --cov-report=term 2>/dev/null | grep TOTAL | awk '{print $4}' | tr -d '%' || echo "0"
  else
    echo "0"
  fi
}

# Count security issues
count_security_issues() {
  local critical=0
  local high=0

  if [[ -f "$SECURITY_FILE" ]]; then
    if command -v jq >/dev/null 2>&1; then
      critical=$(jq '[.vulnerabilities[]? | select(.severity=="critical")] | length' "$SECURITY_FILE" 2>/dev/null || echo 0)
      high=$(jq '[.vulnerabilities[]? | select(.severity=="high")] | length' "$SECURITY_FILE" 2>/dev/null || echo 0)
    fi
  elif command -v npm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
    # Try npm audit
    local audit_output
    audit_output=$(npm audit --json 2>/dev/null || echo '{}')
    if [[ -n "$audit_output" ]]; then
      critical=$(echo "$audit_output" | jq '.metadata.vulnerabilities.critical // 0' 2>/dev/null || echo 0)
      high=$(echo "$audit_output" | jq '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo 0)
    fi
  elif command -v safety >/dev/null 2>&1 && [[ -f "requirements.txt" ]]; then
    # Try Python safety check
    safety check --json 2>/dev/null | jq '[.[] | select(.severity=="high")] | length' 2>/dev/null || echo 0
  fi

  echo "$critical:$high"
}

# Check CI status
get_ci_status() {
  # Check GitHub Actions
  if [[ -d ".github/workflows" ]] && command -v gh >/dev/null 2>&1; then
    local status
    status=$(gh run list --branch="$BRANCH" --limit=1 --json status -q '.[0].status' 2>/dev/null || echo "unknown")
    case "$status" in
      completed) echo "passing" ;;
      in_progress) echo "running" ;;
      failure) echo "failing" ;;
      *) echo "unknown" ;;
    esac
  elif [[ -f ".gitlab-ci.yml" ]] && command -v glab >/dev/null 2>&1; then
    glab ci status 2>/dev/null | grep -oE 'passed|failed|running' | head -1 || echo "unknown"
  else
    echo "unknown"
  fi
}

# Determine phase-specific thresholds
set_thresholds() {
  case "$PHASE" in
    poc)
      P0_THRESHOLD=999  # No limit for POC
      COVERAGE_THRESHOLD=0
      SECURITY_CRITICAL_THRESHOLD=999
      SECURITY_HIGH_THRESHOLD=999
      ;;
    mvp)
      P0_THRESHOLD=5    # Advisory for MVP
      COVERAGE_THRESHOLD=40
      SECURITY_CRITICAL_THRESHOLD=3
      SECURITY_HIGH_THRESHOLD=10
      ;;
    beta)
      P0_THRESHOLD=0    # Must be zero for beta
      COVERAGE_THRESHOLD=60
      SECURITY_CRITICAL_THRESHOLD=0
      SECURITY_HIGH_THRESHOLD=3
      ;;
    scale|prod*)
      P0_THRESHOLD=0
      COVERAGE_THRESHOLD=80
      SECURITY_CRITICAL_THRESHOLD=0
      SECURITY_HIGH_THRESHOLD=0
      ;;
    *)
      P0_THRESHOLD=5
      COVERAGE_THRESHOLD=40
      SECURITY_CRITICAL_THRESHOLD=3
      SECURITY_HIGH_THRESHOLD=10
      ;;
  esac
}

# Main execution
main() {
  # Gather metrics
  local p0_count
  p0_count=$(count_p0_tickets)

  local coverage
  coverage=$(get_coverage)
  coverage=${coverage%.*}  # Remove decimals

  local security
  security=$(count_security_issues)
  IFS=: read -r sec_critical sec_high <<< "$security"

  local ci_status
  ci_status=$(get_ci_status)

  # Set thresholds based on phase
  set_thresholds

  # Determine overall status
  local status="READY"
  local status_color="$GREEN"
  local status_icon="✓"

  if [[ "$p0_count" -gt "$P0_THRESHOLD" ]]; then
    if [[ "$PHASE" == "mvp" ]]; then
      status="ADVISORY"
      status_color="$YELLOW"
      status_icon="!"
    else
      status="BLOCKED"
      status_color="$RED"
      status_icon="✗"
    fi
  fi

  if [[ "$coverage" -lt "$COVERAGE_THRESHOLD" ]]; then
    if [[ "$PHASE" == "mvp" ]]; then
      [[ "$status" != "BLOCKED" ]] && status="ADVISORY" && status_color="$YELLOW" && status_icon="!"
    else
      status="BLOCKED"
      status_color="$RED"
      status_icon="✗"
    fi
  fi

  if [[ "$sec_critical" -gt "$SECURITY_CRITICAL_THRESHOLD" ]]; then
    status="BLOCKED"
    status_color="$RED"
    status_icon="✗"
  elif [[ "$sec_high" -gt "$SECURITY_HIGH_THRESHOLD" ]]; then
    if [[ "$PHASE" == "mvp" ]]; then
      [[ "$status" != "BLOCKED" ]] && status="ADVISORY" && status_color="$YELLOW" && status_icon="!"
    else
      status="BLOCKED"
      status_color="$RED"
      status_icon="✗"
    fi
  fi

  # Print release readiness card
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  RELEASE READINESS REPORT${NC}"
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  metric "Project" "$PROJECT_NAME"
  metric "Branch" "$BRANCH @ $COMMIT"
  metric "Phase" "$(echo "$PHASE" | tr '[:lower:]' '[:upper:]')"
  metric "CI Status" "$ci_status"
  echo ""
  echo -e "${BOLD}  Metrics${NC}"
  echo "  ────────────────────"

  # P0 Tickets
  if [[ "$p0_count" -gt "$P0_THRESHOLD" ]]; then
    if [[ "$PHASE" == "mvp" ]]; then
      metric "P0 Tickets" "${YELLOW}${p0_count}${NC} (threshold: $P0_THRESHOLD)"
    else
      metric "P0 Tickets" "${RED}${p0_count}${NC} (threshold: $P0_THRESHOLD)"
    fi
  else
    metric "P0 Tickets" "${GREEN}${p0_count}${NC}"
  fi

  # Coverage
  if [[ "$coverage" -lt "$COVERAGE_THRESHOLD" ]]; then
    if [[ "$PHASE" == "mvp" ]]; then
      metric "Test Coverage" "${YELLOW}${coverage}%${NC} (threshold: ${COVERAGE_THRESHOLD}%)"
    else
      metric "Test Coverage" "${RED}${coverage}%${NC} (threshold: ${COVERAGE_THRESHOLD}%)"
    fi
  else
    metric "Test Coverage" "${GREEN}${coverage}%${NC}"
  fi

  # Security
  if [[ "$sec_critical" -gt 0 ]] || [[ "$sec_high" -gt "$SECURITY_HIGH_THRESHOLD" ]]; then
    metric "Security Issues" "${RED}Critical: $sec_critical, High: $sec_high${NC}"
  elif [[ "$sec_high" -gt 0 ]]; then
    metric "Security Issues" "${YELLOW}Critical: $sec_critical, High: $sec_high${NC}"
  else
    metric "Security Issues" "${GREEN}Critical: $sec_critical, High: $sec_high${NC}"
  fi

  echo ""
  echo -e "${BOLD}  Decision${NC}"
  echo "  ────────────────────"
  echo -e "  Status: ${status_color}${BOLD}$status_icon $status${NC}"

  # Phase-specific guidance
  echo ""
  case "$PHASE" in
    mvp)
      if [[ "$status" == "ADVISORY" ]]; then
        echo "  Note: MVP allows flexibility. Consider addressing:"
        [[ "$p0_count" -gt "$P0_THRESHOLD" ]] && echo "    • Reduce P0 tickets to $P0_THRESHOLD or less"
        [[ "$coverage" -lt "$COVERAGE_THRESHOLD" ]] && echo "    • Increase coverage to ${COVERAGE_THRESHOLD}%"
        [[ "$sec_high" -gt "$SECURITY_HIGH_THRESHOLD" ]] && echo "    • Fix high-severity security issues"
      fi
      ;;
    beta)
      if [[ "$status" == "BLOCKED" ]]; then
        echo "  Beta release requirements not met:"
        [[ "$p0_count" -gt 0 ]] && echo "    • All P0 tickets must be resolved"
        [[ "$coverage" -lt "$COVERAGE_THRESHOLD" ]] && echo "    • Coverage must be at least ${COVERAGE_THRESHOLD}%"
        [[ "$sec_critical" -gt 0 ]] && echo "    • No critical security issues allowed"
        [[ "$sec_high" -gt "$SECURITY_HIGH_THRESHOLD" ]] && echo "    • Maximum $SECURITY_HIGH_THRESHOLD high-severity issues"
      fi
      ;;
    scale|prod*)
      if [[ "$status" == "BLOCKED" ]]; then
        echo "  Production requirements not met:"
        [[ "$p0_count" -gt 0 ]] && echo "    • All P0 tickets must be resolved"
        [[ "$coverage" -lt "$COVERAGE_THRESHOLD" ]] && echo "    • Coverage must be at least ${COVERAGE_THRESHOLD}%"
        [[ "$sec_critical" -gt 0 ]] || [[ "$sec_high" -gt 0 ]] && echo "    • No security issues allowed"
      fi
      ;;
  esac

  echo ""
  echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Exit code based on status
  case "$status" in
    READY) exit 0 ;;
    ADVISORY) exit 0 ;;  # Advisory is still a pass for MVP
    BLOCKED) exit 1 ;;
  esac
}

# Run main
main "$@"
