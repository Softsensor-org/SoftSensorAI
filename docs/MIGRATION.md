# Migration Guide

## Migrating from DevPilot v1.x to v2.0

DevPilot 2.0 is a major release with significant improvements. While we've maintained backward
compatibility where possible, some changes require migration steps.

## Quick Migration (5 minutes)

```bash
# 1. Backup your current setup
cp -r ~/.claude ~/.claude.v1.backup
cp -r ~/.gemini ~/.gemini.v1.backup
cp -r ~/.grok ~/.grok.v1.backup

# 2. Get DevPilot 2.0
cd ~/devpilot  # or wherever you installed it
git fetch origin
git checkout v2.0.0

# 3. Run the upgrade
./setup_all.sh

# 4. Update your projects
for project in ~/projects/*/*; do
  if [ -d "$project/.git" ]; then
    echo "Updating $project"
    (cd "$project" && ~/devpilot/setup/agents_repo.sh --force)
  fi
done
```

## What's Changed

### Directory Structure

**Before (v1.x):**

```
devpilot/
├── install_key_software_wsl.sh
├── install_ai_clis.sh
├── setup_agents_global.sh
├── setup_agents_repo.sh
├── repo_setup_wizard.sh
└── validate_agents.sh
```

**After (v2.0):**

```
devpilot/
├── setup_all.sh              # Single entry point
├── install/                  # All installers
│   ├── key_software_linux.sh # Merged WSL+Linux
│   ├── key_software_macos.sh
│   └── ai_clis.sh
├── setup/                    # Setup scripts
│   ├── agents_global.sh
│   ├── agents_repo.sh
│   └── repo_wizard.sh
└── validation/               # Validation tools
    └── validate_agents.sh
```

### Script Changes

| Old Command                     | New Command                                           |
| ------------------------------- | ----------------------------------------------------- |
| `./install_key_software_wsl.sh` | `./install/key_software_linux.sh`                     |
| `./setup_agents_global.sh`      | `./setup/agents_global.sh` (auto-run by setup_all.sh) |
| `./repo_setup_wizard.sh`        | `./setup/repo_wizard.sh`                              |
| `./validate_agents.sh`          | `./validation/validate_agents.sh`                     |

### Configuration Updates

#### Global Settings

- Location unchanged: `~/.claude/`, `~/.gemini/`, etc.
- New features added (MCP servers, advanced permissions)
- Existing settings preserved

#### Repository Settings

- `.claude/commands/` now includes 15+ new commands
- `.mcp.json` added for MCP server configuration
- `CLAUDE.md` enhanced with skill-based instructions

## New Features to Enable

### 1. Skill Profiles

Set your skill level for each project:

```bash
cd your-project
~/devpilot/scripts/apply_profile.sh --skill beginner --teach-mode on
# or: --skill l1, --skill l2, --skill expert
```

### 2. Project Phases

Configure project maturity:

```bash
~/devpilot/scripts/apply_profile.sh --phase mvp
# or: --phase poc, --phase beta, --phase scale
```

### 3. MCP Servers

Add to `.mcp.local.json` in your project:

```json
{
  "mcpServers": {
    "github": {
      "command": "mcp-github",
      "args": ["--repo", "owner/repo"]
    }
  }
}
```

### 4. New Commands

Try these in Claude:

- `/think-hard` - Deep problem solving
- `/security-review` - Find vulnerabilities
- `/audit-full` - Complete code review
- `/tickets-from-code` - Generate issues

## Breaking Changes

### 1. WSL Installer Removed

- **Impact**: Scripts calling `install_key_software_wsl.sh`
- **Fix**: Use `install/key_software_linux.sh` instead

### 2. Root Directory Scripts

- **Impact**: Direct paths to root scripts
- **Fix**: Update paths to use subdirectories

### 3. Upgrade Mode Removed

- **Impact**: `setup_all.sh --upgrade` no longer works
- **Fix**: Just run `setup_all.sh` (auto-detects)

## Troubleshooting

### Issue: Command not found

```bash
# Reload your shell
exec bash
# or
source ~/.bashrc
```

### Issue: Old scripts referenced

```bash
# Find and update old references
grep -r "install_key_software_wsl" ~/projects
grep -r "setup_agents_global.sh" ~/projects
```

### Issue: Permissions error

```bash
# Fix permissions
chmod +x ~/devpilot/**/*.sh
```

### Issue: Configuration conflicts

```bash
# Reset to defaults
rm -rf ~/.claude ~/.gemini ~/.grok
~/devpilot/setup/agents_global.sh
```

## Rollback Plan

If you need to revert to v1.x:

```bash
# 1. Restore backups
rm -rf ~/.claude ~/.gemini ~/.grok
cp -r ~/.claude.v1.backup ~/.claude
cp -r ~/.gemini.v1.backup ~/.gemini
cp -r ~/.grok.v1.backup ~/.grok

# 2. Checkout old version
cd ~/devpilot
git checkout v1.5.0

# 3. Note: Some features will be unavailable
```

## FAQ

### Q: Do I need to reinstall everything?

**A:** No, running `setup_all.sh` will detect existing installations and update configurations.

### Q: Will my API keys be preserved?

**A:** Yes, API keys in `.envrc.local` or environment variables are unchanged.

### Q: Can I keep using old scripts?

**A:** Legacy wrapper scripts are provided, but we recommend updating to new paths.

### Q: What about my existing projects?

**A:** Run `~/devpilot/setup/agents_repo.sh --force` in each project to update.

### Q: Is the migration reversible?

**A:** Yes, with backups you can rollback. However, you'll lose v2.0 features.

## Benefits After Migration

- ✅ **Skill-based progression** - Tools that grow with you
- ✅ **Better organization** - Cleaner directory structure
- ✅ **More commands** - 15+ new Claude commands
- ✅ **MCP support** - GitHub and Jira integrations
- ✅ **Productivity tools** - Database, ML, K8s utilities
- ✅ **Teaching mode** - Learn as you code

## Need Help?

1. Check validation: `~/devpilot/validation/validate_agents.sh`
2. Review docs: `~/devpilot/docs/`
3. Open issue: https://github.com/Softsensor-org/DevPilot/issues

---

**Welcome to DevPilot 2.0!** The migration is worth it for the enhanced features and better
development experience.
