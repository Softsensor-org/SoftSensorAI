# SoftSensorAI Directory Structure

## Root Directory

```
.
├── README.md           # Main documentation
├── LICENSE             # License file
├── VERSION             # Version tracking
├── Makefile            # Build automation
├── setup_all.sh        # Main setup script
├── AGENTS.md           # Agent configurations
├── CLAUDE.md           # Claude AI instructions
└── PROFILE.md          # Profile documentation
```

## Directory Organization

### `/bin/`

Executable scripts and CLI tools

- `ssai` - Main SoftSensorAI CLI

### `/config/`

Configuration files and profiles

- `package.json` - Node.js dependencies
- `requirements.txt` - Python dependencies
- `profiles/` - Skill and phase profiles

### `/docs/`

All documentation

- `guides/` - User guides
- `dev/` - Developer documentation
- `api/` - API documentation
- `architecture/` - System design docs

### `/install/`

Installation scripts for different platforms

### `/scripts/`

Utility and automation scripts

### `/setup/`

Repository setup scripts

### `/system/`

System prompts and configurations

### `/templates/`

Project and file templates

### `/tests/`

Test files and test scripts

### `/tools/`

Development tools and utilities

### `/utils/`

Utility functions and helpers

### `/validation/`

Validation and checking scripts

### `/var/`

Variable data (not tracked in git)

- `tmp/` - Temporary files
- `cache/` - Cache files
- `logs/` - Log files

### `/workspace/`

Working directories for examples and testing

### `/.archive/`

Archived old files for reference
