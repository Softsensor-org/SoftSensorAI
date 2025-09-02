# Implementation TODO for Unified Interface

## Priority 1: Implement Missing dp Commands

Add these functions to `bin/dp`:

```bash
# Configuration commands
cmd_profile() {
  "$ROOT/scripts/apply_profile.sh" "$@"
}

cmd_persona() {
  "$ROOT/scripts/persona_manager.sh" "$@"
}

# Analysis commands
cmd_score() {
  "$ROOT/scripts/dprs.sh" "$@"
}

cmd_detect() {
  "$ROOT/scripts/detect_stack.sh" "$@"
}

cmd_plan() {
  "$ROOT/scripts/repo_plan.sh" "$@"
}

# AI commands
cmd_ai() {
  "$ROOT/tools/ai_shim.sh" "$@"
}

cmd_sandbox() {
  "$ROOT/scripts/codex_sandbox.sh" "$@"
}

# Utility commands
cmd_chain() {
  "$ROOT/scripts/chain_runner.sh" "$@"
}

cmd_patterns() {
  "$ROOT/scripts/pattern_selector.sh" "$@"
}

cmd_worktree() {
  "$ROOT/tools/worktree_helper.sh" "$@"
}

cmd_release_check() {
  "$ROOT/scripts/release_ready.sh" "$@"
}
```

## Priority 2: Add Compatibility Layer

For each deprecated script, add a wrapper:

```bash
#!/bin/bash
# scripts/apply_profile.sh
echo "⚠️  Direct script access is deprecated. Use 'dp profile' instead." >&2
exec "$(dirname "$0")/../bin/dp" profile "$@"
```

## Priority 3: Fix Command Registry

Update `generate_command_registry.sh`:

```bash
# Add flag handling
SHOW_INTERNAL="${1:-false}"

# Conditionally process directories
if [[ "$SHOW_INTERNAL" == "--all" ]] || [[ "$SHOW_INTERNAL" == "--internal" ]]; then
  process_directory "scripts" "script" "Internal Scripts"
  process_directory "tools" "tool" "Internal Tools"
fi
```

## Priority 4: Documentation Alignment

Either:

1. Create all missing documentation files, OR
2. Remove references to unimplemented commands

Recommended: Implement commands first, then docs are accurate.

## Priority 5: Version Management

Add version info to help users migrate:

```bash
cmd_version() {
  echo "DevPilot dp interface v2.0"
  echo "Legacy scripts: Deprecated but available"
  echo "Migration guide: docs/MIGRATION.md"
}
```

## Testing Checklist

- [ ] All dp commands work: `dp setup`, `dp init`, `dp doctor`, etc.
- [ ] Legacy scripts show deprecation warning but still work
- [ ] Documentation links don't 404
- [ ] `dp palette` shows appropriate commands
- [ ] JSON output includes version field
- [ ] CI/CD still passes

## Migration Communication

1. Add MIGRATION.md explaining changes
2. Add deprecation warnings to old scripts
3. Keep old scripts working for 3-6 months
4. Announce in README changelog
5. Version tag before/after changes
