# SoftSensorAI v0.1.0 Release Notes

**Release Date:** September 12, 2025  
**License:** GNU General Public License v3.0 (GPL-3.0-only)

## 🎉 Initial Open Source Release

We're excited to announce the first open-source release of SoftSensorAI! This marks the transition from proprietary software to a fully GPL-3.0 licensed development automation framework.

## ✨ What's New

### 🔧 Core Features
- **Intelligent Setup Automation** - Streamlined project initialization and environment setup
- **Contract-Driven Development** - Structured workflow management with acceptance criteria
- **Phase-Aware CI/CD** - Adaptive quality gates for prototype, beta, and scale phases
- **Multi-Stack Support** - Comprehensive tooling for various technology stacks

### 📋 Contract System
- **APC-CORE**: Foundation contract system with YAML front-matter
- **APC-ENFORCER**: CI-based contract scope and hash verification
- **APC-VIBE**: Exploration workflow for rapid prototyping
- **APC-AGENT**: AI-powered development assistance integration
- **APC-BUDGETS**: Performance budgets and telemetry tracking

### 🛠 Developer Tools
- **Command Registry**: Centralized command documentation and validation
- **Profile Management**: Configurable development personas and workflows
- **Brand Compatibility**: Legacy → SoftSensorAI migration support
- **OS Compatibility**: Cross-platform support (Linux, macOS, Windows/WSL)

### 🔒 Security & Compliance
- **License Compliance**: Full GPL-3.0 implementation with SPDX headers
- **Security Scanning**: Integrated vulnerability detection and analysis
- **Secret Management**: Automated secret detection and secure handling
- **Dependency Auditing**: Supply chain security validation

## 📊 Project Statistics

- **Source Files**: 97 files with SPDX headers
- **Test Coverage**: Contract-based testing framework
- **CI Workflows**: 15+ GitHub Actions workflows
- **Commands**: 50+ documented development commands
- **Scripts**: 80+ automation and utility scripts

## 🚀 Getting Started

### Quick Installation
```bash
git clone https://github.com/Softsensor-org/SoftSensorAI.git
cd SoftSensorAI
./setup_all.sh
```

### Contract Workflow
```bash
# Initialize new contract
./bin/dp contract create MY-FEATURE

# Validate contract compliance  
npm run contracts:validate

# Run contract tests
npm run test:contracts
```

### Phase Management
```bash
# Check current phase
./bin/dp phase status

# Graduate to next phase
./bin/dp graduate beta
```

## 📖 Documentation

- **Command Palette**: See [COMMAND_PALETTE.md](COMMAND_PALETTE.md) for all available commands
- **Quick Reference**: See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for common workflows
- **Contract Guide**: See [docs/contracts.md](docs/contracts.md) for contract-driven development
- **Vibe Lane**: See [docs/vibe-lane.md](docs/vibe-lane.md) for exploration workflows

## 🔄 Migration from Legacy Systems

Existing legacy users can migrate seamlessly:

```bash
./scripts/migrate_legacy_to_softsensorai.sh
```

This will:
- Update configuration paths and environment variables
- Migrate existing contracts and profiles
- Preserve custom configurations and data

## 🛡️ License & Compliance

**Important**: This software is now released under the GNU General Public License v3.0 (GPL-3.0-only).

- All source files include proper SPDX license identifiers
- Complete license text available in [LICENSE](LICENSE)
- Copyright notices preserved in all copies
- Corresponding source code provided with all distributions

If you share or modify this software, you must:
- Keep copyright and license notices intact
- Provide the license text to recipients
- Make corresponding source code available under the same terms

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for:
- Code style and conventions
- Testing requirements
- Contract-driven development workflow
- Security and license compliance

## 🐛 Known Issues

- Some legacy system references may remain in older configurations
- Contract validation requires Node.js environment
- Phase graduation requires manual approval for production deployment

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Softsensor-org/SoftSensorAI/issues)
- **Documentation**: [Project Wiki](https://github.com/Softsensor-org/SoftSensorAI/wiki)
- **License Questions**: See [LICENSE](LICENSE) or contact legal@softsensor.ai

## 🙏 Acknowledgments

Special thanks to:
- The open-source community for inspiring this release
- Claude Code for development assistance
- All beta testers and early adopters

---

**Full Changelog**: [Compare changes](https://github.com/Softsensor-org/SoftSensorAI/commits/v0.1.0)

## Post-Release Social Media Copy

> **🎉 SoftSensorAI v0.1.0 is now open source!**
> 
> We're excited to release our intelligent development environment automation framework under GPL-3.0. Features include contract-driven development, phase-aware CI/CD, and comprehensive tooling for modern software engineering.
> 
> **License**: The code in SoftSensorAI is released under the **GNU General Public License v3.0 (GPL-3.0-only)**. If you share or modify it, please keep notices intact and provide the license text and corresponding source to recipients under the same terms. No warranty is provided. See `LICENSE` in the repo.
> 
> ⭐ Star us on GitHub: https://github.com/Softsensor-org/SoftSensorAI
> 
> #OpenSource #GPL3 #DevTools #SoftwareEngineering #Automation

*This is not legal advice.*