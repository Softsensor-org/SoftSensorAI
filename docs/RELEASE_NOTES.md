# SoftSensorAI v2.0.0 Release Notes

**Release Date:** August 31, 2024 **Type:** Major Release **Breaking Changes:** Yes (see Migration
section)

## 🚀 Highlights

SoftSensorAI 2.0 is a complete reimagining of the platform, transforming it from a collection of
setup scripts into a comprehensive AI development environment that adapts to your skill level and
project needs.

### Key Features

- **🎓 Skill-Based Progression**: Start as a beginner with teaching mode, progress through L1/L2,
  unlock expert features
- **📈 Project Phase Management**: Automatic CI/CD and tooling based on POC → MVP → Beta → Scale
  lifecycle
- **🤖 Multi-Agent Platform**: Unified configuration for Claude, Gemini, Grok, and Codex
- **🔌 MCP Integrations**: Native GitHub and Atlassian connections
- **📦 Smart Project Setup**: Interactive wizard with dependency detection and profile application

## 📊 By the Numbers

- **5** Skill levels for progressive learning
- **4** Project phases with automatic configuration
- **15+** Pre-configured Claude commands
- **50+** Development tools available
- **100%** Cross-platform support (WSL, Linux, macOS)

## 🎯 Major Improvements

### For Beginners

- Teaching mode with guided workflows
- Safety rails to prevent mistakes
- Progressive skill unlocking
- Comprehensive documentation

### For Teams

- Standardized project structure
- Consistent tooling across projects
- Validation and audit capabilities
- Ticket generation from code

### For Experts

- Advanced Claude commands
- Custom MCP server support
- Full productivity extras suite
- Unrestricted tool access

## 💡 Quick Start

```bash
# Install SoftSensorAI
git clone https://github.com/Softsensor-org/SoftSensorAI.git ~/devpilot
cd ~/devpilot
./setup_all.sh

# Create your first project
./setup/repo_wizard.sh
```

## 🔄 Migration from v1.x

### Breaking Changes

1. **Directory Structure**: Scripts reorganized into subdirectories
2. **Removed Scripts**: `key_software_wsl.sh` consolidated into `key_software_linux.sh`
3. **Configuration**: New two-tier global + repo system

### Migration Steps

```bash
# 1. Backup existing setup
cp -r ~/.claude ~/.claude.backup
cp -r ~/.gemini ~/.gemini.backup

# 2. Install SoftSensorAI 2.0
cd ~/devpilot
git pull origin main
./setup_all.sh

# 3. Update existing projects
cd your-project
~/devpilot/setup/agents_repo.sh --force
```

## 📋 Complete Feature List

### Core Platform

- ✅ 5 skill levels with progressive features
- ✅ 4 project phases with automatic configuration
- ✅ Teaching mode for beginners
- ✅ Multi-agent support (Claude, Gemini, Grok, Codex)
- ✅ MCP server integrations
- ✅ Global + per-repository configuration

### Developer Tools

- ✅ Interactive repository wizard
- ✅ Planning/preview mode
- ✅ Automatic dependency installation
- ✅ Git hooks for quality
- ✅ Environment variable management
- ✅ Universal task runner (just)
- ✅ Runtime version management (mise)

### Claude Commands

- ✅ `/think-hard` - Deep reasoning
- ✅ `/security-review` - Vulnerability scanning
- ✅ `/audit-full` - Comprehensive review
- ✅ `/tickets-from-code` - Issue generation
- ✅ `/explore-plan-code-test` - Full cycle
- ✅ 10+ additional specialized commands

### Productivity Extras

- ✅ API development tools
- ✅ Database utilities
- ✅ ML/Data science tools
- ✅ Kubernetes development
- ✅ Security scanners
- ✅ Code quality tools

### Project Organization

- ✅ Structured directory layout
- ✅ Category-based organization
- ✅ Workspace management
- ✅ Template system

## 🐛 Bug Fixes

- Fixed WSL PowerShell hanging issues
- Resolved path references in scripts
- Corrected JSON validation errors
- Fixed cross-platform compatibility

## 📈 Performance Improvements

- 50% faster installation with parallel downloads
- Reduced script duplication
- Optimized validation processing
- Cleaner directory structure

## 🔐 Security Enhancements

- Secure-by-default permissions
- Automatic secret detection
- Enhanced gitignore patterns
- Environment isolation with `.envrc.local`

## 📚 Documentation

- Complete README rewrite
- Enhanced quickstart guide
- Command reference documentation
- Troubleshooting guides
- Profile explanations

## 🙏 Acknowledgments

Thanks to all contributors and users who provided feedback for this major release.

## 📝 Known Issues

- Some MCP servers require manual configuration
- Teaching mode prompts may be verbose for experienced users
- Profile switching requires repository re-initialization

## 🔮 What's Next

- v2.1: Enhanced MCP server library
- v2.2: Cloud development environments
- v2.3: Team collaboration features
- v3.0: AI model fine-tuning support

## 📞 Support

- **Issues**: https://github.com/Softsensor-org/SoftSensorAI/issues
- **Documentation**: See `/docs` directory
- **Validation**: Run `./validation/validate_agents.sh`

---

**Upgrade Today!** SoftSensorAI 2.0 is the most significant update yet, designed to grow with you
from your first line of code to architecting complex systems.
