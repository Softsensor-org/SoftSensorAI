#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# DevPilot Readiness Score (DPRS) - Measure repository maturity
set -euo pipefail

# Debug mode if DPRS_DEBUG is set
[ "${DPRS_DEBUG:-}" = "1" ] && set -x

# Ensure compatibility symlinks exist for reorganized structure
if [ ! -f package-lock.json ] && [ -f config/package-lock.json ]; then
  ln -sf config/package-lock.json package-lock.json 2>/dev/null || true
fi
if [ ! -f package.json ] && [ -f config/package.json ]; then
  ln -sf config/package.json package.json 2>/dev/null || true
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
OUTPUT_DIR="artifacts"
VERBOSE=0

usage() {
  cat <<EOF
DevPilot Readiness Score (DPRS) - Measure Repository Maturity

Usage: $0 [OPTIONS]

Options:
  --output DIR     Output directory (default: artifacts/)
  --verbose        Show detailed scoring breakdown
  --help           Show this help message

Scoring Categories:
  - Tests (25%): Coverage %, test files, CI passing
  - Security (25%): Vulnerability count, secret scanning, SARIF uploads
  - Documentation (25%): README, CONTRIBUTING, SECURITY, runbooks
  - Developer Experience (25%): Justfile, .envrc, package management

Output:
  - artifacts/dprs.json    (Machine-readable scores)
  - artifacts/dprs.md      (Human-readable report)

Examples:
  $0                       # Generate DPRS for current repo
  $0 --verbose             # Show detailed breakdown
  $0 --output reports/     # Custom output directory

EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      usage
      ;;
  esac
done

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get repository info
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)" 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TODAY=$(date +%Y-%m-%d)

echo -e "${BLUE}=== DevPilot Readiness Score (DPRS) ===${NC}"
echo "Repository: $REPO_NAME"
echo "Branch: $BRANCH"
echo "Commit: $SHA"
echo "Date: $TODAY"
echo ""

# Initialize scoring
TESTS_SCORE=0
SECURITY_SCORE=0
DOCS_SCORE=0
DX_SCORE=0
TOTAL_SCORE=0

# Category weights (must sum to 100)
TESTS_WEIGHT=25
SECURITY_WEIGHT=25
DOCS_WEIGHT=25
DX_WEIGHT=25

# Tests Score (0-100)
calculate_tests_score() {
  local score=0
  local details=""

  # Coverage percentage (40 points max)
  local coverage=0
  if [ -f "coverage/lcov-report/index.html" ]; then
    coverage=$(grep -o '[0-9]\+\.[0-9]\+%' coverage/lcov-report/index.html | head -1 | sed 's/%//' || echo "0")
  elif [ -f ".coverage" ]; then
    coverage=$(python3 -c "import coverage; cov = coverage.Coverage(); cov.load(); print(f'{cov.report(show_missing=False):.1f}')" 2>/dev/null || echo "0")
  elif [ -f "coverage.xml" ]; then
    coverage=$(grep 'line-rate' coverage.xml | head -1 | grep -o '[0-9]\+\.[0-9]\+' | awk '{print $1*100}' || echo "0")
  fi

  local coverage_points=$(echo "$coverage" | awk '{print int($1 * 0.4)}')
  score=$((score + coverage_points))
  details="$details\n  Coverage: ${coverage}% → $coverage_points/40 points"

  # Test files present (20 points)
  local test_files=$(find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -path "*/tests/*" -o -path "*/test/*" \) | wc -l)
  local test_points=0
  if [ "$test_files" -gt 50 ]; then
    test_points=20
  elif [ "$test_files" -gt 20 ]; then
    test_points=15
  elif [ "$test_files" -gt 5 ]; then
    test_points=10
  elif [ "$test_files" -gt 0 ]; then
    test_points=5
  fi
  score=$((score + test_points))
  details="$details\n  Test files: $test_files → $test_points/20 points"

  # CI/CD present (25 points)
  local ci_points=0
  if [ -f ".github/workflows/ci.yml" ] || [ -f ".gitlab-ci.yml" ] || [ -f ".circleci/config.yml" ]; then
    ci_points=25
  elif [ -d ".github/workflows" ] && [ "$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l)" -gt 0 ]; then
    ci_points=15
  fi
  score=$((score + ci_points))
  details="$details\n  CI/CD: $ci_points/25 points"

  # Package manager lockfiles (15 points)
  local lock_points=0
  # Check for lock files in both root and config/
  if [ -f "package-lock.json" ] || [ -f "config/package-lock.json" ] || \
     [ -f "yarn.lock" ] || [ -f "pnpm-lock.yaml" ] || \
     [ -f "requirements.txt" ] || [ -f "config/requirements.txt" ] || \
     [ -f "Pipfile.lock" ] || [ -f "Cargo.lock" ]; then
    lock_points=15
  fi
  score=$((score + lock_points))
  details="$details\n  Lockfiles: $lock_points/15 points"

  TESTS_SCORE=$score
  [ "$VERBOSE" -eq 1 ] && echo -e "${YELLOW}Tests Score Details:${NC}$details"
  return 0
}

# Security Score (0-100)
calculate_security_score() {
  local score=100  # Start with perfect score, deduct for issues
  local details=""

  # Check for security scan results
  local high_vulns=0
  local crit_vulns=0
  local secrets=0

  # Semgrep results
  if [ -f "semgrep-results.json" ]; then
    high_vulns=$(jq '[.results[] | select(.extra.severity == "WARNING" or .extra.severity == "ERROR")] | length' semgrep-results.json 2>/dev/null || echo "0")
  fi

  # Trivy results
  if [ -f "trivy-results.json" ]; then
    crit_vulns=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity == "CRITICAL" or .Severity == "HIGH")] | length' trivy-results.json 2>/dev/null || echo "0")
  fi

  # Gitleaks results
  if [ -f "gitleaks-results.json" ]; then
    secrets=$(jq '. | length' gitleaks-results.json 2>/dev/null || echo "0")
  fi

  # Deduct points for findings
  local vuln_deduction=$((high_vulns * 5 + crit_vulns * 10))
  local secret_deduction=$((secrets * 20))  # Secrets are critical
  score=$((score - vuln_deduction - secret_deduction))

  # Floor at 0
  [ "$score" -lt 0 ] && score=0

  details="$details\n  High/Critical vulnerabilities: $((high_vulns + crit_vulns)) → -$vuln_deduction points"
  details="$details\n  Exposed secrets: $secrets → -$secret_deduction points"

  # Bonus for security tooling
  local tooling_bonus=0
  [ -f ".github/workflows/security-review.yml" ] && tooling_bonus=$((tooling_bonus + 10))
  [ -f "SECURITY.md" ] && tooling_bonus=$((tooling_bonus + 5))
  [ -f ".trivyignore" ] || [ -f ".semgrepignore" ] && tooling_bonus=$((tooling_bonus + 5))

  score=$((score + tooling_bonus))
  [ "$score" -gt 100 ] && score=100
  details="$details\n  Security tooling bonus: +$tooling_bonus points"

  SECURITY_SCORE=$score
  [ "$VERBOSE" -eq 1 ] && echo -e "${YELLOW}Security Score Details:${NC}$details"
  return 0
}

# Documentation Score (0-100)
calculate_docs_score() {
  local score=0
  local details=""

  # Essential docs (60 points total)
  local readme_points=0
  if [ -f "README.md" ]; then
    local readme_size=$(wc -l < README.md)
    if [ "$readme_size" -gt 200 ]; then
      readme_points=25
    elif [ "$readme_size" -gt 50 ]; then
      readme_points=15
    elif [ "$readme_size" -gt 10 ]; then
      readme_points=10
    fi
  fi
  score=$((score + readme_points))
  details="$details\n  README.md: $readme_points/25 points"

  local contributing_points=0
  # Check for CONTRIBUTING.md in both root and docs/
  { [ -f "CONTRIBUTING.md" ] || [ -f "docs/CONTRIBUTING.md" ]; } && contributing_points=15
  score=$((score + contributing_points))
  details="$details\n  CONTRIBUTING.md: $contributing_points/15 points"

  local security_doc_points=0
  # Check for SECURITY.md in both root and docs/
  { [ -f "SECURITY.md" ] || [ -f "docs/SECURITY.md" ]; } && security_doc_points=10
  score=$((score + security_doc_points))
  details="$details\n  SECURITY.md: $security_doc_points/10 points"

  local license_points=0
  [ -f "LICENSE" ] || [ -f "LICENSE.md" ] || [ -f "LICENSE.txt" ] && license_points=10
  score=$((score + license_points))
  details="$details\n  LICENSE: $license_points/10 points"

  # API/Code documentation (25 points)
  local api_docs=0
  [ -f "docs/API.md" ] || [ -f "api.md" ] && api_docs=$((api_docs + 10))
  [ -d "docs/" ] && [ "$(ls -1 docs/*.md 2>/dev/null | wc -l)" -gt 3 ] && api_docs=$((api_docs + 10))
  [ -f "openapi.yml" ] || [ -f "swagger.yml" ] && api_docs=$((api_docs + 5))
  [ "$api_docs" -gt 25 ] && api_docs=25
  score=$((score + api_docs))
  details="$details\n  API/Code docs: $api_docs/25 points"

  # Changelog/Releases (15 points)
  local changelog_points=0
  # Check for CHANGELOG in both root and docs/
  { [ -f "CHANGELOG.md" ] || [ -f "docs/CHANGELOG.md" ] || [ -f "HISTORY.md" ]; } && changelog_points=15
  score=$((score + changelog_points))
  details="$details\n  CHANGELOG: $changelog_points/15 points"

  DOCS_SCORE=$score
  [ "$VERBOSE" -eq 1 ] && echo -e "${YELLOW}Documentation Score Details:${NC}$details"
  return 0
}

# Developer Experience Score (0-100)
calculate_dx_score() {
  local score=0
  local details=""

  # Task runner (25 points)
  local task_points=0
  if [ -f "justfile" ]; then
    local just_targets=$(grep '^[a-zA-Z][a-zA-Z0-9_-]*:' justfile | wc -l)
    if [ "$just_targets" -gt 10 ]; then
      task_points=25
    elif [ "$just_targets" -gt 5 ]; then
      task_points=20
    elif [ "$just_targets" -gt 0 ]; then
      task_points=15
    fi
  elif [ -f "Makefile" ]; then
    task_points=15
  elif { [ -f "package.json" ] && grep -q '"scripts"' package.json; } || \
       { [ -f "config/package.json" ] && grep -q '"scripts"' config/package.json; }; then
    task_points=10
  fi
  score=$((score + task_points))
  details="$details\n  Task runner: $task_points/25 points"

  # Environment management (20 points)
  local env_points=0
  [ -f ".envrc" ] && env_points=$((env_points + 10))
  [ -f ".env.example" ] || [ -f ".env.template" ] && env_points=$((env_points + 5))
  [ -f ".mise.toml" ] || [ -f ".tool-versions" ] && env_points=$((env_points + 5))
  score=$((score + env_points))
  details="$details\n  Environment: $env_points/20 points"

  # AI/Claude integration (20 points)
  local ai_points=0
  [ -f "CLAUDE.md" ] && ai_points=$((ai_points + 10))
  [ -d ".claude/commands" ] && [ "$(ls -1 .claude/commands/*.md 2>/dev/null | wc -l)" -gt 5 ] && ai_points=$((ai_points + 10))
  score=$((score + ai_points))
  details="$details\n  AI integration: $ai_points/20 points"

  # Development tooling (20 points)
  local tooling_points=0
  [ -f ".pre-commit-config.yaml" ] && tooling_points=$((tooling_points + 5))
  [ -f ".editorconfig" ] && tooling_points=$((tooling_points + 5))
  [ -f ".gitignore" ] && [ "$(wc -l < .gitignore)" -gt 10 ] && tooling_points=$((tooling_points + 5))
  [ -f "docker-compose.yml" ] || [ -f "Dockerfile" ] && tooling_points=$((tooling_points + 5))
  score=$((score + tooling_points))
  details="$details\n  Dev tooling: $tooling_points/20 points"

  # Package manager health (15 points)
  local pkg_points=0
  # Check for package files in both root and config/
  if [ -f "package.json" ] || [ -f "config/package.json" ]; then
    # Check for security audit
    if command -v npm >/dev/null 2>&1; then
      npm audit --audit-level=high >/dev/null 2>&1 && pkg_points=$((pkg_points + 10))
    fi
    # Check for up-to-date dependencies would require network calls, skip
    pkg_points=$((pkg_points + 5))  # Basic package.json presence
  elif [ -f "requirements.txt" ] || [ -f "config/requirements.txt" ]; then
    pkg_points=10
  elif [ -f "Cargo.toml" ]; then
    pkg_points=10
  fi
  score=$((score + pkg_points))
  details="$details\n  Package health: $pkg_points/15 points"

  DX_SCORE=$score
  [ "$VERBOSE" -eq 1 ] && echo -e "${YELLOW}Developer Experience Score Details:${NC}$details"
  return 0
}

# Calculate phase readiness
calculate_phase_readiness() {
  local total=$1

  if [ "$total" -ge 90 ]; then
    echo "SCALE"
  elif [ "$total" -ge 75 ]; then
    echo "BETA"
  elif [ "$total" -ge 60 ]; then
    echo "MVP"
  elif [ "$total" -ge 40 ]; then
    echo "POC"
  else
    echo "INCEPTION"
  fi
}

# Get phase color
get_phase_color() {
  case "$1" in
    "SCALE") echo "$GREEN" ;;
    "BETA") echo "$BLUE" ;;
    "MVP") echo "$YELLOW" ;;
    "POC") echo "$YELLOW" ;;
    *) echo "$RED" ;;
  esac
}

# Calculate all scores
echo -e "${BLUE}Calculating scores...${NC}"
calculate_tests_score
calculate_security_score
calculate_docs_score
calculate_dx_score

# Calculate weighted total
TOTAL_SCORE=$(( (TESTS_SCORE * TESTS_WEIGHT + SECURITY_SCORE * SECURITY_WEIGHT + DOCS_SCORE * DOCS_WEIGHT + DX_SCORE * DX_WEIGHT) / 100 ))
PHASE_READINESS=$(calculate_phase_readiness "$TOTAL_SCORE")
PHASE_COLOR=$(get_phase_color "$PHASE_READINESS")

# Generate JSON output
cat > "$OUTPUT_DIR/dprs.json" <<EOF
{
  "repository": "$REPO_NAME",
  "branch": "$BRANCH",
  "commit": "$SHA",
  "date": "$TODAY",
  "total_score": $TOTAL_SCORE,
  "phase_readiness": "$PHASE_READINESS",
  "categories": {
    "tests": {
      "score": $TESTS_SCORE,
      "weight": $TESTS_WEIGHT,
      "weighted_score": $((TESTS_SCORE * TESTS_WEIGHT / 100))
    },
    "security": {
      "score": $SECURITY_SCORE,
      "weight": $SECURITY_WEIGHT,
      "weighted_score": $((SECURITY_SCORE * SECURITY_WEIGHT / 100))
    },
    "documentation": {
      "score": $DOCS_SCORE,
      "weight": $DOCS_WEIGHT,
      "weighted_score": $((DOCS_SCORE * DOCS_WEIGHT / 100))
    },
    "developer_experience": {
      "score": $DX_SCORE,
      "weight": $DX_WEIGHT,
      "weighted_score": $((DX_SCORE * DX_WEIGHT / 100))
    }
  },
  "thresholds": {
    "scale": 90,
    "beta": 75,
    "mvp": 60,
    "poc": 40
  }
}
EOF

# Generate Markdown report
cat > "$OUTPUT_DIR/dprs.md" <<EOF
# 📊 DevPilot Readiness Score (DPRS)

**Repository:** $REPO_NAME
**Branch:** $BRANCH
**Commit:** $SHA
**Date:** $TODAY

## Overall Score

### ${TOTAL_SCORE}/100 - Phase: $PHASE_READINESS

| Category | Score | Weight | Contribution |
|----------|-------|---------|-------------|
| 🧪 **Tests** | $TESTS_SCORE/100 | ${TESTS_WEIGHT}% | $((TESTS_SCORE * TESTS_WEIGHT / 100))/25 |
| 🔒 **Security** | $SECURITY_SCORE/100 | ${SECURITY_WEIGHT}% | $((SECURITY_SCORE * SECURITY_WEIGHT / 100))/25 |
| 📚 **Documentation** | $DOCS_SCORE/100 | ${DOCS_WEIGHT}% | $((DOCS_SCORE * DOCS_WEIGHT / 100))/25 |
| 🛠️ **Developer Experience** | $DX_SCORE/100 | ${DX_WEIGHT}% | $((DX_SCORE * DX_WEIGHT / 100))/25 |

## Phase Readiness Scale

| Phase | Threshold | Description |
|-------|-----------|-------------|
| 🚀 **SCALE** | 90+ | Production-ready with full automation |
| 🧪 **BETA** | 75+ | Feature-complete, ready for users |
| ⚡ **MVP** | 60+ | Core features working, basic quality gates |
| 🔬 **POC** | 40+ | Concept proven, exploring viability |
| 💡 **INCEPTION** | <40 | Early exploration phase |

## Recommendations

## 🎯 Improvement Opportunities

EOF

# Generate detailed, actionable improvements
if [ "$PHASE_READINESS" = "SCALE" ]; then
  echo "✅ **Excellent!** Your repository meets production standards." >> "$OUTPUT_DIR/dprs.md"
  echo "" >> "$OUTPUT_DIR/dprs.md"
  echo "### Maintain Excellence:" >> "$OUTPUT_DIR/dprs.md"
  echo "- Keep test coverage above 80%" >> "$OUTPUT_DIR/dprs.md"
  echo "- Monitor security vulnerabilities continuously" >> "$OUTPUT_DIR/dprs.md"
  echo "- Update dependencies regularly" >> "$OUTPUT_DIR/dprs.md"
else
  # Calculate points needed for next phase
  next_phase_score=60
  next_phase_name="MVP"
  if [ "$TOTAL_SCORE" -ge 60 ]; then
    next_phase_score=75
    next_phase_name="BETA"
  fi
  if [ "$TOTAL_SCORE" -ge 75 ]; then
    next_phase_score=90
    next_phase_name="SCALE"
  fi

  points_needed=$((next_phase_score - TOTAL_SCORE))
  echo "**Current Phase:** $PHASE_READINESS ($TOTAL_SCORE/100)" >> "$OUTPUT_DIR/dprs.md"
  echo "**Target Phase:** $next_phase_name ($next_phase_score/100)" >> "$OUTPUT_DIR/dprs.md"
  echo "**Points Needed:** $points_needed" >> "$OUTPUT_DIR/dprs.md"
  echo "" >> "$OUTPUT_DIR/dprs.md"

  # Testing improvements (highest impact)
  if [ "$TESTS_SCORE" -lt 90 ]; then
    echo "### 🧪 Testing Improvements (Current: $TESTS_SCORE/100)" >> "$OUTPUT_DIR/dprs.md"
    echo "" >> "$OUTPUT_DIR/dprs.md"

    # Coverage check
    if [ ! -f "coverage.xml" ] && [ ! -f ".coverage" ] && [ ! -f "coverage/lcov-report/index.html" ]; then
      echo "**🔴 Critical: No test coverage found (+40 points potential)**" >> "$OUTPUT_DIR/dprs.md"
      echo '```bash' >> "$OUTPUT_DIR/dprs.md"
      echo '# Python:' >> "$OUTPUT_DIR/dprs.md"
      echo 'pip install pytest-cov && pytest --cov --cov-report=xml' >> "$OUTPUT_DIR/dprs.md"
      echo '# JavaScript:' >> "$OUTPUT_DIR/dprs.md"
      echo 'npm test -- --coverage' >> "$OUTPUT_DIR/dprs.md"
      echo '# Go:' >> "$OUTPUT_DIR/dprs.md"
      echo 'go test -coverprofile=coverage.out ./...' >> "$OUTPUT_DIR/dprs.md"
      echo '```' >> "$OUTPUT_DIR/dprs.md"
      echo "" >> "$OUTPUT_DIR/dprs.md"
    fi

    # Test file count
    test_count=$(find . -type f \( -name "*.test.*" -o -name "*.spec.*" -o -path "*/tests/*" \) 2>/dev/null | wc -l)
    if [ "$test_count" -lt 20 ]; then
      echo "**⚠️ Add more tests (Current: $test_count files, +5-10 points)**" >> "$OUTPUT_DIR/dprs.md"
      echo "- Target: 20+ test files for +15 points, 50+ for +20 points" >> "$OUTPUT_DIR/dprs.md"
      echo "- Create unit tests for each module" >> "$OUTPUT_DIR/dprs.md"
      echo "- Add integration tests for workflows" >> "$OUTPUT_DIR/dprs.md"
      echo "" >> "$OUTPUT_DIR/dprs.md"
    fi
  fi

  # Documentation improvements
  if [ "$DOCS_SCORE" -lt 90 ]; then
    echo "### 📚 Documentation Improvements (Current: $DOCS_SCORE/100)" >> "$OUTPUT_DIR/dprs.md"
    echo "" >> "$OUTPUT_DIR/dprs.md"

    [ ! -f "README.md" ] && echo "- **Create README.md** (+25 points)" >> "$OUTPUT_DIR/dprs.md"
    [ ! -f "CONTRIBUTING.md" ] && [ ! -f "docs/CONTRIBUTING.md" ] && echo "- **Add CONTRIBUTING.md** (+15 points)" >> "$OUTPUT_DIR/dprs.md"
    [ ! -f "CHANGELOG.md" ] && [ ! -f "docs/CHANGELOG.md" ] && echo "- **Maintain CHANGELOG.md** (+15 points)" >> "$OUTPUT_DIR/dprs.md"
    [ ! -d "docs" ] && echo "- **Create docs/ with API documentation** (+10 points)" >> "$OUTPUT_DIR/dprs.md"
    echo "" >> "$OUTPUT_DIR/dprs.md"
  fi

  # Developer Experience improvements
  if [ "$DX_SCORE" -lt 90 ]; then
    echo "### 🛠️ Developer Experience Improvements (Current: $DX_SCORE/100)" >> "$OUTPUT_DIR/dprs.md"
    echo "" >> "$OUTPUT_DIR/dprs.md"

    if [ ! -f "justfile" ] && [ ! -f "Makefile" ]; then
      echo "- **Add task runner** (justfile/Makefile) (+20 points)" >> "$OUTPUT_DIR/dprs.md"
      echo '  ```bash' >> "$OUTPUT_DIR/dprs.md"
      echo '  curl -sL https://just.systems/install.sh | bash' >> "$OUTPUT_DIR/dprs.md"
      echo '  ```' >> "$OUTPUT_DIR/dprs.md"
    fi
    [ ! -f ".env.example" ] && echo "- **Create .env.example** (+5 points)" >> "$OUTPUT_DIR/dprs.md"
    [ ! -f ".pre-commit-config.yaml" ] && echo "- **Configure pre-commit hooks** (+5 points)" >> "$OUTPUT_DIR/dprs.md"
    [ ! -f "CLAUDE.md" ] && echo "- **Add CLAUDE.md for AI assistance** (+10 points)" >> "$OUTPUT_DIR/dprs.md"
    echo "" >> "$OUTPUT_DIR/dprs.md"
  fi

  # Quick wins summary
  echo "### ⚡ Quick Wins (Can implement today)" >> "$OUTPUT_DIR/dprs.md"
  echo "" >> "$OUTPUT_DIR/dprs.md"
  echo "1. **Set up test coverage** (if missing): +40 points" >> "$OUTPUT_DIR/dprs.md"
  echo "2. **Add missing documentation files**: +5-15 points each" >> "$OUTPUT_DIR/dprs.md"
  echo "3. **Create .env.example**: +5 points" >> "$OUTPUT_DIR/dprs.md"
  echo "4. **Add pre-commit hooks**: +5 points" >> "$OUTPUT_DIR/dprs.md"
fi

echo "" >> "$OUTPUT_DIR/dprs.md"
echo "---" >> "$OUTPUT_DIR/dprs.md"
echo "*Generated by DevPilot Readiness Score on $TODAY*" >> "$OUTPUT_DIR/dprs.md"

# Display results
echo ""
echo -e "${BLUE}=== DPRS Results ===${NC}"
echo -e "Total Score: ${PHASE_COLOR}${TOTAL_SCORE}/100${NC}"
echo -e "Phase Readiness: ${PHASE_COLOR}${PHASE_READINESS}${NC}"
echo ""
echo "Category Breakdown:"
echo -e "  Tests: ${TESTS_SCORE}/100"
echo -e "  Security: ${SECURITY_SCORE}/100"
echo -e "  Documentation: ${DOCS_SCORE}/100"
echo -e "  Developer Experience: ${DX_SCORE}/100"
echo ""
echo "Reports generated:"
echo "  📊 $OUTPUT_DIR/dprs.json"
echo "  📝 $OUTPUT_DIR/dprs.md"

exit 0
