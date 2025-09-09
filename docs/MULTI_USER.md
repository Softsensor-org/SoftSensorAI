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

- SoftSensorAI installed system-wide at `/opt/devpilot`
- Per-user artifacts in `~/.devpilot/artifacts/`
- Shared templates and tools
- Centralized updates by admins

## How Mode Detection Works

The `dp` command automatically detects multi-user installations by checking for
`/opt/devpilot/etc/devpilot.conf`:

```bash
# Mode detection in bin/dp
if [[ -f "/opt/devpilot/etc/devpilot.conf" ]]; then
    # Multi-user mode
    source /opt/devpilot/etc/devpilot.conf
    ROOT="${DEVPILOT_ROOT:-/opt/devpilot}"
    ART="${DEVPILOT_USER_DIR:-$HOME/.devpilot}/artifacts"
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
sudo mkdir -p /opt/devpilot/{bin,tools,templates,scripts,etc}

# 2. Clone SoftSensorAI
sudo git clone https://github.com/Softsensor-org/SoftSensorAI.git /opt/devpilot/src

# 3. Copy components
sudo cp -r /opt/devpilot/src/bin/* /opt/devpilot/bin/
sudo cp -r /opt/devpilot/src/tools/* /opt/devpilot/tools/
sudo cp -r /opt/devpilot/src/templates/* /opt/devpilot/templates/
sudo cp -r /opt/devpilot/src/scripts/* /opt/devpilot/scripts/

# 4. Create configuration
sudo tee /opt/devpilot/etc/devpilot.conf > /dev/null <<'EOF'
# SoftSensorAI Multi-User Configuration
DEVPILOT_ROOT=/opt/devpilot
DEVPILOT_USER_DIR=$HOME/.devpilot
DEVPILOT_VERSION=2.0.0

# Optional: Shared AI provider (users can override)
# AI_PROVIDER=anthropic
# AI_MODEL=claude-3-7-sonnet-20250219
EOF

# 5. Set permissions
sudo chmod 755 /opt/devpilot/bin/*
sudo chmod 644 /opt/devpilot/etc/devpilot.conf

# 6. Add to system PATH
echo 'export PATH="/opt/devpilot/bin:$PATH"' | sudo tee /etc/profile.d/devpilot.sh
```

## User Setup

Each user needs to initialize their personal SoftSensorAI environment:

```bash
# 1. Create user directories
mkdir -p ~/.devpilot/{artifacts,cache,logs,config}

# 2. Set up API keys (if not using shared keys)
export ANTHROPIC_API_KEY="sk-ant-..."
# Or use secure storage
/opt/devpilot/utils/secure_keys.sh store

# 3. Initialize a project
cd ~/my-project
dp init

# 4. Verify setup
dp doctor
```

## Configuration File Reference

### System Configuration (`/opt/devpilot/etc/devpilot.conf`)

```bash
# Required settings
DEVPILOT_ROOT=/opt/devpilot           # System installation path
DEVPILOT_USER_DIR=$HOME/.devpilot     # Per-user data directory
DEVPILOT_VERSION=2.0.0                 # SoftSensorAI version

# Optional team defaults
AI_PROVIDER=anthropic                  # Default AI provider
AI_MODEL=claude-3-7-sonnet-20250219   # Default model
BASE_BRANCH=main                       # Default base branch for agents

# Optional paths (rarely changed)
DEVPILOT_TEMPLATES=/opt/devpilot/templates
DEVPILOT_TOOLS=/opt/devpilot/tools
DEVPILOT_SCRIPTS=/opt/devpilot/scripts
```

### User Configuration (`~/.devpilot/config/user.conf`)

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
/opt/devpilot/
├── bin/                # Executables (dp, dp-agent)
├── tools/              # Utility scripts
├── templates/          # Project templates
├── scripts/            # Setup and maintenance scripts
├── etc/                # Configuration
│   └── devpilot.conf   # System config
└── src/                # Source repository (for updates)
```

### User Directories (user-owned)

```
~/.devpilot/
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
$ dp init
✓ SoftSensorAI initialized for project: my-app
  Version      : 2.0.0
  Mode         : Multi-user
  System root  : /opt/devpilot
  Your artifacts: /home/alice/.devpilot/artifacts
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
sudo cp company-template.md /opt/devpilot/templates/

# Users can use it
dp init --template company-template
```

## Team Doctor Command

Check multi-user setup health:

```bash
$ dp team doctor

SoftSensorAI Team Setup Check
-------------------------
✓ Multi-user mode active
✓ System config readable: /opt/devpilot/etc/devpilot.conf
✓ System root valid: /opt/devpilot
✓ User directory writable: ~/.devpilot
✓ Artifacts directory exists: ~/.devpilot/artifacts
✓ AI CLI available: anthropic
✓ Git configured: user.name = Alice Smith
✓ SSH key exists for GitHub

All checks passed! Ready for team development.
```

## Maintenance

### Updating SoftSensorAI (Admin)

```bash
# 1. Pull latest changes
cd /opt/devpilot/src
sudo git pull

# 2. Update components
sudo cp -r bin/* /opt/devpilot/bin/
sudo cp -r tools/* /opt/devpilot/tools/
sudo cp -r templates/* /opt/devpilot/templates/

# 3. Notify users
echo "SoftSensorAI updated to $(cat VERSION)" | wall
```

### Backup Strategy

Regular backups should include:

- `/opt/devpilot/etc/` - Configuration
- `/opt/devpilot/templates/` - Custom templates
- `~/.devpilot/` - User data (each user)

### Monitoring Usage

```bash
# Check active users
ls -la /home/*/.devpilot/artifacts/agent/task-* 2>/dev/null | wc -l

# Disk usage per user
du -sh /home/*/.devpilot/artifacts 2>/dev/null

# Recent agent tasks
find /home -path "*/.devpilot/artifacts/agent/task-*" -mtime -7 2>/dev/null
```

## Troubleshooting

### Permission Denied

If users get permission errors:

```bash
# Fix system directory permissions
sudo chmod 755 /opt/devpilot/{bin,tools,scripts}/*
sudo chmod 644 /opt/devpilot/etc/devpilot.conf

# User should own their directory
chown -R $USER:$USER ~/.devpilot
```

### Mode Not Detected

If `dp` doesn't detect multi-user mode:

```bash
# Check config exists and is readable
ls -la /opt/devpilot/etc/devpilot.conf

# Verify it's being sourced
grep "devpilot.conf" $(which dp)

# Test manually
source /opt/devpilot/etc/devpilot.conf
echo $DEVPILOT_ROOT  # Should show /opt/devpilot
```

### Artifacts Missing

If artifacts aren't where expected:

```bash
# Check which mode is active
dp init | grep Mode

# Verify artifact path
echo $ART

# Ensure directory exists
mkdir -p ~/.devpilot/artifacts
```

## Security Considerations

### API Key Management

- **Never** store API keys in `/opt/devpilot/etc/devpilot.conf`
- Users should set keys in their shell environment or use encrypted storage
- Consider using a secrets management system for production

### File Permissions

```bash
# System files (root-owned, world-readable)
/opt/devpilot/**: root:root 755 (dirs), 644 (files), 755 (executables)

# User files (user-owned, user-only)
~/.devpilot/**: $USER:$USER 700 (dirs), 600 (files)
```

### Audit Logging

Enable audit logging for compliance:

```bash
# Add to devpilot.conf
DEVPILOT_AUDIT_LOG=/var/log/devpilot/audit.log

# Create log directory
sudo mkdir -p /var/log/devpilot
sudo touch /var/log/devpilot/audit.log
sudo chmod 666 /var/log/devpilot/audit.log
```

## Migration Guide

### From Single-User to Multi-User

```bash
# 1. Admin installs system-wide SoftSensorAI
sudo ./scripts/install_multi_user.sh

# 2. Users migrate their artifacts
mv ./artifacts/* ~/.devpilot/artifacts/

# 3. Remove local installation
rm -rf bin/ tools/ scripts/ templates/

# 4. Verify multi-user mode
dp doctor
```

### From Multi-User to Single-User

```bash
# 1. Clone SoftSensorAI locally
git clone https://github.com/Softsensor-org/SoftSensorAI.git .

# 2. Copy artifacts back
cp -r ~/.devpilot/artifacts/* ./artifacts/

# 3. Remove multi-user config (admin)
sudo rm /opt/devpilot/etc/devpilot.conf

# 4. Verify single-user mode
./bin/dp doctor
```

## See Also

- [Quick Start Guide](./quickstart.md) - Getting started with SoftSensorAI
- [AI CLI Installation](./AI_CLI_INSTALL.md) - Setting up AI providers
- [Architecture Overview](./ARCHITECTURE_OVERVIEW.md) - System design
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues and solutions
