# Changelog

All notable changes to SoftSensorAI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-08-31

### 🎉 Major Release - Complete Platform Redesign

This release transforms SoftSensorAI from a collection of setup scripts into a comprehensive AI
development platform with skill-based progression, project phase management, and enterprise
features.

### ✨ Added

#### Core Platform Features

- **Skill-Based Development Profiles** - 5 progressive skill levels (vibe → beginner → l1 → l2 →
  expert)
- **Project Phase Management** - Automatic configuration for POC, MVP, Beta, and Scale phases
- **Teaching Mode** - Interactive learning for beginners with guided workflows
- **Multi-Agent Support** - Unified setup for Claude, Gemini, Grok, and Codex
- **MCP (Model Context Protocol)** - Native integrations with GitHub, Atlassian, and custom servers

#### Developer Tools

- **Repository Wizard** - Interactive and non-interactive project setup with planning mode
- **Advanced Claude Commands** - 15+ pre-configured commands for analysis, security, and automation
- **Productivity Extras** - Comprehensive tooling for API, database, ML, K8s, and security work
- **Universal Task Runner** - `just` integration for consistent project commands
- **Runtime Management** - `mise` for managing Node, Python, Go, Rust versions

#### Project Organization

- **Structured Directory Layout** - `~/projects/org/category/repo` organization
- **Smart Dependency Detection** - Automatic installation of project dependencies
- **Git Hooks** - Commit sanitization and quality checks
- **Environment Management** - `direnv` with `.envrc` and `.envrc.local` patterns

#### Validation & Security

- **Comprehensive Validation** - `validate_agents.sh` with auto-fix capabilities
- **Security-First Defaults** - Granular permissions, secret detection, gitignore management
- **Audit Commands** - Full code audits, security reviews, and quality gates
- **Ticket Generation** - Automatic JIRA/GitHub issue creation from code analysis

### 🔄 Changed

#### Architecture

- **Modular Structure** - Reorganized into `install/`, `setup/`, `validation/`, `utils/` directories
- **Two-Tier Configuration** - Global (`~/.claude/`) and per-repository settings
- **Cross-Platform Support** - Unified installers for WSL, Linux, and macOS
- **Simplified Entry Point** - Single `setup_all.sh` with intelligent detection

#### Documentation

- **Comprehensive README** - Complete feature documentation with examples
- **Enhanced Quickstart** - Step-by-step guide with troubleshooting
- **Command Reference** - Full documentation of Claude commands
- **Profile Documentation** - Detailed skill and phase explanations

### 🗑️ Removed

- Duplicate scripts in root directory
- Redundant `key_software_wsl.sh` (consolidated with Linux installer)
- Migration-related code and documentation
- Empty directories (academy, insights, onboard, etc.)
- Legacy upgrade mode complexity

### 🔧 Fixed

- WSL PowerShell hanging issues
- Script path references
- JSON validation in configuration files
- Cross-platform compatibility issues

### 🚀 Performance

- Faster installation with parallel tool downloads
- Optimized validation with batch processing
- Reduced script duplication
- Cleaner directory structure

---

## [1.5.0] - 2024-08-15

### Added

- Initial skill level profiles (beginner, intermediate, advanced)
- Basic MCP server support
- Claude command templates
- Repository validation script

### Changed

- Improved agent configuration templates
- Enhanced error handling in setup scripts

### Fixed

- Permission issues in global setup
- Git hook installation errors

---

## [1.0.0] - 2024-07-01

### Added

- Initial release
- Basic setup scripts for WSL/Linux
- Claude, Gemini, Grok CLI installations
- Agent configuration templates
- Project folder structure creation

---

## Version History

| Version | Date       | Description                                 |
| ------- | ---------- | ------------------------------------------- |
| 2.0.0   | 2024-08-31 | Major platform redesign with skill profiles |
| 1.5.0   | 2024-08-15 | Added validation and MCP support            |
| 1.0.0   | 2024-07-01 | Initial release                             |

---

For detailed migration instructions from v1.x to v2.0, see [MIGRATION.md](docs/MIGRATION.md)
