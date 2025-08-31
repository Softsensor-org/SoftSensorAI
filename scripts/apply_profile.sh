#!/usr/bin/env bash
# Apply skill level and project phase profiles to configure the repository
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SKILL="beginner"
PHASE="mvp"
TEACH_MODE=""
SETUP_SCRIPTS_DIR="${SETUP_SCRIPTS_DIR:-$(dirname "$(dirname "$(realpath "$0")")")}"

# Usage
usage() {
  cat <<EOF
Apply Profile - Configure repository for skill level and project phase

Usage: $0 [OPTIONS]

Options:
  --skill LEVEL     Skill level: vibe, beginner, l1, l2, expert (default: beginner)
  --phase PHASE     Project phase: poc, mvp, beta, scale (default: mvp)
  --teach-mode MODE Teaching mode: on, off (default: based on skill level)
  --help            Show this help message

Examples:
  $0 --skill beginner --phase mvp --teach-mode on
  $0 --skill expert --phase scale
  $0 --skill vibe --phase poc

Current Profile:
EOF
  
  if [ -f "PROFILE.md" ]; then
    grep "^- " PROFILE.md | head -5
  else
    echo "  No profile configured yet"
  fi
  
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)
      SKILL="$2"
      shift 2
      ;;
    --phase)
      PHASE="$2"
      shift 2
      ;;
    --teach-mode)
      TEACH_MODE="$2"
      shift 2
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

# Validate inputs
VALID_SKILLS="vibe beginner l1 l2 expert"
VALID_PHASES="poc mvp beta scale"

if ! echo "$VALID_SKILLS" | grep -w "$SKILL" > /dev/null; then
  echo -e "${RED}Invalid skill level: $SKILL${NC}"
  echo "Valid options: $VALID_SKILLS"
  exit 1
fi

if ! echo "$VALID_PHASES" | grep -w "$PHASE" > /dev/null; then
  echo -e "${RED}Invalid phase: $PHASE${NC}"
  echo "Valid options: $VALID_PHASES"
  exit 1
fi

# Set teach mode default based on skill if not specified
if [ -z "$TEACH_MODE" ]; then
  case "$SKILL" in
    vibe|beginner)
      TEACH_MODE="on"
      ;;
    *)
      TEACH_MODE="off"
      ;;
  esac
fi

echo -e "${BLUE}=== Applying Profile ===${NC}"
echo -e "Skill Level: ${GREEN}$SKILL${NC}"
echo -e "Project Phase: ${GREEN}$PHASE${NC}"
echo -e "Teach Mode: ${GREEN}$TEACH_MODE${NC}"
echo ""

# Function to merge JSON files
merge_json() {
  local base="$1"
  local overlay="$2"
  local output="$3"
  
  if command -v jq >/dev/null 2>&1; then
    if [ -f "$base" ]; then
      jq -s '.[0] * .[1]' "$base" "$overlay" > "$output"
    else
      cp "$overlay" "$output"
    fi
  else
    # Fallback without jq - just copy overlay
    echo -e "${YELLOW}Warning: jq not installed, using simple copy${NC}"
    cp "$overlay" "$output"
  fi
}

# 1. Apply permissions
echo -e "${BLUE}1. Configuring permissions...${NC}"
PERM_FILE="$SETUP_SCRIPTS_DIR/profiles/skills/permissions-${SKILL}.json"

if [ -f "$PERM_FILE" ]; then
  mkdir -p .claude
  
  # If settings.json exists, merge; otherwise copy
  if [ -f ".claude/settings.json" ]; then
    cp .claude/settings.json .claude/settings.json.backup
    merge_json .claude/settings.json "$PERM_FILE" .claude/settings.json.tmp
    mv .claude/settings.json.tmp .claude/settings.json
    echo "  ✓ Merged permissions into .claude/settings.json"
  else
    cp "$PERM_FILE" .claude/settings.json
    echo "  ✓ Created .claude/settings.json"
  fi
  
  # Add teach mode to env
  if command -v jq >/dev/null 2>&1; then
    if [ "$TEACH_MODE" = "on" ]; then
      jq '.env.TEACH_MODE = "1"' .claude/settings.json > .claude/settings.json.tmp
    else
      jq '.env.TEACH_MODE = "0"' .claude/settings.json > .claude/settings.json.tmp
    fi
    mv .claude/settings.json.tmp .claude/settings.json
  fi
else
  echo -e "${RED}  ✗ Permissions file not found: $PERM_FILE${NC}"
fi

# 2. Setup command sets
echo -e "${BLUE}2. Installing command sets...${NC}"
COMMANDS_DIR="$SETUP_SCRIPTS_DIR/.claude/commands/sets/$SKILL"

if [ -d "$COMMANDS_DIR" ]; then
  mkdir -p .claude/commands
  
  # Remove old symlinks
  find .claude/commands -type l -delete 2>/dev/null || true
  
  # Create new symlinks
  for cmd in "$COMMANDS_DIR"/*.md; do
    if [ -f "$cmd" ]; then
      cmd_name=$(basename "$cmd")
      ln -sf "$cmd" ".claude/commands/$cmd_name"
      echo "  ✓ Linked command: $cmd_name"
    fi
  done
else
  echo -e "${YELLOW}  ⚠ No command set found for skill level: $SKILL${NC}"
fi

# 3. Configure CI workflow
echo -e "${BLUE}3. Configuring CI workflow...${NC}"
CI_FILE="$SETUP_SCRIPTS_DIR/profiles/phases/ci-${PHASE}.yml"

if [ -f "$CI_FILE" ]; then
  mkdir -p .github/workflows
  cp "$CI_FILE" .github/workflows/ci.yml
  echo "  ✓ Installed CI workflow for $PHASE phase"
else
  echo -e "${RED}  ✗ CI workflow not found: $CI_FILE${NC}"
fi

# 4. Create PROFILE.md
echo -e "${BLUE}4. Creating profile documentation...${NC}"
cat > PROFILE.md <<EOF
# Repository Profile

## Current Configuration
- **Skill Level**: $SKILL
- **Project Phase**: $PHASE  
- **Teach Mode**: $TEACH_MODE
- **Profile Applied**: $(date '+%Y-%m-%d %H:%M:%S')

## Skill Level: $SKILL
EOF

case "$SKILL" in
  vibe)
    cat >> PROFILE.md <<'EOF'
**For**: Product managers, designers, non-engineers
**Capabilities**: Read-only exploration, explanations, mockups
**Restrictions**: No direct code execution, guided scripts only
**Focus**: Understanding and communication

### Available Commands
- `/explain-this-file` - Understand any file in simple terms
- `/mock-a-screen` - Create UI mockups
- `/generate-readme` - Write documentation
- `/draft-api-from-text` - Design APIs from descriptions
EOF
    ;;
  beginner)
    cat >> PROFILE.md <<'EOF'
**For**: Developers new to the codebase and AI tools
**Capabilities**: Basic development tasks with guidance
**Restrictions**: Limited to safe operations, requires approval for destructive actions
**Focus**: Learning best practices

### Available Commands
- `/explore-plan-code-test` - Structured development workflow
- `/fix-ci-failures` - Debug CI issues with explanations
- `/chain-spec` - Create specifications
- `/chain-tests` - Write test cases
EOF
    ;;
  l1)
    cat >> PROFILE.md <<'EOF'
**For**: Junior developers comfortable with basics
**Capabilities**: Testing, linting, basic security scans
**Restrictions**: Deployment and infrastructure changes require approval
**Focus**: Code quality and testing

### Available Commands
- `/secure-fix` - Find and fix security issues
- `/perf-scan` - Basic performance analysis
- `/api-contract-update` - Update API specifications
- All beginner commands
EOF
    ;;
  l2)
    cat >> PROFILE.md <<'EOF'
**For**: Intermediate developers
**Capabilities**: Migrations, performance testing, security tools
**Restrictions**: Production deployments require approval
**Focus**: Performance and security

### Available Commands
- `/migration-plan` - Database migration planning
- `/observability-pass` - Add monitoring and logging
- `/k8s-dry-run` - Kubernetes deployment preview
- All L1 commands
EOF
    ;;
  expert)
    cat >> PROFILE.md <<'EOF'
**For**: Senior developers and technical leads
**Capabilities**: Full tool access, architecture decisions
**Restrictions**: Minimal - focuses on risk management
**Focus**: Architecture, performance, and production readiness

### Available Commands
- `/architect-spike` - Evaluate technical approaches
- `/think-hard` - Deep problem analysis
- `/release-notes` - Generate release documentation
- All commands available
EOF
    ;;
esac

cat >> PROFILE.md <<EOF

## Project Phase: $PHASE
EOF

case "$PHASE" in
  poc)
    cat >> PROFILE.md <<'EOF'
**Goal**: Prove feasibility quickly
**CI/CD**: Minimal - linting and tests are advisory only
**Quality Gates**: None enforced
**Focus**: Speed of iteration, demos, prototypes

### Phase Characteristics
- Tests optional
- Security scans advisory only
- No coverage requirements
- Breaking changes allowed
EOF
    ;;
  mvp)
    cat >> PROFILE.md <<'EOF'
**Goal**: First usable version
**CI/CD**: Basic - linting, type checking, unit tests required
**Quality Gates**: Must pass basic quality checks
**Focus**: Core functionality with basic quality

### Phase Characteristics
- Unit tests required
- Linting enforced
- Security scans advisory
- Basic documentation required
EOF
    ;;
  beta)
    cat >> PROFILE.md <<'EOF'
**Goal**: Production-ready for early adopters
**CI/CD**: Comprehensive - quality, security, and performance checks
**Quality Gates**: 60% coverage, security scans, integration tests
**Focus**: Stability, security, performance baseline

### Phase Characteristics
- 60% test coverage minimum
- Security scans blocking for HIGH/CRITICAL
- Integration tests required
- Performance budgets tracked
- API contracts validated
EOF
    ;;
  scale)
    cat >> PROFILE.md <<'EOF'
**Goal**: Full production with SLOs
**CI/CD**: Production-grade - all gates enforced
**Quality Gates**: 80% coverage, performance gates, SLO monitoring
**Focus**: Reliability, performance, cost optimization

### Phase Characteristics
- 80% test coverage minimum
- Mutation testing tracked
- Load testing required
- SLO monitoring active
- Full observability required
- Deployment requires approvals
EOF
    ;;
esac

cat >> PROFILE.md <<'EOF'

## Graduation Criteria

### To Next Skill Level
EOF

case "$SKILL" in
  vibe)
    cat >> PROFILE.md <<'EOF'
- [ ] Complete 3 tasks using scripts
- [ ] Understand Plan→Code→Test workflow
- [ ] Can run `pnpm test` independently
- [ ] Ready to write simple code changes
EOF
    ;;
  beginner)
    cat >> PROFILE.md <<'EOF'
- [ ] Write failing tests first consistently
- [ ] Pass CI without mentor help
- [ ] Use `/secure-fix` successfully
- [ ] Understand atomic commits
EOF
    ;;
  l1)
    cat >> PROFILE.md <<'EOF'
- [ ] Ship a database migration safely
- [ ] Add performance tests
- [ ] Triage security findings correctly
- [ ] Lead a small feature end-to-end
EOF
    ;;
  l2)
    cat >> PROFILE.md <<'EOF'
- [ ] Complete an architecture spike
- [ ] Implement observability for a service
- [ ] Optimize performance bottleneck
- [ ] Mentor a beginner successfully
EOF
    ;;
  expert)
    cat >> PROFILE.md <<'EOF'
You've reached expert level! Consider:
- [ ] Define team coding standards
- [ ] Lead architecture decisions
- [ ] Establish SLOs and error budgets
- [ ] Create team playbooks
EOF
    ;;
esac

cat >> PROFILE.md <<'EOF'

### To Next Project Phase
EOF

case "$PHASE" in
  poc)
    cat >> PROFILE.md <<'EOF'
- [ ] Core concept proven
- [ ] Basic tests written
- [ ] Key risks identified
- [ ] MVP scope defined
EOF
    ;;
  mvp)
    cat >> PROFILE.md <<'EOF'
- [ ] Core features complete
- [ ] 60% test coverage achieved
- [ ] Security scan clean (no HIGH)
- [ ] Basic documentation complete
EOF
    ;;
  beta)
    cat >> PROFILE.md <<'EOF'
- [ ] 80% test coverage achieved
- [ ] Performance validated at scale
- [ ] SLOs defined and measured
- [ ] Observability implemented
EOF
    ;;
  scale)
    cat >> PROFILE.md <<'EOF'
Already at Scale phase! Focus on:
- [ ] Cost optimization
- [ ] Performance improvements
- [ ] Reliability enhancements
- [ ] Feature velocity
EOF
    ;;
esac

cat >> PROFILE.md <<'EOF'

## Quick Commands

View current profile:
```bash
scripts/profile_show.sh
```

Change skill level:
```bash
scripts/apply_profile.sh --skill l2
```

Change project phase:
```bash
scripts/apply_profile.sh --phase beta
```

## Resources

- [Skill Level Descriptions](profiles/skills/)
- [Project Phase Workflows](.github/workflows/)
- [Available Commands](.claude/commands/)
EOF

echo "  ✓ Created PROFILE.md"

# 5. System prompt layering
echo -e "${BLUE}5. System prompt layering...${NC}"
mkdir -p system
if [ -f "$SETUP_SCRIPTS_DIR/templates/system/00-global.md" ]; then
  cp -n "$SETUP_SCRIPTS_DIR/templates/system/00-global.md" system/00-global.md || true
fi
if [ -f "$SETUP_SCRIPTS_DIR/templates/system/10-repo.md" ]; then
  cp -n "$SETUP_SCRIPTS_DIR/templates/system/10-repo.md" system/10-repo.md || true
fi
if [ -f "$SETUP_SCRIPTS_DIR/templates/system/20-task.md" ] && [ ! -f system/20-task.md ]; then
  cp "$SETUP_SCRIPTS_DIR/templates/system/20-task.md" system/20-task.md || true
fi
{
  [ -f system/00-global.md ] && cat system/00-global.md || true
  echo
  [ -f system/10-repo.md ] && cat system/10-repo.md || true
  echo
  [ -f system/20-task.md ] && cat system/20-task.md || true
} > system/active.md
echo "  ✓ Wrote system/active.md"

# 6. Summary
echo ""
echo -e "${GREEN}=== Profile Applied Successfully ===${NC}"
echo ""
echo "Summary of changes:"
echo "  • Permissions: Configured for $SKILL level"
echo "  • Commands: Installed for $SKILL level"
echo "  • CI/CD: Configured for $PHASE phase"
echo "  • Documentation: PROFILE.md created"
echo ""
echo "Next steps:"
echo "  1. Review PROFILE.md for your capabilities and restrictions"
echo "  2. Check graduation criteria to advance"
echo "  3. Run 'scripts/profile_show.sh' to see current status"
echo ""

# 7. Git ignore entries
if [ -f .gitignore ]; then
  grep -q "PROFILE.md" .gitignore || echo "PROFILE.md" >> .gitignore
  grep -q ".claude/settings.json.backup" .gitignore || echo ".claude/settings.json.backup" >> .gitignore
fi
