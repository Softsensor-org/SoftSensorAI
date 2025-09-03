# DevPilot Migration Guide

## Legacy Script Migration

As of 2025-09-03, DevPilot has consolidated all functionality under the unified `dp` CLI command.
Legacy scripts are being phased out in favor of the new structure.

### Maintained Compatibility Wrappers

The following legacy scripts now forward to their `dp` equivalents:

| Legacy Script                 | New Command      | Notes                          |
| ----------------------------- | ---------------- | ------------------------------ |
| `scripts/after_clone.sh`      | `dp init`        | Initialize project after clone |
| `scripts/generate_tickets.sh` | `dp tickets`     | Generate tickets from codebase |
| `scripts/review_local.sh`     | `dp review`      | Review local changes           |
| `scripts/repo_review.sh`      | `dp repo-review` | Full repository review         |

These wrappers print deprecation notices but maintain full backward compatibility.

### Removed/Archived Scripts

The following scripts have been removed or archived:

- `generate_tickets_legacy.sh` - Original implementation, replaced by `dp tickets`
- `.archive/setup.sh.old` - Old setup script, use `dp setup`
- `*.yml.disabled` - Disabled workflows, no longer needed

### Migration Steps

1. **Update your scripts/workflows**:

   ```bash
   # Old
   ./scripts/after_clone.sh

   # New
   dp init
   ```

2. **Update CI/CD pipelines**:

   ```yaml
   # Old
   - run: ./scripts/generate_tickets.sh

   # New
   - run: dp tickets
   ```

3. **Update documentation**:
   - Replace references to individual scripts with `dp` commands
   - Update README files to reflect the new structure

### Command Mapping

| Task               | Old Method                    | New Method       |
| ------------------ | ----------------------------- | ---------------- |
| Initialize project | `scripts/after_clone.sh`      | `dp init`        |
| Generate tickets   | `scripts/generate_tickets.sh` | `dp tickets`     |
| Review changes     | `scripts/review_local.sh`     | `dp review`      |
| Full repo review   | `scripts/repo_review.sh`      | `dp repo-review` |
| Setup project      | `setup/repo_wizard.sh`        | `dp setup`       |
| Check system       | `scripts/doctor.sh`           | `dp doctor`      |
| Agent tasks        | `scripts/agent_*.sh`          | `dp agent`       |

### Benefits of Migration

- **Unified interface**: Single entry point for all DevPilot functionality
- **Better discovery**: `dp help` shows all available commands
- **Consistent behavior**: Shared configuration and error handling
- **Improved performance**: Optimized command routing
- **Multi-user support**: Automatic detection of single/multi-user modes

### Support

For help with migration:

- Run `dp help` for command documentation
- Report issues at https://github.com/Softsensor-org/DevPilot/issues
