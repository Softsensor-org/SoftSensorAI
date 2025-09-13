# SoftSensorAI Setup Scripts

**One-command setup for AI-powered development environments.**

Automatically configures Claude, Codex, Gemini, and other AI assistants for your projects with the right permissions, commands, and workflows.

## What This Does

- **Sets up AI assistants** with proper configurations for your skill level
- **Installs development tools** (ripgrep, jq, gh, direnv, etc.)
- **Configures projects** with AI-ready settings and commands
- **Provides 50+ AI commands** for common development tasks

## Quick Start

```bash
# 1. Clone and install (one time)
git clone https://github.com/Softsensor-org/SoftSensorAI.git
cd SoftSensorAI
./setup_all.sh

# 2. Add to your PATH
export PATH="$(pwd)/bin:$PATH"  # Add to ~/.bashrc

# 3. Setup any project
ssai setup                      # Interactive
# or
ssai setup https://github.com/user/repo
```

That's it! Your project now has AI assistant configurations.

## What You Get

**Global Setup** (installed once on your machine):
- Development tools: `rg`, `jq`, `gh`, `fzf`, etc.
- AI CLI tools: `claude`, `codex`, `gemini`, `grok`
- Global AI configurations

**Per-Project Setup** (for each repository):
- `CLAUDE.md` - AI understands your project
- `.claude/settings.json` - Project permissions
- `.claude/commands/` - 50+ specialized AI commands
- Smart defaults based on your skill level

## Installation Options

### Single User (Default)
```bash
git clone https://github.com/Softsensor-org/SoftSensorAI.git
cd SoftSensorAI && ./setup_all.sh
```

### Multi-User/Team
```bash
sudo ./install/multi_user_setup.sh
```

## Core Commands

```bash
ssai setup        # Setup a project with AI tools
ssai doctor       # Check system health
ssai review       # AI code review
ssai tickets      # Generate tickets from code
ssai help         # Quick reference
```

## Features

- **Smart Detection** - Automatically detects your project type and sets appropriate configurations
- **Skill Levels** - Adapts AI behavior to your experience (beginner, junior, mid-level, expert)
- **Project Phases** - Different settings for POC, MVP, Beta, and Production phases
- **AI Commands** - Pre-built prompts for common tasks like `/think-hard`, `/security-review`, `/backend-feature`
- **Multi-AI Support** - Works with Claude, Codex, Gemini, Grok, and others
- **Team Ready** - Multi-user installations and consistent configurations

## System Requirements

- **OS**: Linux, macOS, Windows (WSL)
- **Prerequisites**: `bash`, `git`, `curl`
- **Disk Space**: ~2GB for full installation
- **AI CLIs**: Optional but recommended

## Popular AI Commands

Once set up, use these commands in Claude or Cursor:

- `/think-hard` - Deep analysis with structured reasoning
- `/security-review` - Comprehensive security audit
- `/backend-feature` - Create API endpoints with tests
- `/tickets-from-code` - Generate project backlog
- `/explore-plan-code-test` - Full development workflow

## Documentation

- **[Quick Tutorial](tutorials/quick-start-this-week.md)** - Start using in 5 minutes
- **[Multi-User Setup](docs/MULTI_USER.md)** - Team installations
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues

## Support

- **Issues**: [GitHub Issues](https://github.com/Softsensor-org/SoftSensorAI/issues)
- **System Check**: Run `ssai doctor` to diagnose problems

---

**Transform your development workflow with AI in minutes, not hours.**