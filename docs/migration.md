# DevPilot Migration Guide

This guide helps you migrate from the legacy setup-scripts structure to the new DevPilot 2.0 architecture.

## Table of Contents
- [Overview](#overview)
- [Migration Strategy](#migration-strategy)
- [Step-by-Step Migration](#step-by-step-migration)
- [Compatibility Layer](#compatibility-layer)
- [Rollback Procedures](#rollback-procedures)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## Overview

DevPilot 2.0 introduces a modular, maintainable architecture that:
- Separates concerns into logical domains (core, pilot, projects, insights)
- Provides better error handling and logging
- Avoids WSL-specific issues (like PowerShell hanging)
- Offers backward compatibility through wrapper scripts
- Includes comprehensive migration tooling

### Key Changes

| Component | Legacy Path | New Path | Description |
|-----------|------------|----------|-------------|
| Bootstrap | `setup_all.sh` | `devpilot-new/core/bootstrap.sh` | Main orchestrator |
| Agent Setup | `setup/agents_global.sh` | `devpilot-new/pilot/agents/setup.sh` | Global agent config |
| Repo Setup | `setup/agents_repo.sh` | `devpilot-new/pilot/agents/repo.sh` | Per-repo config |
| Folders | `setup/folders.sh` | `devpilot-new/core/folders.sh` | Directory structure |
| WSL Install | `install/key_software_wsl.sh` | `devpilot-new/onboard/platforms/wsl.sh` | WSL tools |
| Validation | `validation/validate_agents.sh` | `devpilot-new/insights/audit.sh` | Agent validation |

## Migration Strategy

The migration follows a safe, incremental approach:

1. **Non-destructive**: Original files remain untouched
2. **Parallel installation**: New structure coexists with legacy
3. **Compatibility wrappers**: Old commands continue working
4. **Rollback capability**: Checkpoint-based recovery
5. **Canary deployment**: Test with subset before full migration

## Step-by-Step Migration

### Prerequisites

```bash
# Ensure you're in the repository root
cd ~/repos/setup-scripts

# Check current state
git status
git diff

# Create a backup branch
git checkout -b pre-migration-backup
git add .
git commit -m "Backup before DevPilot 2.0 migration"
git checkout main
```

### Phase 1: Initial Setup

```bash
# 1. Verify migration framework exists
ls -la .migration/

# 2. Check migration state
cat .migration/state/config.json

# 3. Review migration map
jq . .migration/state/migration-map.json
```

### Phase 2: Execute Migration

```bash
# 1. Run the migration executor
.migration/scripts/migrate-files.sh

# This will:
# - Copy files to new structure
# - Apply transformations
# - Create checkpoint
# - Log all actions

# 2. Verify migration results
.migration/scripts/test-migration.sh

# Expected output:
# ✅ PASS - New structure scripts parse
# ✅ PASS - DevPilot help shows
# ✅ PASS - JSON files valid
```

### Phase 3: Create Compatibility Layer

```bash
# 1. Preview wrapper generation (non-destructive)
.migration/scripts/compat-layer.sh

# Review generated wrappers
ls -la .migration/wrappers/

# 2. Test a wrapper
.migration/wrappers/setup_all.sh --help

# 3. Apply wrappers in-place (when ready)
.migration/scripts/compat-layer.sh --in-place

# This creates wrapper scripts at original locations
# that redirect to new implementations
```

### Phase 4: Test New System

```bash
# 1. Test bootstrap with dry-run
./devpilot-new/devpilot bootstrap --dry-run

# 2. Test agent setup
./devpilot-new/devpilot pilot setup --dry-run

# 3. Test folder creation
./devpilot-new/devpilot core folders --dry-run

# 4. Run full audit
./devpilot-new/devpilot insights audit
```

### Phase 5: Canary Deployment

```bash
# 1. Enable canary mode
.migration/scripts/canary.sh

# This creates:
# - devpilot-canary symlink
# - Canary flag file
# - Limited rollout

# 2. Test with canary
./devpilot-canary bootstrap --dry-run

# 3. Monitor canary
.migration/scripts/monitor.sh

# 4. Promote canary to production (when satisfied)
.migration/scripts/canary.sh --promote
```

### Phase 6: Full Migration

```bash
# 1. Run actual bootstrap
./devpilot-new/devpilot bootstrap --upgrade

# 2. Update shell configuration
echo 'export PATH="$HOME/repos/setup-scripts/devpilot-new:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 3. Verify installation
devpilot --version
devpilot help
```

## Compatibility Layer

The compatibility layer ensures existing scripts and workflows continue functioning:

### How It Works

1. **Wrapper Scripts**: Thin scripts at original locations that call new implementations
2. **Parameter Translation**: Maps old arguments to new format
3. **Output Compatibility**: Maintains expected output format
4. **Exit Codes**: Preserves original exit code behavior

### Example Wrapper

```bash
#!/usr/bin/env bash
# Compatibility wrapper for setup_all.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEW_SCRIPT="$SCRIPT_DIR/devpilot-new/core/bootstrap.sh"

# Translate old parameters to new format
# ... parameter mapping logic ...

# Execute new implementation
exec "$NEW_SCRIPT" "$@"
```

### Maintaining Compatibility

```bash
# Check wrapper status
.migration/scripts/compat-layer.sh --status

# Update wrappers after changes
.migration/scripts/compat-layer.sh --update

# Remove wrappers (when ready to fully migrate)
.migration/scripts/compat-layer.sh --remove
```

## Rollback Procedures

### Checkpoint Rollback

```bash
# List available checkpoints
ls -la .migration/checkpoints/

# Rollback to specific checkpoint
.migration/scripts/rollback.sh checkpoint_20240831_160000.tar.gz

# Rollback to latest checkpoint
.migration/scripts/rollback.sh latest
```

### Emergency Rollback

```bash
# Complete rollback to pre-migration state
.migration/scripts/rollback.sh --emergency

# This will:
# 1. Remove all new directories
# 2. Restore original files
# 3. Clear migration state
# 4. Remove wrappers
```

### Git-based Rollback

```bash
# If all else fails, use git
git status
git clean -fd
git checkout -- .
```

## Troubleshooting

### Common Issues

#### Migration Script Fails

```bash
# Check logs
tail -f .migration/logs/migration-*.log

# Verify permissions
chmod +x .migration/scripts/*.sh

# Run with debug mode
DEBUG=1 .migration/scripts/migrate-files.sh
```

#### Wrapper Not Working

```bash
# Check wrapper exists
ls -la setup_all.sh

# Verify it's a wrapper
head -5 setup_all.sh | grep "Compatibility wrapper"

# Test wrapper directly
bash -x setup_all.sh --help
```

#### New Scripts Not Found

```bash
# Check PATH
echo $PATH | grep devpilot-new

# Add to PATH if missing
export PATH="$HOME/repos/setup-scripts/devpilot-new:$PATH"

# Make permanent
echo 'export PATH="$HOME/repos/setup-scripts/devpilot-new:$PATH"' >> ~/.bashrc
```

#### WSL PowerShell Hanging

The new system avoids PowerShell entirely. If you encounter hanging:

```bash
# Find stuck PowerShell process
ps aux | grep powershell

# Kill it
kill -9 <PID>

# Use new bootstrap instead
./devpilot-new/devpilot bootstrap
```

## FAQ

### Q: Will my existing configurations be preserved?
A: Yes, the migration backs up all existing configurations and the new system reads from the same locations.

### Q: Can I run both old and new systems simultaneously?
A: Yes, they can coexist. The compatibility layer ensures smooth transition.

### Q: How do I know if migration was successful?
A: Run `.migration/scripts/test-migration.sh` - all tests should pass.

### Q: What if I need to add custom scripts?
A: Place them in the appropriate new directory and update the migration map if needed.

### Q: How do I migrate custom modifications?
A: 
1. Identify your customizations
2. Apply them to the new structure
3. Test thoroughly
4. Update wrappers if needed

### Q: When can I remove the old structure?
A: After:
1. All workflows are tested with new structure
2. Team members are notified
3. CI/CD pipelines are updated
4. A full backup is created

## Migration Checklist

- [ ] Backup current setup
- [ ] Review migration map
- [ ] Run migration executor
- [ ] Test migration
- [ ] Create compatibility wrappers
- [ ] Test with dry-run
- [ ] Deploy canary
- [ ] Monitor for issues
- [ ] Full migration
- [ ] Update documentation
- [ ] Notify team
- [ ] Schedule old structure removal

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs in `.migration/logs/`
3. Open an issue with:
   - Migration state (`cat .migration/state/config.json`)
   - Error logs
   - System information (`uname -a`, `bash --version`)

## Next Steps

After successful migration:

1. Explore new features in [DevPilot 2.0 Features](../README.md#key-features)
2. Configure skill profiles: [Profiles Guide](profiles.md)
3. Setup AI agents: [Agent Guide](agents.md)
4. Learn the new CLI: [CLI Reference](cli-reference.md)

---

*Migration guide for DevPilot 2.0 - The Learning-Aware Update*