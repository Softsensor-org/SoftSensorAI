# Simplified Setup Flow

## What Changed?

### Before (Complex)
- 12+ interactive questions
- Nested folder structures: `org/category/repo/`
- Separate wizards for different scenarios
- Manual profile configuration
- Explicit hooks installation

### After (Simple)
- **1 question**: GitHub URL
- Flat structure: `org/repo/`
- Single unified command
- Smart defaults applied automatically
- Everything configured silently

## New Usage

### Single Repository
```bash
ss setup
# Enter GitHub URL: git@github.com:acme/webapp-api.git
# Done! Creates: ~/projects/acme/webapp-api/
```

### Multiple Repositories (Project)
```bash
ss setup
# Enter GitHub URL: git@github.com:acme/shop-api.git
# Additional URLs? (empty to continue)
# > git@github.com:acme/shop-ui.git
# > [enter]
# Creates: ~/projects/acme/shop/shop-api/
#          ~/projects/acme/shop/shop-ui/
```

### Existing Repository
```bash
cd my-existing-repo
ss setup
# Add SoftSensorAI configurations here? (Y/n): y
# Done!
```

## Folder Structure

### Old Structure (with categories)
```
~/projects/
└── org1/
    ├── backend/
    │   └── api-service/
    ├── frontend/
    │   └── web-app/
    └── customer/
        └── project/
            ├── backend/
            │   └── project-api/
            └── frontend/
                └── project-ui/
```

### New Structure (flat)
```
~/projects/
└── org1/
    ├── api-service/      # Direct repos
    ├── web-app/
    └── customer-project/ # Multi-repo project
        ├── project-api/
        └── project-ui/
```

## Smart Defaults

All these are now automatic:
- **Profile**: L2/MVP (mid-level developer, practical phase)
- **Organization**: Extracted from GitHub URL or "default"
- **Dependencies**: Installed silently (pnpm/npm for Node, venv for Python)
- **Git Hooks**: Commit sanitizer installed automatically
- **Agent Configs**: CLAUDE.md, .claude/, .codex/ all configured

## Migration from Old Setup

If you have existing repos in the old structure, they'll continue to work. For new repos, use the simplified setup:

```bash
# Old way (still works but deprecated)
./setup/repo_wizard.sh
./setup/customer_project_wizard.sh

# New way (recommended)
ss setup
```

## Advanced Options

For cases where you need more control:

```bash
# Skip dependency installation
SOFTSENSORAI_BASE=~/custom/path ss setup

# Use specific organization
SOFTSENSORAI_ORG=myorg ss setup

# Manual profile configuration after setup
cd repo && ss profile
```

## Benefits

1. **90% faster setup** - From 5+ minutes to under 30 seconds
2. **No decision fatigue** - Smart defaults for everything
3. **Cleaner paths** - No redundant category folders
4. **Git-friendly** - Works with git clone's natural behavior
5. **Context-aware** - Detects if you're in a repo, empty dir, or setup location

## Troubleshooting

### Missing templates
```bash
# Ensure templates exist
ls ~/softsensorai/templates/
```

### Permission issues
```bash
# Fix permissions
chmod +x ~/softsensorai/setup/simplified_setup.sh
```

### Custom base directory
```bash
# Set custom base
export SOFTSENSORAI_BASE=~/my-projects
ss setup
```