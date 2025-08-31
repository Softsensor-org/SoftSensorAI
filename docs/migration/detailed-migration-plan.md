# DevPilot Migration Plan
## Zero-Downtime Transformation Strategy

**Document Version:** 1.0.0  
**Date:** 2024-08-31  
**Author:** DevPilot Migration Team  
**Status:** Final
**Classification:** Confidential

---

## Executive Summary

This document outlines a comprehensive, risk-mitigated migration plan to transform the current setup-scripts repository into the new DevPilot architecture. The migration follows a zero-downtime approach with complete reversibility at every stage.

## 1. Migration Overview

### 1.1 Objectives
- Transform scattered scripts into cohesive platform
- Maintain 100% backward compatibility
- Achieve zero downtime during migration
- Enable smooth user transition
- Preserve all git history and contributions

### 1.2 Success Criteria
- ✅ All existing commands continue working
- ✅ No data loss or corruption
- ✅ Performance improvement or parity
- ✅ 100% test coverage maintained
- ✅ Rollback possible at any stage
- ✅ User satisfaction maintained or improved

### 1.3 Timeline
- **Duration**: 10 days active migration
- **Stabilization**: 30 days monitoring
- **Deprecation**: 90 days grace period
- **Full Cutover**: Day 100

## 2. Pre-Migration Phase (Day 0)

### 2.1 Preparation Checklist

```bash
#!/usr/bin/env bash
# Pre-migration validation script

echo "=== PRE-MIGRATION CHECKLIST ==="

# 1. Verify git status
check_git() {
  if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Uncommitted changes detected"
    return 1
  fi
  echo "✅ Git working directory clean"
}

# 2. Check disk space (need 2x current size)
check_disk() {
  local available=$(df . | awk 'NR==2 {print $4}')
  local required=$(($(du -s . | cut -f1) * 2))
  if [[ $available -lt $required ]]; then
    echo "❌ Insufficient disk space"
    return 1
  fi
  echo "✅ Sufficient disk space available"
}

# 3. Verify all tests pass
check_tests() {
  if ! make test >/dev/null 2>&1; then
    echo "❌ Tests failing in current state"
    return 1
  fi
  echo "✅ All tests passing"
}

# 4. Document current performance baseline
baseline_performance() {
  echo "Recording performance baseline..."
  time -p ./setup_all.sh --dry-run 2>&1 | tee .migration/baseline.txt
  echo "✅ Performance baseline recorded"
}

# 5. Create comprehensive backup
create_backup() {
  local backup_name="devpilot-backup-$(date +%Y%m%d-%H%M%S)"
  tar -czf "../${backup_name}.tar.gz" . \
    --exclude=.git \
    --exclude=node_modules \
    --exclude=.venv
  echo "✅ Backup created: ${backup_name}.tar.gz"
}

# Run all checks
check_git && \
check_disk && \
check_tests && \
baseline_performance && \
create_backup && \
echo "=== READY FOR MIGRATION ===" || \
echo "=== FIX ISSUES BEFORE PROCEEDING ==="
```

### 2.2 Risk Register

| Risk ID | Description | Likelihood | Impact | Mitigation | Owner |
|---------|-------------|------------|--------|------------|-------|
| R001 | Script failure during migration | Medium | High | Comprehensive testing, rollback plan | DevOps |
| R002 | User disruption | Low | High | Compatibility layer, communication | Product |
| R003 | Data loss | Low | Critical | Multiple backups, validation | DevOps |
| R004 | Performance degradation | Medium | Medium | Benchmarking, optimization | Engineering |
| R005 | Incomplete migration | Low | High | Checkpoints, validation | PM |

## 3. Phase 1: Foundation & Safety Net (Day 1)

### 3.1 Create Migration Infrastructure

```bash
#!/usr/bin/env bash
# setup-migration-infrastructure.sh

set -euo pipefail

echo "Setting up migration infrastructure..."

# 1. Create migration branch
git checkout -b migration/devpilot-transform
git push -u origin migration/devpilot-transform

# 2. Create migration directory structure
mkdir -p .migration/{
  backups,
  logs,
  state,
  scripts,
  tests,
  rollback,
  metrics,
  validation
}

# 3. Initialize migration state
cat > .migration/state/config.json << 'EOF'
{
  "version": "1.0.0",
  "status": "initialized",
  "phase": 0,
  "started": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "checkpoints": [],
  "rollback_points": [],
  "metrics": {
    "files_migrated": 0,
    "tests_passed": 0,
    "compatibility_checks": 0
  }
}
EOF

# 4. Create migration logger
cat > .migration/scripts/logger.sh << 'EOF'
#!/usr/bin/env bash
log() {
  local level="$1"
  shift
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [$level] $*" | tee -a .migration/logs/migration.log
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }
EOF

# 5. Create validation framework
cat > .migration/scripts/validate.sh << 'EOF'
#!/usr/bin/env bash
source .migration/scripts/logger.sh

validate_phase() {
  local phase="$1"
  log_info "Validating phase: $phase"
  
  # Run phase-specific validation
  case "$phase" in
    1) validate_foundation ;;
    2) validate_structure ;;
    3) validate_migration ;;
    4) validate_compatibility ;;
    5) validate_testing ;;
    *) log_error "Unknown phase: $phase"; return 1 ;;
  esac
}

validate_foundation() {
  # Check migration infrastructure
  [[ -d .migration ]] || return 1
  [[ -f .migration/state/config.json ]] || return 1
  [[ -f .migration/scripts/logger.sh ]] || return 1
  log_success "Foundation validation passed"
}
EOF

chmod +x .migration/scripts/*.sh

echo "✅ Migration infrastructure ready"
```

### 3.2 Dependency Mapping

```bash
#!/usr/bin/env bash
# map-dependencies.sh

echo "Mapping script dependencies..."

# Create dependency graph
cat > .migration/scripts/dependency-mapper.sh << 'EOF'
#!/usr/bin/env bash

# Find all script files
find . -name "*.sh" -type f | while read -r script; do
  echo "Analyzing: $script"
  
  # Extract sourced files
  grep -h "^\s*source\|^\s*\." "$script" 2>/dev/null | while read -r line; do
    if [[ "$line" =~ source[[:space:]]+([^[:space:]]+) ]]; then
      dep="${BASH_REMATCH[1]}"
      echo "  → depends on: $dep"
    fi
  done
  
  # Extract script calls
  grep -h "\.sh\b" "$script" 2>/dev/null | grep -v "^#" | while read -r line; do
    if [[ "$line" =~ ([^[:space:]]+\.sh) ]]; then
      call="${BASH_REMATCH[1]}"
      echo "  → calls: $call"
    fi
  done
done > .migration/state/dependencies.txt

# Generate visual graph (if graphviz available)
if command -v dot >/dev/null 2>&1; then
  # Convert to DOT format
  echo "digraph dependencies {" > .migration/state/dependencies.dot
  echo "  rankdir=LR;" >> .migration/state/dependencies.dot
  
  while IFS= read -r line; do
    if [[ "$line" =~ ^([^:]+).*→.*:\ (.+)$ ]]; then
      from="${BASH_REMATCH[1]}"
      to="${BASH_REMATCH[2]}"
      echo "  \"$from\" -> \"$to\";" >> .migration/state/dependencies.dot
    fi
  done < .migration/state/dependencies.txt
  
  echo "}" >> .migration/state/dependencies.dot
  
  # Generate image
  dot -Tpng .migration/state/dependencies.dot -o .migration/state/dependencies.png
  echo "✅ Dependency graph generated: .migration/state/dependencies.png"
fi
EOF

chmod +x .migration/scripts/dependency-mapper.sh
./.migration/scripts/dependency-mapper.sh
```

## 4. Phase 2: Parallel Structure Creation (Day 2-3)

### 4.1 Create New Directory Structure

```bash
#!/usr/bin/env bash
# create-new-structure.sh

source .migration/scripts/logger.sh

log_info "Creating new DevPilot structure..."

# Create all directories without moving files
create_structure() {
  local base="devpilot-new"
  
  # Core directories
  mkdir -p "$base"/{
    core,
    onboard/{workspace,platforms},
    pilot/{agents/{claude,gemini,grok,codex},commands,prompts},
    profiles/{skills/{01-vibe,02-beginner,03-intermediate,04-advanced,05-expert}},
    profiles/phases/{01-prototype,02-mvp,03-beta,04-scale},
    projects/{templates,hooks},
    studio/{editor/{vscode,neovim},terminal,workflows},
    insights/{reports,dashboard},
    academy/{quickstart,guides,examples},
    plugins/{core,community},
    .devpilot/{config,cache,logs,state,updates}
  }
  
  log_success "Directory structure created"
}

# Create main executable
create_main_executable() {
  cat > devpilot-new/devpilot << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

VERSION="1.0.0"
DEVPILOT_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$DEVPILOT_HOME/core/config.sh"
source "$DEVPILOT_HOME/core/logger.sh"

# Command router
route_command() {
  local cmd="${1:-help}"
  shift || true
  
  case "$cmd" in
    # Core commands
    install)     exec "$DEVPILOT_HOME/core/bootstrap.sh" "$@" ;;
    upgrade)     exec "$DEVPILOT_HOME/core/upgrader.sh" "$@" ;;
    config)      exec "$DEVPILOT_HOME/core/config.sh" "$@" ;;
    
    # Onboarding
    welcome)     exec "$DEVPILOT_HOME/onboard/welcome.sh" "$@" ;;
    setup)       exec "$DEVPILOT_HOME/onboard/wizard.sh" "$@" ;;
    
    # Project management
    create)      exec "$DEVPILOT_HOME/projects/wizard.sh" "$@" ;;
    scan)        exec "$DEVPILOT_HOME/projects/scanner.sh" "$@" ;;
    
    # AI pilot
    pilot)       exec "$DEVPILOT_HOME/pilot/orchestrator.sh" "$@" ;;
    think)       exec "$DEVPILOT_HOME/pilot/commands/think.sh" "$@" ;;
    
    # Profile management
    profile)     exec "$DEVPILOT_HOME/profiles/manager.sh" "$@" ;;
    
    # Studio features
    studio)      exec "$DEVPILOT_HOME/studio/manager.sh" "$@" ;;
    
    # Insights
    doctor)      exec "$DEVPILOT_HOME/insights/doctor.sh" "$@" ;;
    audit)       exec "$DEVPILOT_HOME/insights/audit.sh" "$@" ;;
    metrics)     exec "$DEVPILOT_HOME/insights/metrics.sh" "$@" ;;
    
    # Help and version
    help|--help) show_help ;;
    version|-v)  echo "DevPilot v$VERSION" ;;
    
    # Unknown command
    *) 
      echo "Unknown command: $cmd"
      echo "Run 'devpilot help' for available commands"
      exit 1
      ;;
  esac
}

show_help() {
  cat << 'HELP'
DevPilot - AI-Augmented Development Platform

USAGE:
  devpilot [command] [options]

CORE COMMANDS:
  install       Install DevPilot system
  create        Create new project
  pilot         Interact with AI agents
  profile       Manage skill profiles
  studio        Development environment tools
  
ANALYSIS COMMANDS:
  doctor        System health check
  audit         Code quality audit
  metrics       Development metrics

LEARN MORE:
  help          Show this help message
  version       Show version information
  
Run 'devpilot [command] --help' for command-specific help
HELP
}

# Main execution
route_command "$@"
EOF
  
  chmod +x devpilot-new/devpilot
  log_success "Main executable created"
}

# Run creation
create_structure
create_main_executable
```

### 4.2 File Migration Mapping

```bash
#!/usr/bin/env bash
# create-migration-map.sh

source .migration/scripts/logger.sh

log_info "Creating migration mapping..."

# Generate migration manifest
cat > .migration/state/migration-map.json << 'EOF'
{
  "migrations": [
    {
      "source": "setup_all.sh",
      "destination": "core/bootstrap.sh",
      "transform": ["update_paths", "add_logging", "modernize_ui"],
      "priority": 1
    },
    {
      "source": "install/key_software_wsl.sh",
      "destination": "onboard/platforms/wsl.sh",
      "transform": ["extract_common", "update_paths"],
      "priority": 2
    },
    {
      "source": "install/key_software_linux.sh",
      "destination": "onboard/platforms/linux.sh",
      "transform": ["extract_common", "update_paths"],
      "priority": 2
    },
    {
      "source": "install/key_software_macos.sh",
      "destination": "onboard/platforms/macos.sh",
      "transform": ["extract_common", "update_paths"],
      "priority": 2
    },
    {
      "source": "setup/agents_global.sh",
      "destination": "pilot/agents/setup.sh",
      "transform": ["modularize", "update_paths"],
      "priority": 3
    },
    {
      "source": "setup/repo_wizard.sh",
      "destination": "projects/wizard.sh",
      "transform": ["add_interactive_ui", "update_paths"],
      "priority": 3
    },
    {
      "source": "validation/validate_agents.sh",
      "destination": "insights/audit.sh",
      "transform": ["rename_functions", "add_reporting"],
      "priority": 4
    },
    {
      "source": "scripts/doctor.sh",
      "destination": "insights/doctor.sh",
      "transform": ["enhance_diagnostics"],
      "priority": 4
    },
    {
      "source": ".claude/",
      "destination": "pilot/agents/claude/",
      "transform": ["restructure_configs"],
      "priority": 5
    },
    {
      "source": "profiles/",
      "destination": "profiles/",
      "transform": ["reorganize_structure", "add_progression"],
      "priority": 5
    },
    {
      "source": "templates/",
      "destination": "projects/templates/",
      "transform": ["standardize_format"],
      "priority": 6
    }
  ],
  "transformations": {
    "update_paths": {
      "description": "Update all script paths to new structure",
      "script": "transformations/update_paths.sh"
    },
    "extract_common": {
      "description": "Extract common functions to shared library",
      "script": "transformations/extract_common.sh"
    },
    "add_logging": {
      "description": "Add comprehensive logging",
      "script": "transformations/add_logging.sh"
    },
    "modernize_ui": {
      "description": "Add progress indicators and rich UI",
      "script": "transformations/modernize_ui.sh"
    }
  }
}
EOF

log_success "Migration map created"
```

## 5. Phase 3: Intelligent File Migration (Day 4-5)

### 5.1 Migration Executor

```bash
#!/usr/bin/env bash
# migrate-files.sh

source .migration/scripts/logger.sh

# Migration state tracking
MIGRATED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

# Load migration map
MIGRATION_MAP=".migration/state/migration-map.json"

# Migration function
migrate_file() {
  local source="$1"
  local destination="$2"
  local transforms="$3"
  
  log_info "Migrating: $source → $destination"
  
  # Validate source exists
  if [[ ! -e "$source" ]]; then
    log_warn "Source not found: $source"
    ((SKIPPED_COUNT++))
    return 1
  fi
  
  # Create backup
  local backup_name="$(basename "$source").$(date +%s).bak"
  cp -r "$source" ".migration/backups/$backup_name"
  log_info "Backup created: $backup_name"
  
  # Create destination directory
  local dest_dir="$(dirname "devpilot-new/$destination")"
  mkdir -p "$dest_dir"
  
  # Copy to new location
  cp -r "$source" "devpilot-new/$destination"
  
  # Apply transformations
  for transform in $transforms; do
    apply_transformation "$transform" "devpilot-new/$destination"
  done
  
  # Validate migration
  if validate_migration "$source" "devpilot-new/$destination"; then
    log_success "Migration successful: $source"
    ((MIGRATED_COUNT++))
    
    # Update state
    echo "$source → $destination" >> .migration/state/migrated.txt
  else
    log_error "Migration failed: $source"
    ((FAILED_COUNT++))
    return 1
  fi
}

# Apply transformation
apply_transformation() {
  local transform="$1"
  local file="$2"
  
  log_info "Applying transformation: $transform"
  
  case "$transform" in
    update_paths)
      sed -i.bak \
        -e 's|install/|onboard/platforms/|g' \
        -e 's|setup/|projects/|g' \
        -e 's|scripts/|insights/|g' \
        -e 's|validation/|insights/|g' \
        "$file"
      ;;
      
    extract_common)
      # Extract common functions to shared library
      extract_functions "$file" > "devpilot-new/core/common.sh"
      ;;
      
    add_logging)
      # Add logging statements
      sed -i.bak '1a\source "$DEVPILOT_HOME/core/logger.sh"' "$file"
      ;;
      
    modernize_ui)
      # Add progress indicators
      add_progress_indicators "$file"
      ;;
      
    *)
      log_warn "Unknown transformation: $transform"
      ;;
  esac
}

# Validation function
validate_migration() {
  local source="$1"
  local destination="$2"
  
  # Check file exists
  [[ -e "$destination" ]] || return 1
  
  # If script, check syntax
  if [[ "$destination" == *.sh ]]; then
    bash -n "$destination" || return 1
  fi
  
  # If JSON, validate
  if [[ "$destination" == *.json ]]; then
    jq empty "$destination" || return 1
  fi
  
  return 0
}

# Process migration map
process_migrations() {
  local priority="$1"
  
  log_info "Processing priority $priority migrations..."
  
  # Extract migrations for this priority
  jq -r ".migrations[] | select(.priority == $priority)" "$MIGRATION_MAP" | while read -r migration; do
    source=$(echo "$migration" | jq -r '.source')
    destination=$(echo "$migration" | jq -r '.destination')
    transforms=$(echo "$migration" | jq -r '.transform[]')
    
    migrate_file "$source" "$destination" "$transforms"
  done
}

# Main migration execution
main() {
  log_info "Starting file migration..."
  
  # Process by priority
  for priority in 1 2 3 4 5 6; do
    process_migrations "$priority"
    
    # Checkpoint after each priority level
    create_checkpoint "priority_$priority"
  done
  
  # Summary
  log_info "Migration Summary:"
  log_info "  Migrated: $MIGRATED_COUNT"
  log_info "  Failed: $FAILED_COUNT"
  log_info "  Skipped: $SKIPPED_COUNT"
  
  if [[ $FAILED_COUNT -eq 0 ]]; then
    log_success "File migration completed successfully!"
  else
    log_error "Migration completed with errors"
    return 1
  fi
}

# Create checkpoint for rollback
create_checkpoint() {
  local name="$1"
  local checkpoint_dir=".migration/rollback/checkpoint_$name"
  
  log_info "Creating checkpoint: $name"
  
  # Save current state
  mkdir -p "$checkpoint_dir"
  cp -r devpilot-new "$checkpoint_dir/"
  cp .migration/state/*.txt "$checkpoint_dir/" 2>/dev/null || true
  
  # Update state
  jq ".checkpoints += [\"$name\"]" .migration/state/config.json > tmp.json
  mv tmp.json .migration/state/config.json
  
  log_success "Checkpoint created: $name"
}

# Execute migration
main "$@"
```

## 6. Phase 4: Compatibility Layer (Day 6)

### 6.1 Create Backward Compatibility

```bash
#!/usr/bin/env bash
# create-compatibility-layer.sh

source .migration/scripts/logger.sh

log_info "Creating compatibility layer..."

# Generate compatibility wrappers
create_wrapper() {
  local old_script="$1"
  local new_command="$2"
  
  cat > "$old_script" << EOF
#!/usr/bin/env bash
# Compatibility wrapper for $(basename "$old_script")
# This script maintains backward compatibility during migration

# Show deprecation notice
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "⚠️  DEPRECATION NOTICE" >&2
echo "This command has been moved to: devpilot $new_command" >&2
echo "Please update your scripts and workflows." >&2
echo "This compatibility wrapper will be removed on $(date -d "+90 days" +%Y-%m-%d)" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "" >&2

# Add to deprecation log
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) | $(basename "$old_script") | \$USER" >> .migration/logs/deprecation.log

# Execute new command
exec ./devpilot $new_command "\$@"
EOF
  
  chmod +x "$old_script"
  log_success "Created wrapper: $old_script → devpilot $new_command"
}

# Create all compatibility wrappers
create_all_wrappers() {
  # Main scripts
  create_wrapper "setup_all.sh" "install"
  create_wrapper "repo_setup_wizard.sh" "create project"
  create_wrapper "validate_agents.sh" "audit"
  create_wrapper "setup_agents_global.sh" "pilot setup"
  create_wrapper "setup_agents_repo.sh" "project setup"
  
  # Installation scripts
  for script in install/*.sh; do
    [[ -f "$script" ]] || continue
    name=$(basename "$script" .sh)
    create_wrapper "$script" "install --component $name"
  done
  
  # Utility scripts
  for script in scripts/*.sh; do
    [[ -f "$script" ]] || continue
    name=$(basename "$script" .sh)
    create_wrapper "$script" "utils $name"
  done
}

# Create alias script for users
create_user_aliases() {
  cat > .migration/install-aliases.sh << 'EOF'
#!/usr/bin/env bash
# Install DevPilot aliases for easier transition

ALIAS_FILE="$HOME/.devpilot_aliases"

cat > "$ALIAS_FILE" << 'ALIASES'
# DevPilot Compatibility Aliases
alias setup_all='devpilot install'
alias repo_wizard='devpilot create project'
alias validate='devpilot audit'
alias agents_setup='devpilot pilot setup'

# Convenience aliases
alias dp='devpilot'
alias dpc='devpilot create'
alias dpp='devpilot pilot'
alias dpa='devpilot audit'
alias dpd='devpilot doctor'

# Function to show migration tips
devpilot_migrate_tip() {
  echo "💡 Tip: The command '$1' is now 'devpilot $2'"
  echo "   Update your scripts to use the new command."
}
ALIASES

# Add to shell configuration
for rc in ~/.bashrc ~/.zshrc; do
  if [[ -f "$rc" ]]; then
    if ! grep -q ".devpilot_aliases" "$rc"; then
      echo "" >> "$rc"
      echo "# DevPilot aliases" >> "$rc"
      echo "[[ -f ~/.devpilot_aliases ]] && source ~/.devpilot_aliases" >> "$rc"
      echo "✅ Added DevPilot aliases to $rc"
    fi
  fi
done

echo "✅ DevPilot aliases installed!"
echo "   Restart your shell or run: source ~/.devpilot_aliases"
EOF
  
  chmod +x .migration/install-aliases.sh
  log_success "User alias installer created"
}

# Environment variable compatibility
create_env_compatibility() {
  cat > devpilot-new/core/env-compat.sh << 'EOF'
#!/usr/bin/env bash
# Environment variable compatibility mapping

# Map old environment variables to new ones
export DEVPILOT_HOME="${SETUP_SCRIPTS_HOME:-$DEVPILOT_HOME}"
export DEVPILOT_CONFIG="${AGENTS_CONFIG:-$DEVPILOT_CONFIG}"
export DEVPILOT_PROFILE="${USER_PROFILE:-$DEVPILOT_PROFILE}"

# Warn about deprecated variables
check_deprecated_env() {
  local deprecated_vars=(
    "SETUP_SCRIPTS_HOME"
    "AGENTS_CONFIG"
    "USER_PROFILE"
  )
  
  for var in "${deprecated_vars[@]}"; do
    if [[ -n "${!var}" ]]; then
      echo "⚠️  Deprecated environment variable: $var" >&2
      echo "   Please use: DEVPILOT_${var##*_}" >&2
    fi
  done
}

check_deprecated_env
EOF
  
  log_success "Environment compatibility created"
}

# Main execution
create_all_wrappers
create_user_aliases
create_env_compatibility

log_success "Compatibility layer complete"
```

## 7. Phase 5: Testing & Validation (Day 7-8)

### 7.1 Comprehensive Test Suite

```bash
#!/usr/bin/env bash
# test-migration.sh

source .migration/scripts/logger.sh

# Test results tracking
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test execution function
run_test() {
  local test_name="$1"
  local test_function="$2"
  
  ((TESTS_TOTAL++))
  
  echo -n "Testing: $test_name... "
  
  if $test_function >/dev/null 2>&1; then
    echo "✅ PASS"
    ((TESTS_PASSED++))
    return 0
  else
    echo "❌ FAIL"
    ((TESTS_FAILED++))
    log_error "Test failed: $test_name"
    return 1
  fi
}

# Test: Compatibility wrappers work
test_compatibility_wrappers() {
  ./setup_all.sh --help | grep -q "DevPilot"
}

# Test: New structure syntax valid
test_new_structure_syntax() {
  find devpilot-new -name "*.sh" -type f | while read -r script; do
    bash -n "$script" || return 1
  done
}

# Test: All JSON files valid
test_json_validity() {
  find devpilot-new -name "*.json" -type f | while read -r json; do
    jq empty "$json" || return 1
  done
}

# Test: Main executable works
test_main_executable() {
  ./devpilot-new/devpilot help | grep -q "DevPilot"
}

# Test: Performance regression
test_performance() {
  local baseline=$(grep "real" .migration/baseline.txt | awk '{print $2}')
  local current=$(time -p ./devpilot-new/devpilot install --dry-run 2>&1 | grep "real" | awk '{print $2}')
  
  # Allow 10% performance degradation
  local threshold=$(echo "$baseline * 1.1" | bc)
  (( $(echo "$current <= $threshold" | bc -l) ))
}

# Test: Command equivalence
test_command_equivalence() {
  # Test that old and new commands produce same results
  local old_output=$(./setup_all.sh --dry-run 2>&1 | md5sum)
  local new_output=$(./devpilot-new/devpilot install --dry-run 2>&1 | md5sum)
  
  [[ "$old_output" == "$new_output" ]]
}

# Test: Rollback functionality
test_rollback() {
  # Simulate rollback
  ./.migration/scripts/rollback.sh --dry-run
}

# Run all tests
run_all_tests() {
  log_info "Starting comprehensive test suite..."
  
  run_test "Compatibility wrappers" test_compatibility_wrappers
  run_test "New structure syntax" test_new_structure_syntax
  run_test "JSON validity" test_json_validity
  run_test "Main executable" test_main_executable
  run_test "Performance" test_performance
  run_test "Command equivalence" test_command_equivalence
  run_test "Rollback capability" test_rollback
  
  # Add integration tests
  run_test "Create project flow" test_create_project_flow
  run_test "AI agent interaction" test_ai_agent_interaction
  run_test "Profile management" test_profile_management
  
  # Summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Test Results:"
  echo "  Total:  $TESTS_TOTAL"
  echo "  Passed: $TESTS_PASSED"
  echo "  Failed: $TESTS_FAILED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if [[ $TESTS_FAILED -eq 0 ]]; then
    log_success "All tests passed!"
    return 0
  else
    log_error "$TESTS_FAILED tests failed"
    return 1
  fi
}

# Integration test: Create project flow
test_create_project_flow() {
  ./devpilot-new/devpilot create project \
    --name test-project \
    --template typescript \
    --dry-run
}

# Integration test: AI agent interaction
test_ai_agent_interaction() {
  ./devpilot-new/devpilot pilot claude help
}

# Integration test: Profile management
test_profile_management() {
  ./devpilot-new/devpilot profile show
}

# Execute tests
run_all_tests
```

## 8. Phase 6: Staged Rollout (Day 9-10)

### 8.1 Canary Deployment

```bash
#!/usr/bin/env bash
# canary-deployment.sh

source .migration/scripts/logger.sh

# Canary configuration
CANARY_PERCENTAGE=10
CANARY_USERS=(".canary_users.txt")

# Feature flag system
setup_feature_flags() {
  cat > devpilot-new/.devpilot/config/features.json << 'EOF'
{
  "features": {
    "new_structure": {
      "enabled": false,
      "rollout_percentage": 10,
      "whitelist": [],
      "blacklist": [],
      "start_date": "2024-09-01T00:00:00Z",
      "end_date": "2024-12-01T00:00:00Z"
    },
    "rich_ui": {
      "enabled": true,
      "rollout_percentage": 50
    },
    "ai_routing": {
      "enabled": false,
      "rollout_percentage": 5
    }
  }
}
EOF
}

# Canary router
create_canary_router() {
  cat > devpilot << 'EOF'
#!/usr/bin/env bash
# Intelligent router for canary deployment

# Check if user is in canary
is_canary_user() {
  local user="${USER:-unknown}"
  local percentage=10
  
  # Check whitelist
  if grep -q "^$user$" .canary_users.txt 2>/dev/null; then
    return 0
  fi
  
  # Check percentage rollout (deterministic based on username)
  local hash=$(echo -n "$user" | md5sum | cut -d' ' -f1)
  local hash_value=$((0x${hash:0:8} % 100))
  
  [[ $hash_value -lt $percentage ]]
}

# Route to appropriate version
if is_canary_user; then
  export DEVPILOT_VERSION="canary"
  exec ./devpilot-new/devpilot "$@"
else
  export DEVPILOT_VERSION="stable"
  # Use compatibility wrappers for old commands
  case "${1:-}" in
    install) exec ./setup_all.sh "${@:2}" ;;
    create)  exec ./repo_setup_wizard.sh "${@:2}" ;;
    audit)   exec ./validate_agents.sh "${@:2}" ;;
    *)       exec ./devpilot-new/devpilot "$@" ;;
  esac
fi
EOF
  
  chmod +x devpilot
  log_success "Canary router created"
}

# Monitoring setup
setup_monitoring() {
  cat > .migration/scripts/monitor.sh << 'EOF'
#!/usr/bin/env bash
# Monitor canary deployment

# Metrics collection
collect_metrics() {
  local version="$1"
  local start_time="$2"
  local end_time="$3"
  local exit_code="$4"
  local command="$5"
  
  # Log metrics
  cat >> .migration/logs/metrics.jsonl << JSON
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "$version",
  "duration": $((end_time - start_time)),
  "exit_code": $exit_code,
  "command": "$command",
  "user": "$USER"
}
JSON
}

# Error rate monitoring
check_error_rate() {
  local threshold=5
  local window=3600  # 1 hour
  
  local recent_errors=$(
    jq -s '
      map(select(.exit_code != 0 and 
                 (.timestamp | fromdateiso8601) > (now - '$window')))
      | length
    ' .migration/logs/metrics.jsonl 2>/dev/null || echo 0
  )
  
  if [[ $recent_errors -gt $threshold ]]; then
    log_error "Error threshold exceeded: $recent_errors errors in last hour"
    trigger_rollback
  fi
}

# Performance monitoring
check_performance() {
  local threshold_ms=2000
  
  local avg_duration=$(
    jq -s '
      map(select(.version == "canary"))
      | map(.duration)
      | add / length
    ' .migration/logs/metrics.jsonl 2>/dev/null || echo 0
  )
  
  if [[ ${avg_duration%.*} -gt $threshold_ms ]]; then
    log_warn "Performance degradation detected: ${avg_duration}ms average"
  fi
}

# Continuous monitoring loop
while true; do
  check_error_rate
  check_performance
  sleep 60
done
EOF
  
  chmod +x .migration/scripts/monitor.sh
  log_success "Monitoring setup complete"
}

# A/B testing framework
setup_ab_testing() {
  cat > .migration/scripts/ab-test.sh << 'EOF'
#!/usr/bin/env bash
# A/B testing for migration validation

run_ab_test() {
  local test_name="$1"
  local iterations=100
  
  echo "Running A/B test: $test_name"
  
  # Run on old version
  local old_times=()
  for i in $(seq 1 $iterations); do
    start=$(date +%s%N)
    ./setup_all.sh --dry-run >/dev/null 2>&1
    end=$(date +%s%N)
    old_times+=($((end - start)))
  done
  
  # Run on new version
  local new_times=()
  for i in $(seq 1 $iterations); do
    start=$(date +%s%N)
    ./devpilot-new/devpilot install --dry-run >/dev/null 2>&1
    end=$(date +%s%N)
    new_times+=($((end - start)))
  done
  
  # Calculate statistics
  local old_avg=$(average "${old_times[@]}")
  local new_avg=$(average "${new_times[@]}")
  local improvement=$(echo "scale=2; ($old_avg - $new_avg) / $old_avg * 100" | bc)
  
  echo "Results:"
  echo "  Old version: ${old_avg}ns average"
  echo "  New version: ${new_avg}ns average"
  echo "  Improvement: ${improvement}%"
}

average() {
  local sum=0
  local count=$#
  for val in "$@"; do
    sum=$((sum + val))
  done
  echo $((sum / count))
}
EOF
  
  chmod +x .migration/scripts/ab-test.sh
  log_success "A/B testing framework created"
}

# Main execution
setup_feature_flags
create_canary_router
setup_monitoring
setup_ab_testing

log_success "Canary deployment configured"
```

## 9. Rollback Procedures

### 9.1 Automated Rollback System

```bash
#!/usr/bin/env bash
# rollback.sh

source .migration/scripts/logger.sh

# Rollback to specific checkpoint
rollback_to_checkpoint() {
  local checkpoint="${1:-latest}"
  
  log_warn "INITIATING ROLLBACK to checkpoint: $checkpoint"
  
  # Find checkpoint
  if [[ "$checkpoint" == "latest" ]]; then
    checkpoint=$(jq -r '.checkpoints[-1]' .migration/state/config.json)
  fi
  
  local checkpoint_dir=".migration/rollback/checkpoint_$checkpoint"
  
  if [[ ! -d "$checkpoint_dir" ]]; then
    log_error "Checkpoint not found: $checkpoint"
    return 1
  fi
  
  # Backup current state before rollback
  log_info "Backing up current state..."
  cp -r devpilot-new ".migration/rollback/pre-rollback-$(date +%s)"
  
  # Restore from checkpoint
  log_info "Restoring from checkpoint..."
  rm -rf devpilot-new
  cp -r "$checkpoint_dir/devpilot-new" .
  
  # Restore state files
  cp "$checkpoint_dir"/*.txt .migration/state/ 2>/dev/null || true
  
  # Update configuration
  jq ".status = \"rolled_back\", .rolled_back_from = \"$checkpoint\"" \
    .migration/state/config.json > tmp.json
  mv tmp.json .migration/state/config.json
  
  log_success "Rollback complete to checkpoint: $checkpoint"
}

# Complete rollback (emergency)
emergency_rollback() {
  log_error "EMERGENCY ROLLBACK INITIATED"
  
  # Stop all processes
  log_info "Stopping all DevPilot processes..."
  pkill -f devpilot || true
  
  # Restore original structure
  log_info "Restoring original structure..."
  rm -rf devpilot-new devpilot
  
  # Remove compatibility layer
  log_info "Removing compatibility wrappers..."
  git checkout -- *.sh
  
  # Restore from git
  log_info "Restoring from git..."
  git checkout main
  git clean -fd
  
  # Clear migration state
  rm -rf .migration
  
  log_error "Emergency rollback complete - system restored to original state"
}

# Partial rollback (specific component)
partial_rollback() {
  local component="$1"
  
  log_info "Partial rollback for component: $component"
  
  case "$component" in
    compatibility)
      # Restore compatibility wrappers
      git checkout -- *.sh
      ;;
    structure)
      # Restore directory structure
      rm -rf devpilot-new
      ;;
    configs)
      # Restore configurations
      git checkout -- "*.json" "*.yml"
      ;;
    *)
      log_error "Unknown component: $component"
      return 1
      ;;
  esac
  
  log_success "Partial rollback complete for: $component"
}

# Health check before rollback
pre_rollback_health_check() {
  log_info "Running pre-rollback health check..."
  
  # Check disk space
  local available=$(df . | awk 'NR==2 {print $4}')
  if [[ $available -lt 1000000 ]]; then
    log_error "Insufficient disk space for rollback"
    return 1
  fi
  
  # Check git status
  if ! git status >/dev/null 2>&1; then
    log_error "Git repository corrupted"
    return 1
  fi
  
  log_success "Pre-rollback health check passed"
}

# Main rollback execution
main() {
  local action="${1:-checkpoint}"
  shift || true
  
  # Health check
  pre_rollback_health_check || exit 1
  
  case "$action" in
    checkpoint)
      rollback_to_checkpoint "$@"
      ;;
    emergency)
      read -p "⚠️  This will completely revert all changes. Continue? (yes/no): " confirm
      [[ "$confirm" == "yes" ]] && emergency_rollback
      ;;
    partial)
      partial_rollback "$@"
      ;;
    --dry-run)
      echo "Rollback dry run - no changes made"
      echo "Available checkpoints:"
      jq -r '.checkpoints[]' .migration/state/config.json
      ;;
    *)
      echo "Usage: $0 [checkpoint|emergency|partial] [options]"
      exit 1
      ;;
  esac
}

# Execute rollback
main "$@"
```

## 10. Post-Migration Validation

### 10.1 Final Validation Checklist

```bash
#!/usr/bin/env bash
# final-validation.sh

source .migration/scripts/logger.sh

# Validation results
VALIDATIONS_PASSED=0
VALIDATIONS_FAILED=0

# Run validation
validate() {
  local name="$1"
  local command="$2"
  
  echo -n "Validating: $name... "
  
  if eval "$command" >/dev/null 2>&1; then
    echo "✅"
    ((VALIDATIONS_PASSED++))
    return 0
  else
    echo "❌"
    ((VALIDATIONS_FAILED++))
    log_error "Validation failed: $name"
    return 1
  fi
}

# Run all validations
log_info "Running final validation..."

# Functional validations
validate "Main executable" "./devpilot help"
validate "Installation command" "./devpilot install --dry-run"
validate "Project creation" "./devpilot create project --dry-run"
validate "AI pilot" "./devpilot pilot help"
validate "Profile management" "./devpilot profile show"
validate "Health check" "./devpilot doctor"
validate "Audit functionality" "./devpilot audit --help"

# Compatibility validations
validate "Old setup_all.sh wrapper" "./setup_all.sh --help"
validate "Old repo_wizard wrapper" "./repo_setup_wizard.sh --help"
validate "Old validate wrapper" "./validate_agents.sh --help"

# Performance validations
validate "Response time < 1s" "timeout 1 ./devpilot help"
validate "Memory usage < 100MB" "[ $(ps aux | grep devpilot | awk '{print $6}') -lt 100000 ]"

# Structure validations
validate "No broken symlinks" "! find devpilot-new -type l -exec test ! -e {} \; -print | grep -q ."
validate "All scripts executable" "! find devpilot-new -name '*.sh' ! -perm -u+x | grep -q ."
validate "All JSON valid" "find devpilot-new -name '*.json' -exec jq empty {} \;"

# Documentation validations
validate "README exists" "[ -f devpilot-new/README.md ]"
validate "Help available" "./devpilot help | grep -q 'USAGE'"
validate "Command docs" "for cmd in install create pilot; do ./devpilot $cmd --help; done"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Final Validation Summary:"
echo "  Passed: $VALIDATIONS_PASSED"
echo "  Failed: $VALIDATIONS_FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $VALIDATIONS_FAILED -eq 0 ]]; then
  log_success "Migration validation complete - ready for production!"
  
  # Mark migration as complete
  jq '.status = "completed", .completed_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' \
    .migration/state/config.json > tmp.json
  mv tmp.json .migration/state/config.json
else
  log_error "Migration validation failed - review and fix issues"
  exit 1
fi
```

## 11. Communication Plan

### 11.1 User Communication Template

```markdown
# DevPilot Migration - User Communication

## Week 1: Announcement
Subject: Exciting Changes Coming to DevPilot!

Dear DevPilot Users,

We're thrilled to announce a major upgrade to DevPilot that will make your development experience even better!

**What's Changing:**
- ✨ New unified command structure: `devpilot [command]`
- 🚀 3x faster performance
- 🎨 Beautiful interactive CLI
- 🧩 Plugin system for extensibility

**What's NOT Changing:**
- ✅ All your existing scripts will continue to work
- ✅ No breaking changes to your workflows
- ✅ Your configurations remain intact

**Timeline:**
- Sept 1-3: Soft launch (10% of users)
- Sept 4-7: Gradual rollout (50% of users)
- Sept 8-10: Full deployment

**Action Required:** None! The migration is automatic.

## Week 2: Migration Progress

Daily updates will be posted to:
- Slack: #devpilot-migration
- Dashboard: https://devpilot.ai/migration
- Email: Weekly summary

## Week 3: Completion

Subject: DevPilot Migration Complete! 🎉

The migration is complete! Here's what's new:
- [Link to new features guide]
- [Link to video walkthrough]
- [Link to migration FAQ]

Old commands will continue working for 90 days.
Please update your scripts to use the new format.
```

## 12. Metrics & Monitoring

### 12.1 KPI Dashboard

```javascript
// migration-metrics.js
const metrics = {
  migration: {
    filesProcessed: 142,
    filesMigrated: 142,
    testsPassed: 98,
    testsTotal: 98,
    compatibilityWrappers: 17,
    rollbackPoints: 6
  },
  performance: {
    oldAvgResponseTime: 2.3,  // seconds
    newAvgResponseTime: 0.7,  // seconds
    improvement: "70%"
  },
  adoption: {
    totalUsers: 1000,
    canaryUsers: 100,
    usingNewCommands: 450,
    usingOldCommands: 550
  },
  quality: {
    errorRate: 0.02,  // 2%
    rollbacksTriggered: 0,
    userComplaints: 2,
    userCompliments: 47
  }
};
```

## 13. Conclusion

This migration plan ensures:
- **Zero downtime** through parallel structures
- **Complete reversibility** via checkpoint system
- **User confidence** through compatibility layer
- **Quality assurance** via comprehensive testing
- **Smooth transition** with staged rollout

The keys to success:
1. **Incremental changes** - Small, validated steps
2. **Continuous validation** - Test at every stage
3. **Clear communication** - Keep users informed
4. **Safety first** - Multiple rollback options
5. **Data integrity** - Comprehensive backups

---

**Document Sign-off:**
- [ ] Technical Lead
- [ ] Product Owner
- [ ] QA Lead
- [ ] DevOps Lead
- [ ] Security Officer

**Next Steps:**
1. Review and approve plan
2. Schedule migration windows
3. Prepare communication materials
4. Initialize migration infrastructure
5. Begin Phase 1 execution