# Multi-User / Team Installation Guide

SoftSensorAI supports both single-user (developer laptop) and multi-user (shared server)
installations. This guide covers the multi-user model for teams.

## Installation Modes

### Single-User Mode (Default)

- SoftSensorAI lives in your repository
- Artifacts stored in `./artifacts/`
- Perfect for individual developers
- No special permissions required

### Multi-User Mode (Teams)

- SoftSensorAI installed system-wide at `/opt/softsensorai`
- Per-user artifacts in `~/.softsensorai/artifacts/`
- Shared templates and tools
- Centralized updates by admins

## How Mode Detection Works

The `ssai` command automatically detects multi-user installations by checking for
`/opt/softsensorai/etc/softsensorai.conf`:

```bash
# Mode detection in bin/ssai
if [[ -f "/opt/softsensorai/etc/softsensorai.conf" ]]; then
    # Multi-user mode
    source /opt/softsensorai/etc/softsensorai.conf
    ROOT="${SOFTSENSORAI_ROOT:-/opt/softsensorai}"
    ART="${SOFTSENSORAI_USER_DIR:-$HOME/.softsensorai}/artifacts"
else
    # Single-user mode
    ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    ART="$ROOT/artifacts"
fi
```

## System-Wide Installation (Admin)

### Prerequisites

- Root/sudo access
- Bash 4.0+
- Git installed
- At least one AI CLI (see [AI CLI Installation Guide](./AI_CLI_INSTALL.md))

### Quick Install

```bash
# Download and run the multi-user installer (public repos only)
curl -fsSL https://raw.githubusercontent.com/Softsensor-org/SoftSensorAI/main/scripts/install_multi_user.sh | sudo bash

# For private repos, clone first then run:
git clone https://github.com/Softsensor-org/SoftSensorAI.git
sudo bash SoftSensorAI/scripts/install_multi_user.sh
```

### Manual Install

```bash
# 1. Create system directories
sudo mkdir -p /opt/softsensorai/{bin,tools,templates,scripts,etc}

# 2. Clone SoftSensorAI
sudo git clone https://github.com/Softsensor-org/SoftSensorAI.git /opt/softsensorai/src

# 3. Copy components
sudo cp -r /opt/softsensorai/src/bin/* /opt/softsensorai/bin/
sudo cp -r /opt/softsensorai/src/tools/* /opt/softsensorai/tools/
sudo cp -r /opt/softsensorai/src/templates/* /opt/softsensorai/templates/
sudo cp -r /opt/softsensorai/src/scripts/* /opt/softsensorai/scripts/

# 4. Create configuration
sudo tee /opt/softsensorai/etc/softsensorai.conf > /dev/null <<'EOF'
# SoftSensorAI Multi-User Configuration
SOFTSENSORAI_ROOT=/opt/softsensorai
SOFTSENSORAI_USER_DIR=$HOME/.softsensorai
SOFTSENSORAI_VERSION=2.0.0

# Optional: Shared AI provider (users can override)
# AI_PROVIDER=anthropic
# AI_MODEL=claude-3-7-sonnet-20250219
EOF

# 5. Set permissions
sudo chmod 755 /opt/softsensorai/bin/*
sudo chmod 644 /opt/softsensorai/etc/softsensorai.conf

# 6. Add to system PATH
echo 'export PATH="/opt/softsensorai/bin:$PATH"' | sudo tee /etc/profile.d/softsensorai.sh
```

## User Setup

Each user needs to initialize their personal SoftSensorAI environment:

```bash
# 1. Create user directories
mkdir -p ~/.softsensorai/{artifacts,cache,logs,config}

# 2. Set up API keys (if not using shared keys)
export ANTHROPIC_API_KEY="sk-ant-..."
# Or use secure storage
/opt/softsensorai/utils/secure_keys.sh store

# 3. Initialize a project
cd ~/my-project
ssai init

# 4. Verify setup
ssai doctor
```

## Configuration File Reference

### System Configuration (`/opt/softsensorai/etc/softsensorai.conf`)

```bash
# Required settings
SOFTSENSORAI_ROOT=/opt/softsensorai           # System installation path
SOFTSENSORAI_USER_DIR=$HOME/.softsensorai     # Per-user data directory
SOFTSENSORAI_VERSION=2.0.0                 # SoftSensorAI version

# Optional team defaults
AI_PROVIDER=anthropic                  # Default AI provider
AI_MODEL=claude-3-7-sonnet-20250219   # Default model
BASE_BRANCH=main                       # Default base branch for agents

# Optional paths (rarely changed)
SOFTSENSORAI_TEMPLATES=/opt/softsensorai/templates
SOFTSENSORAI_TOOLS=/opt/softsensorai/tools
SOFTSENSORAI_SCRIPTS=/opt/softsensorai/scripts
```

### User Configuration (`~/.softsensorai/config/user.conf`)

Users can override team defaults:

```bash
# Personal overrides
AI_PROVIDER=openai                     # Use different provider
AI_MODEL=gpt-4                         # Use different model
EDITOR=nvim                             # Preferred editor
```

## Directory Structure

### System Directories (root-owned)

```
/opt/softsensorai/
├── bin/                # Executables (ssai, ssai-agent)
├── tools/              # Utility scripts
├── templates/          # Project templates
├── scripts/            # Setup and maintenance scripts
├── etc/                # Configuration
│   └── softsensorai.conf   # System config
└── src/                # Source repository (for updates)
```

### User Directories (user-owned)

```
~/.softsensorai/
├── artifacts/          # Task outputs
│   ├── agent/          # Agent task results
│   ├── review/         # Code review results
│   └── build/          # Build artifacts
├── cache/              # Temporary files
├── logs/               # User activity logs
└── config/             # Personal configuration
    ├── user.conf       # User overrides
    └── keys.enc        # Encrypted API keys
```

## Status Display

When running SoftSensorAI commands, the mode and paths are displayed:

```bash
$ ssai init
✓ SoftSensorAI initialized for project: my-app
  Version      : 2.0.0
  Mode         : Multi-user
  System root  : /opt/softsensorai
  Your artifacts: /home/alice/.softsensorai/artifacts
```

## Team Workflows

### Agent Branch Naming

Multi-user installations use namespaced branches for agent work:

```bash
agent/<username>/<task-id>
# Example: agent/alice/task-20250903-fix-auth
```

### PR Auto-Labeling

Agent-created PRs automatically get labels:

- `agentic` - Created by AI agent
- `owner:<username>` - Task owner
- `risk:<level>` - Risk assessment (auth, db, infra, etc.)

### Shared Templates

Admins can add team-specific templates:

```bash
# Admin adds a template
sudo cp company-template.md /opt/softsensorai/templates/

# Users can use it
ssai init --template company-template
```

## Team Doctor Command

Check multi-user setup health:

```bash
$ ssai team doctor

SoftSensorAI Team Setup Check
-------------------------
✓ Multi-user mode active
✓ System config readable: /opt/softsensorai/etc/softsensorai.conf
✓ System root valid: /opt/softsensorai
✓ User directory writable: ~/.softsensorai
✓ Artifacts directory exists: ~/.softsensorai/artifacts
✓ AI CLI available: anthropic
✓ Git configured: user.name = Alice Smith
✓ SSH key exists for GitHub

All checks passed! Ready for team development.
```

## Maintenance

### Updating SoftSensorAI (Admin)

```bash
# 1. Pull latest changes
cd /opt/softsensorai/src
sudo git pull

# 2. Update components
sudo cp -r bin/* /opt/softsensorai/bin/
sudo cp -r tools/* /opt/softsensorai/tools/
sudo cp -r templates/* /opt/softsensorai/templates/

# 3. Notify users
echo "SoftSensorAI updated to $(cat VERSION)" | wall
```

### Backup Strategy

Regular backups should include:

- `/opt/softsensorai/etc/` - Configuration
- `/opt/softsensorai/templates/` - Custom templates
- `~/.softsensorai/` - User data (each user)

### Monitoring Usage

```bash
# Check active users
ls -la /home/*/.softsensorai/artifacts/agent/task-* 2>/dev/null | wc -l

# Disk usage per user
du -sh /home/*/.softsensorai/artifacts 2>/dev/null

# Recent agent tasks
find /home -path "*/.softsensorai/artifacts/agent/task-*" -mtime -7 2>/dev/null
```

## Troubleshooting

### Permission Denied

If users get permission errors:

```bash
# Fix system directory permissions
sudo chmod 755 /opt/softsensorai/{bin,tools,scripts}/*
sudo chmod 644 /opt/softsensorai/etc/softsensorai.conf

# User should own their directory
chown -R $USER:$USER ~/.softsensorai
```

### Mode Not Detected

If `ssai` doesn't detect multi-user mode:

```bash
# Check config exists and is readable
ls -la /opt/softsensorai/etc/softsensorai.conf

# Verify it's being sourced
grep "softsensorai.conf" $(which ssai)

# Test manually
source /opt/softsensorai/etc/softsensorai.conf
echo $SOFTSENSORAI_ROOT  # Should show /opt/softsensorai
```

### Artifacts Missing

If artifacts aren't where expected:

```bash
# Check which mode is active
ssai init | grep Mode

# Verify artifact path
echo $ART

# Ensure directory exists
mkdir -p ~/.softsensorai/artifacts
```

## Security Considerations

### API Key Management

- **Never** store API keys in `/opt/softsensorai/etc/softsensorai.conf`
- Users should set keys in their shell environment or use encrypted storage
- Consider using a secrets management system for production

### File Permissions

```bash
# System files (root-owned, world-readable)
/opt/softsensorai/**: root:root 755 (dirs), 644 (files), 755 (executables)

# User files (user-owned, user-only)
~/.softsensorai/**: $USER:$USER 700 (dirs), 600 (files)
```

### Audit Logging

Enable audit logging for compliance:

```bash
# Add to softsensorai.conf
SOFTSENSORAI_AUDIT_LOG=/var/log/softsensorai/audit.log

# Create log directory
sudo mkdir -p /var/log/softsensorai
sudo touch /var/log/softsensorai/audit.log
sudo chmod 666 /var/log/softsensorai/audit.log
```

## Migration Guide

### From Single-User to Multi-User

```bash
# 1. Admin installs system-wide SoftSensorAI
sudo ./scripts/install_multi_user.sh

# 2. Users migrate their artifacts
mv ./artifacts/* ~/.softsensorai/artifacts/

# 3. Remove local installation
rm -rf bin/ tools/ scripts/ templates/

# 4. Verify multi-user mode
ssai doctor
```

### From Multi-User to Single-User

```bash
# 1. Clone SoftSensorAI locally
git clone https://github.com/Softsensor-org/SoftSensorAI.git .

# 2. Copy artifacts back
cp -r ~/.softsensorai/artifacts/* ./artifacts/

# 3. Remove multi-user config (admin)
sudo rm /opt/softsensorai/etc/softsensorai.conf

# 4. Verify single-user mode
./bin/ssai doctor
```

## See Also

- [Quick Start Guide](./quickstart.md) - Getting started with SoftSensorAI
- [AI CLI Installation](./AI_CLI_INSTALL.md) - Setting up AI providers
- [Architecture Overview](./ARCHITECTURE_OVERVIEW.md) - System design
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues and solutions
