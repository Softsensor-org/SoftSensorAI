# DevPilot - AI-Augmented Development Platform

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/yourusername/devpilot)
[![CI](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-WSL%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)](docs/platforms.md)

DevPilot is a modern, modular development environment orchestrator that seamlessly integrates AI coding assistants (Claude, Gemini, Grok, Codex) into your workflow. It provides automated setup, standardized project structures, and intelligent agent configurations with learning-aware profiles that adapt to your skill level.

## 🎯 Key Features

### Core Capabilities
- **🤖 Multi-Agent Integration**: Unified configuration for Claude, Gemini, Grok, and Codex
- **📈 Learning-Aware Profiles**: 5 skill levels (vibe → beginner → l1 → l2 → expert) with progressive tooling
- **🔄 Project Phase Management**: 4 phases (poc → mvp → beta → scale) with appropriate CI/CD gates
- **🔧 Automated Setup**: Platform-specific installation (WSL, Linux, macOS)
- **📁 Standardized Structure**: Consistent project organization with templates
- **🔒 Security First**: Built-in guardrails for secrets and sensitive data
- **📊 Insights & Auditing**: Code quality checks and system health monitoring
- **🚀 Smart Migration**: Seamless upgrade path from legacy setups

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/devpilot.git
cd devpilot

# Run bootstrap (auto-detects fresh install vs upgrade)
./devpilot-new/devpilot bootstrap

# Configure AI agents globally
./devpilot-new/devpilot pilot setup

# Create project structure
./devpilot-new/devpilot core folders

# Initialize a new project with AI agents
cd ~/projects/personal
./devpilot-new/devpilot project wizard
```

## 🏗️ Project Structure

### Current (Production) Structure
```
setup-scripts/
├── setup_all.sh                # Master setup orchestrator
├── setup/                      # Setup scripts
│   ├── agents_global.sh        # Global agent configuration
│   ├── agents_repo.sh          # Repository agent setup
│   ├── repo_wizard.sh          # Project initialization wizard
│   └── folders.sh              # Directory structure creation
├── install/                    # Platform installers
│   ├── key_software_wsl.sh     # WSL-specific tools
│   ├── key_software_linux.sh   # Linux tools
│   ├── key_software_macos.sh   # macOS tools
│   └── ai_clis.sh              # AI CLI installations
└── validation/                  # Testing and validation
    └── validate_agents.sh       # Agent configuration checker
```

### New (Migrated) Structure
```
devpilot-new/
├── core/                       # Core system components
│   ├── bootstrap.sh            # Main installer/upgrader
│   ├── config.sh               # Configuration management
│   ├── logger.sh               # Logging utilities
│   └── folders.sh              # Directory structure setup
├── onboard/                    # Onboarding and setup
│   ├── platforms/              # Platform-specific installers
│   │   ├── wsl.sh
│   │   ├── linux.sh
│   │   └── macos.sh
│   └── tools/                  # Tool installations
│       └── ai-clis.sh
├── pilot/                      # AI agent management
│   └── agents/
│       ├── setup.sh            # Global agent configuration
│       └── repo.sh             # Repository-specific setup
├── projects/                   # Project management
│   └── wizard.sh               # Interactive project creator
├── insights/                   # Analysis and monitoring
│   ├── audit.sh                # Code quality auditor
│   └── doctor.sh               # System health checker
├── skills/                     # Skill-based profiles
│   └── profiles.sh             # Learning-aware configurations
└── devpilot                    # Main CLI router
```

### Migration Framework
```
.migration/
├── scripts/                    # Migration utilities
│   ├── migrate-files.sh        # File migration executor
│   ├── compat-layer.sh         # Backward compatibility
│   ├── test-migration.sh       # Migration tests
│   └── rollback.sh             # Emergency rollback
├── transformations/            # Code transformations
│   ├── update_paths.sh         # Path updates
│   ├── add_logging.sh          # Logging additions
│   └── extract_common.sh       # Function extraction
└── state/                      # Migration state
    └── migration-map.json      # Source→destination mapping
```

## 📦 Installation

### Prerequisites
- **OS**: WSL 2, Ubuntu 20.04+, or macOS 11+
- **Shell**: Bash 4.0+
- **Tools**: Git, curl/wget
- **Optional**: Docker, Python 3.8+, Node.js 18+

### Bootstrap Installation

```bash
# Full installation with all components
./devpilot-new/devpilot bootstrap --fresh

# Upgrade existing installation
./devpilot-new/devpilot bootstrap --upgrade

# Dry run to preview changes
./devpilot-new/devpilot bootstrap --dry-run

# Platform-specific options
./devpilot-new/devpilot bootstrap --platform wsl
./devpilot-new/devpilot bootstrap --platform linux
./devpilot-new/devpilot bootstrap --platform macos
```

### Legacy Installation (Still Supported)

```bash
# Universal setup
./setup_all.sh

# Platform-specific
./install/key_software_wsl.sh    # WSL
./install/key_software_linux.sh  # Linux
./install/key_software_macos.sh  # macOS
```

## 🔄 Migration Guide

### From Legacy to DevPilot 2.0

```bash
# 1. Run migration executor
.migration/scripts/migrate-files.sh

# 2. Test the migration
.migration/scripts/test-migration.sh

# 3. Create compatibility wrappers (preview)
.migration/scripts/compat-layer.sh

# 4. Apply wrappers in-place
.migration/scripts/compat-layer.sh --in-place

# 5. Verify with canary deployment
.migration/scripts/canary.sh
```

### Rollback if Needed

```bash
# Rollback to latest checkpoint
.migration/scripts/rollback.sh latest

# Emergency rollback
.migration/scripts/rollback.sh --emergency
```

## 🎮 CLI Reference

### Core Commands
```bash
devpilot bootstrap      # Install/upgrade DevPilot
devpilot pilot setup    # Configure AI agents
devpilot project wizard # Create new project
devpilot core folders   # Setup directory structure
```

### Management Commands
```bash
devpilot insights audit    # Run code audit
devpilot insights doctor   # System health check
devpilot skills profile    # Manage skill profiles
devpilot pilot repo-setup  # Setup agents in repo
```

### Advanced Options
```bash
# Dry run mode
devpilot bootstrap --dry-run

# Force operations
devpilot pilot setup --force

# Skip components
devpilot bootstrap --skip-tools --skip-agents

# Custom configurations
devpilot core folders --orgs "acme corp" --personal "my-projects"
```

## 🔧 Configuration

### Environment Variables

```bash
# API Keys (add to ~/.bashrc or ~/.zshrc)
export ANTHROPIC_API_KEY='your-key'
export GEMINI_API_KEY='your-key'
export XAI_API_KEY='your-key'
export OPENAI_API_KEY='your-key'

# DevPilot Settings
export DEVPILOT_ORGS="acme corp startup"
export DEVPILOT_PERSONAL="personal"
export DEVPILOT_PROJECT_BASE="$HOME/projects"
export DEVPILOT_SKILL_LEVEL="l2"  # vibe|beginner|l1|l2|expert
export DEVPILOT_PROJECT_PHASE="mvp" # poc|mvp|beta|scale
```

### Configuration Files

#### Global Agent Settings
- `~/.claude/settings.json` - Claude global configuration
- `~/.gemini/settings.json` - Gemini settings
- `~/.grok/user-settings.json` - Grok configuration
- `~/.codex/config.yaml` - Codex settings
- `~/.devpilot/agents/registry.json` - Agent registry

#### Project-Specific
- `.claude/settings.json` - Project Claude settings
- `CLAUDE.md` - Repository guardrails
- `AGENTS.md` - Agent directives
- `.mcp.json` - MCP server configurations

## 🚨 Troubleshooting

### Common Issues

#### WSL PowerShell Hanging
DevPilot 2.0 avoids PowerShell calls that can hang in WSL. If using legacy scripts:
```bash
# Check for stuck processes
ps aux | grep powershell

# Kill stuck process
kill -9 <PID>
```

#### Permission Denied
```bash
# Make scripts executable
chmod +x devpilot-new/**/*.sh
chmod +x .migration/**/*.sh
chmod +x setup/**/*.sh
```

#### Missing Dependencies
```bash
# Run platform installer
devpilot bootstrap --platform <wsl|linux|macos> --force

# Or use legacy installer
./install/key_software_<platform>.sh
```

## 📚 Documentation

### Core Documentation
- [Architecture Guide](docs/architecture.md) - System design and components
- [Migration Guide](docs/migration.md) - Upgrading from legacy setup
- [CLI Reference](docs/cli-reference.md) - Complete command documentation

### Feature Guides
- [Agent Guide](docs/agents.md) - AI assistant configuration
- [Profiles Guide](docs/profiles.md) - Skill-based profiles
- [Platform Guide](docs/platforms.md) - OS-specific setup
- [Project Wizard](docs/repo-wizard.md) - Project initialization

### Advanced Topics
- [System Prompts](docs/system-prompts.md) - Prompt engineering
- [DevContainer](docs/devcontainer.md) - Container development
- [CI/CD Integration](docs/ci.md) - Continuous integration
- [Validation & Troubleshooting](docs/validation-troubleshooting.md)

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Claude (Anthropic) for AI assistance
- The open-source community for tools and inspiration
- All contributors and users

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/devpilot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/devpilot/discussions)
- **Wiki**: [Project Wiki](https://github.com/yourusername/devpilot/wiki)

---

**DevPilot** - Empowering developers with AI-augmented workflows 🚀

*Version 2.0.0 - The Learning-Aware Update*