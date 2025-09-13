# ssai setup

## Overview

Smart repository setup that automatically detects your context and adds SoftSensorAI capabilities to
any project.

## Usage

```bash
ssai setup [URL] [OPTIONS]
```

## What It Does

1. **Detects Context** - Automatically determines if you're in an existing repo, have a URL, or need
   guidance
2. **Adds SoftSensorAI Files** - Creates CLAUDE.md, AGENTS.md, .claude/ directory structure
3. **Handles Conflicts** - Smart merging for existing files (skip, merge, backup, or diff)
4. **Preserves Your Structure** - Never moves or reorganizes your existing files

## Examples

### Existing Repository

```bash
cd ~/my-project
ssai setup
# ✓ Detected existing repository: my-project
# ✓ Creating CLAUDE.md...
# ✓ Setting up .claude/ directory...
# ✓ Setup complete!
```

### New Repository (with URL)

```bash
ssai setup https://github.com/user/new-project
# ✓ Cloning repository...
# ✓ Entering new-project/
# ✓ Creating SoftSensorAI files...
# ✓ Setup complete!
```

### Empty Directory (Interactive)

```bash
mkdir new-app && cd new-app
ssai setup
# ? What would you like to do?
# > 1) Initialize new git repository here
#   2) Clone a repository
#   3) Cancel
```

## Options

- `--dry-run` - Preview what would be created without making changes
- `--force` - Overwrite existing files without prompting
- `--no-merge` - Skip file merging, preserve existing files

## Files Created

```
your-project/
├── CLAUDE.md           # AI instructions specific to your project
├── AGENTS.md           # General AI behavior directives
├── .claude/
│   ├── settings.json   # Project permissions
│   ├── commands/       # 60+ AI command templates
│   └── personas/       # Active AI personas
└── scripts/
    ├── apply_profile.sh # Profile management
    └── run_checks.sh    # Quality checks
```

## When to Use

- **Starting any new project** - Run immediately after cloning
- **Adding AI to existing project** - Run in your project root
- **Team onboarding** - Have new members run to get consistent setup

## What Happens Next

After `ssai setup`, run `ssai init` to:

- Check system health (`ssai doctor`)
- Configure skill level and project phase
- Install dependencies and build

## Troubleshooting

### "Already has SoftSensorAI files"

```bash
# Option 1: Skip setup (files already exist)
# Option 2: Force overwrite
ssai setup --force
# Option 3: See what would change
ssai setup --dry-run
```

### "Not a git repository"

```bash
# Initialize git first
git init
ssai setup
# Or clone a repository
ssai setup https://github.com/user/repo
```

## Related Commands

- [`ssai init`](init.md) - Initialize and configure after setup
- [`ssai doctor`](doctor.md) - Check system health
- [`ssai project`](project.md) - View/modify project configuration

## Implementation

- **Script**: `bin/ssai` (cmd_setup function)
- **Calls**: `setup/repo_wizard.sh` or `setup/existing_repo_setup.sh`
- **Smart Detection**: Checks for `.git/`, URL parameter, or empty directory
