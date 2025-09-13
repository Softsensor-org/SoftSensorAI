# SoftSensorAI - AI Development Tools

Simple AI-powered development setup. Choose single-user or multi-user installation.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/Softsensor-org/SoftSensorAI.git
cd SoftSensorAI

# 2. Install (asks single-user vs multi-user)
chmod +x setup_simple_final.sh && ./setup_simple_final.sh

# 3. Set up any project
ssai setup
```

## Installation Modes

### Single-User (Default)
- **Good for**: Personal use, development machines
- **What it does**: Installs tools to your home directory
- **Command**: `./setup_simple_final.sh` → choose option 1
- **Result**: Tools available to current user only

### Multi-User (Teams/Servers)
- **Good for**: Shared servers, team environments
- **What it does**: System-wide installation for all users
- **Command**: `sudo ./setup_simple_final.sh` → choose option 2
- **Result**: All users can use `ssai` command

After system-wide install, users run:
```bash
./install/user_setup.sh  # Configure personal settings
```

## What You Get

**Development Tools**: `git`, `ripgrep`, `jq`, `gh` CLI, etc.

**AI CLIs** (optional): `claude`, `codex`, `gemini`, `grok`

**Project Setup**: Simple `ssai setup` command that:
- Asks where to clone repositories (your choice)
- Adds minimal AI configuration files
- No hardcoded directory structures

## Usage

```bash
ssai setup                           # Interactive project setup
ssai setup https://github.com/you/repo  # Clone specific repo
ssai                                 # Show available commands
```

## Requirements

- `bash` 4.0+
- `git` 2.0+
- Internet connection
- For multi-user: `sudo` privileges

## That's It

No complex configurations. No assumptions about your workflow. Just simple setup and project configuration.