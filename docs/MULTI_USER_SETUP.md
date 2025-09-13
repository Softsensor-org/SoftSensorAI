# SoftSensorAI Multi-User Installation Guide

## Overview

SoftSensorAI supports two installation models:

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
│  /opt/softsensorai/                                      │
│  ├── bin/           # Shared binaries (read-only)    │
│  ├── lib/           # Core libraries & scripts       │
│  ├── share/         # Shared resources               │
│  │   ├── patterns/  # Design patterns                │
│  │   ├── commands/  # System commands                │
│  │   └── personas/  # Default personas               │
│  └── etc/           # System configuration           │
│      └── softsensorai.conf                               │
└──────────────────────────────────────────────────────┘
                           ↓
                    Shared by all users
                           ↓
┌──────────────────────────────────────────────────────┐
│                   User Level (Personal)               │
├──────────────────────────────────────────────────────┤
│  ~/.softsensorai/                                        │
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
sudo curl -L https://github.com/Softsensor-org/SoftSensorAI/raw/main/install/multi_user_setup.sh | sudo bash

# Or clone and run locally
git clone https://github.com/Softsensor-org/SoftSensorAI.git
cd SoftSensorAI
sudo ./install/multi_user_setup.sh
```

This will:

- Install system dependencies (git, jq, ripgrep, fd, direnv)
- Create `/opt/softsensorai` directory structure
- Install SoftSensorAI core components
- Set up system-wide configuration
- Create admin utilities (`ssai-admin`)
- Configure logging and auditing

### Step 2: User Setup (Run as Regular User)

Each user runs their personal setup:

```bash
# Run user setup script
curl -L https://github.com/Softsensor-org/SoftSensorAI/raw/main/install/user_setup.sh | bash

# Or if SoftSensorAI is already installed system-wide
ssai setup-user
```

This will:

- Create `~/.softsensorai` directory structure
- Configure personal settings (skill level, phase, AI provider)
- Set up API keys template
- Create personal personas
- Add shell integration (aliases)
- Create example workspace

### Step 3: Configure API Keys

Each user must configure their personal API keys:

```bash
# Edit API keys file
vi ~/.softsensorai/config/api_keys.env

# Add your keys:
ANTHROPIC_API_KEY="sk-ant-..."
OPENAI_API_KEY="sk-..."
GITHUB_TOKEN="ghp_..."

# Encrypt the keys for security
ssai secure-keys encrypt
```

## Security Features

### 1. API Key Encryption

Three encryption methods supported:

- **GPG** (recommended) - Uses user's GPG key
- **OpenSSL** - Password-based AES-256 encryption
- **Age** - Modern, simple encryption tool

```bash
# Encrypt keys
ssai secure-keys encrypt

# Decrypt keys (when needed)
ssai secure-keys decrypt

# Check security status
ssai secure-keys status

# Rotate encryption
ssai secure-keys rotate
```

### 2. Resource Limits

Per-user limits configured in `/opt/softsensorai/etc/softsensorai.conf`:

```bash
SOFTSENSORAI_MAX_ARTIFACTS_MB=1000    # Max artifacts storage
SOFTSENSORAI_MAX_CACHE_MB=500         # Max cache size
SOFTSENSORAI_MAX_CONCURRENT_AGENTS=3  # Max parallel agents
```

### 3. Sandboxing

All AI-generated code runs in sandboxed environment:

- Network isolation
- Filesystem restrictions
- Resource limits (CPU, memory)
- Timeout protection

### 4. Audit Logging

All operations logged to `/var/log/softsensorai/`:

- User actions
- AI interactions
- Resource usage
- Security events

## Administration

### Admin Commands

System administrators can use `ssai-admin`:

```bash
# List all SoftSensorAI users
sudo ssai-admin list-users

# Show usage statistics
sudo ssai-admin stats

# Clean all user caches
sudo ssai-admin clean-cache

# Update SoftSensorAI system-wide
sudo ssai-admin update

# Monitor real-time usage
sudo ssai-admin monitor
```

### User Management

```bash
# Add new user (creates user directory)
sudo ssai-admin add-user username

# Remove user (preserves data, disables access)
sudo ssai-admin disable-user username

# Set user limits
sudo ssai-admin set-limits username --artifacts 2000 --cache 1000
```

### Monitoring

View logs and usage:

```bash
# System logs
sudo tail -f /var/log/softsensorai/system.log

# User activity
sudo grep username /var/log/softsensorai/access.log

# Resource usage
sudo ssai-admin stats --detailed
```

## Configuration

### System Configuration

Edit `/opt/softsensorai/etc/softsensorai.conf`:

```bash
# Installation paths
SOFTSENSORAI_ROOT="/opt/softsensorai"
SOFTSENSORAI_USER_DIR="$HOME/.softsensorai"

# Features
SOFTSENSORAI_MULTI_USER=true
SOFTSENSORAI_SANDBOX_ENABLED=true
SOFTSENSORAI_AUDIT_ENABLED=true

# Resource limits
SOFTSENSORAI_MAX_ARTIFACTS_MB=1000
SOFTSENSORAI_MAX_CACHE_MB=500
SOFTSENSORAI_MAX_CONCURRENT_AGENTS=3

# Security
SOFTSENSORAI_REQUIRE_ENCRYPTION=false  # Set true to enforce key encryption
SOFTSENSORAI_ALLOWED_AI_PROVIDERS="anthropic,openai,google,grok"
```

### User Configuration

Each user's `~/.softsensorai/config/settings.json`:

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
- Easy updates via `ssai-admin update`
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
ssai migrate-to-multiuser

# This will:
# - Copy your settings to ~/.softsensorai
# - Migrate your API keys (re-encrypt)
# - Preserve your personas and preferences
# - Update shell configuration
```

## Troubleshooting

### Common Issues

1. **Permission denied accessing /opt/softsensorai**

   ```bash
   # Fix: Ensure proper permissions
   sudo chmod -R 755 /opt/softsensorai
   ```

2. **User config not initializing**

   ```bash
   # Fix: Manually run init
   /opt/softsensorai/lib/core/init_user.sh
   ```

3. **API keys not loading**

   ```bash
   # Check encryption status
   ssai secure-keys status

   # Re-encrypt if needed
   ssai secure-keys rotate
   ```

4. **Commands not found**

   ```bash
   # Add to PATH
   export PATH="/usr/local/bin:$PATH"

   # Or create symlink
   sudo ln -s /opt/softsensorai/bin/ssai /usr/local/bin/ssai
   ```

### Getting Help

```bash
# Check system status
sudo ssai-admin status

# Run diagnostics
ssai doctor

# View logs
sudo tail -f /var/log/softsensorai/system.log

# Get help
ssai help
ssai-admin help
```

## Best Practices

### For Administrators

1. **Regular Updates**

   - Schedule weekly updates: `sudo ssai-admin update`
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
   - Regular backups of `/opt/softsensorai/etc/`
   - User data in `~/.softsensorai/` (user responsibility)
   - Document custom configurations

### For Users

1. **Security**

   - Always encrypt API keys
   - Don't share keys between users
   - Use project-specific configurations

2. **Organization**

   - Keep workspace organized
   - Clean cache regularly: `rm -rf ~/.softsensorai/cache/*`
   - Archive old artifacts

3. **Customization**
   - Create custom personas for your workflow
   - Define project-specific commands
   - Use aliases for common operations

## Comparison: Single vs Multi-User

| Feature               | Single-User       | Multi-User                                      |
| --------------------- | ----------------- | ----------------------------------------------- |
| Installation Location | `~/softsensorai`      | `/opt/softsensorai` (system) + `~/.softsensorai` (user) |
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
