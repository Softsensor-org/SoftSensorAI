# DevPilot Multi-User Installation Guide

## Overview

DevPilot supports two installation models:

1. **Single-User Mode** (default) - Personal installation in user's home directory
2. **Multi-User Mode** (NEW) - System-wide shared installation with per-user configurations

This guide covers the multi-user installation model, ideal for:

- Shared development servers
- Team environments
- University/educational labs
- Cloud workstations
- Docker/container environments

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                   System Level (Root)                 │
├──────────────────────────────────────────────────────┤
│  /opt/devpilot/                                      │
│  ├── bin/           # Shared binaries (read-only)    │
│  ├── lib/           # Core libraries & scripts       │
│  ├── share/         # Shared resources               │
│  │   ├── patterns/  # Design patterns                │
│  │   ├── commands/  # System commands                │
│  │   └── personas/  # Default personas               │
│  └── etc/           # System configuration           │
│      └── devpilot.conf                               │
└──────────────────────────────────────────────────────┘
                           ↓
                    Shared by all users
                           ↓
┌──────────────────────────────────────────────────────┐
│                   User Level (Personal)               │
├──────────────────────────────────────────────────────┤
│  ~/.devpilot/                                        │
│  ├── config/        # Personal settings              │
│  │   ├── settings.json                               │
│  │   ├── api_keys.env.enc  # Encrypted keys         │
│  │   └── personas/  # Custom personas                │
│  ├── artifacts/     # Generated artifacts            │
│  ├── cache/         # User cache                     │
│  └── workspace/     # User workspace                 │
└──────────────────────────────────────────────────────┘
```

## Installation Process

### Step 1: System Administrator Setup (Run as Root)

```bash
# Download and run multi-user installation script
sudo curl -L https://github.com/Softsensor-org/DevPilot/raw/main/install/multi_user_setup.sh | sudo bash

# Or clone and run locally
git clone https://github.com/Softsensor-org/DevPilot.git
cd DevPilot
sudo ./install/multi_user_setup.sh
```

This will:

- Install system dependencies (git, jq, ripgrep, fd, direnv)
- Create `/opt/devpilot` directory structure
- Install DevPilot core components
- Set up system-wide configuration
- Create admin utilities (`dp-admin`)
- Configure logging and auditing

### Step 2: User Setup (Run as Regular User)

Each user runs their personal setup:

```bash
# Run user setup script
curl -L https://github.com/Softsensor-org/DevPilot/raw/main/install/user_setup.sh | bash

# Or if DevPilot is already installed system-wide
dp setup-user
```

This will:

- Create `~/.devpilot` directory structure
- Configure personal settings (skill level, phase, AI provider)
- Set up API keys template
- Create personal personas
- Add shell integration (aliases)
- Create example workspace

### Step 3: Configure API Keys

Each user must configure their personal API keys:

```bash
# Edit API keys file
vi ~/.devpilot/config/api_keys.env

# Add your keys:
ANTHROPIC_API_KEY="sk-ant-..."
OPENAI_API_KEY="sk-..."
GITHUB_TOKEN="ghp_..."

# Encrypt the keys for security
dp secure-keys encrypt
```

## Security Features

### 1. API Key Encryption

Three encryption methods supported:

- **GPG** (recommended) - Uses user's GPG key
- **OpenSSL** - Password-based AES-256 encryption
- **Age** - Modern, simple encryption tool

```bash
# Encrypt keys
dp secure-keys encrypt

# Decrypt keys (when needed)
dp secure-keys decrypt

# Check security status
dp secure-keys status

# Rotate encryption
dp secure-keys rotate
```

### 2. Resource Limits

Per-user limits configured in `/opt/devpilot/etc/devpilot.conf`:

```bash
DEVPILOT_MAX_ARTIFACTS_MB=1000    # Max artifacts storage
DEVPILOT_MAX_CACHE_MB=500         # Max cache size
DEVPILOT_MAX_CONCURRENT_AGENTS=3  # Max parallel agents
```

### 3. Sandboxing

All AI-generated code runs in sandboxed environment:

- Network isolation
- Filesystem restrictions
- Resource limits (CPU, memory)
- Timeout protection

### 4. Audit Logging

All operations logged to `/var/log/devpilot/`:

- User actions
- AI interactions
- Resource usage
- Security events

## Administration

### Admin Commands

System administrators can use `dp-admin`:

```bash
# List all DevPilot users
sudo dp-admin list-users

# Show usage statistics
sudo dp-admin stats

# Clean all user caches
sudo dp-admin clean-cache

# Update DevPilot system-wide
sudo dp-admin update

# Monitor real-time usage
sudo dp-admin monitor
```

### User Management

```bash
# Add new user (creates user directory)
sudo dp-admin add-user username

# Remove user (preserves data, disables access)
sudo dp-admin disable-user username

# Set user limits
sudo dp-admin set-limits username --artifacts 2000 --cache 1000
```

### Monitoring

View logs and usage:

```bash
# System logs
sudo tail -f /var/log/devpilot/system.log

# User activity
sudo grep username /var/log/devpilot/access.log

# Resource usage
sudo dp-admin stats --detailed
```

## Configuration

### System Configuration

Edit `/opt/devpilot/etc/devpilot.conf`:

```bash
# Installation paths
DEVPILOT_ROOT="/opt/devpilot"
DEVPILOT_USER_DIR="$HOME/.devpilot"

# Features
DEVPILOT_MULTI_USER=true
DEVPILOT_SANDBOX_ENABLED=true
DEVPILOT_AUDIT_ENABLED=true

# Resource limits
DEVPILOT_MAX_ARTIFACTS_MB=1000
DEVPILOT_MAX_CACHE_MB=500
DEVPILOT_MAX_CONCURRENT_AGENTS=3

# Security
DEVPILOT_REQUIRE_ENCRYPTION=false  # Set true to enforce key encryption
DEVPILOT_ALLOWED_AI_PROVIDERS="anthropic,openai,google,grok"
```

### User Configuration

Each user's `~/.devpilot/config/settings.json`:

```json
{
  "preferences": {
    "skill_level": "l2",
    "project_phase": "mvp",
    "ai_provider": "anthropic",
    "editor": "vim"
  },
  "features": {
    "sandbox_enabled": true,
    "audit_enabled": true,
    "telemetry_enabled": false
  }
}
```

## Advantages of Multi-User Mode

### 1. Centralized Management

- Single installation to maintain
- Consistent versions across all users
- Easy updates via `dp-admin update`
- System-wide security policies

### 2. Resource Efficiency

- Shared binaries and libraries (saves disk space)
- Shared pattern/command libraries
- Centralized dependency management
- Reduced installation time for new users

### 3. Security & Compliance

- Enforced security policies
- Centralized audit logging
- Resource usage limits
- Encrypted API key storage

### 4. Team Collaboration

- Shared design patterns
- Common command library
- Consistent AI behavior
- Team personas and configurations

### 5. Easy Onboarding

- New users ready in minutes
- Pre-configured environments
- Example projects included
- Automatic shell integration

## Migration from Single-User

To migrate existing single-user installation:

```bash
# As admin: Install multi-user system
sudo ./install/multi_user_setup.sh

# As user: Migrate personal config
dp migrate-to-multiuser

# This will:
# - Copy your settings to ~/.devpilot
# - Migrate your API keys (re-encrypt)
# - Preserve your personas and preferences
# - Update shell configuration
```

## Troubleshooting

### Common Issues

1. **Permission denied accessing /opt/devpilot**

   ```bash
   # Fix: Ensure proper permissions
   sudo chmod -R 755 /opt/devpilot
   ```

2. **User config not initializing**

   ```bash
   # Fix: Manually run init
   /opt/devpilot/lib/core/init_user.sh
   ```

3. **API keys not loading**

   ```bash
   # Check encryption status
   dp secure-keys status

   # Re-encrypt if needed
   dp secure-keys rotate
   ```

4. **Commands not found**

   ```bash
   # Add to PATH
   export PATH="/usr/local/bin:$PATH"

   # Or create symlink
   sudo ln -s /opt/devpilot/bin/dp /usr/local/bin/dp
   ```

### Getting Help

```bash
# Check system status
sudo dp-admin status

# Run diagnostics
dp doctor

# View logs
sudo tail -f /var/log/devpilot/system.log

# Get help
dp help
dp-admin help
```

## Best Practices

### For Administrators

1. **Regular Updates**

   - Schedule weekly updates: `sudo dp-admin update`
   - Review changelog before major updates
   - Test in staging environment first

2. **Monitor Usage**

   - Set up alerts for resource limits
   - Review audit logs regularly
   - Track user activity patterns

3. **Security**

   - Enforce API key encryption
   - Rotate system keys quarterly
   - Review and update allowed AI providers

4. **Backup**
   - Regular backups of `/opt/devpilot/etc/`
   - User data in `~/.devpilot/` (user responsibility)
   - Document custom configurations

### For Users

1. **Security**

   - Always encrypt API keys
   - Don't share keys between users
   - Use project-specific configurations

2. **Organization**

   - Keep workspace organized
   - Clean cache regularly: `rm -rf ~/.devpilot/cache/*`
   - Archive old artifacts

3. **Customization**
   - Create custom personas for your workflow
   - Define project-specific commands
   - Use aliases for common operations

## Comparison: Single vs Multi-User

| Feature               | Single-User       | Multi-User                                      |
| --------------------- | ----------------- | ----------------------------------------------- |
| Installation Location | `~/devpilot`      | `/opt/devpilot` (system) + `~/.devpilot` (user) |
| Installation Rights   | User              | Root/Admin                                      |
| Disk Usage            | ~500MB per user   | ~200MB shared + ~100MB per user                 |
| Updates               | Each user updates | Admin updates for all                           |
| API Keys              | In user directory | Encrypted in user directory                     |
| Resource Limits       | No                | Yes (configurable)                              |
| Audit Logging         | Optional          | Built-in                                        |
| Shared Resources      | No                | Yes (patterns, commands)                        |
| User Onboarding       | Full install      | Quick setup                                     |
| Maintenance           | Per-user          | Centralized                                     |

## Conclusion

The multi-user installation model is ideal for teams and shared environments, providing:

- Centralized management
- Enhanced security
- Resource efficiency
- Better collaboration
- Easier maintenance

For personal use or single developer machines, the standard single-user installation remains the
simpler option.

## See Also

- [Installation Guide](INSTALLATION.md)
- [Security Best Practices](SECURITY.md)
- [Admin Guide](ADMIN_GUIDE.md)
- [API Key Management](API_KEYS.md)
