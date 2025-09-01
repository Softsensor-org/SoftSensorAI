# Changelog

All notable changes to DevPilot will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2024-08-31

### 🎉 Major Release - The Learning-Aware Update

This release introduces DevPilot 2.0, a complete architectural overhaul with domain-driven design, improved modularity, and comprehensive migration tooling.

### ✨ Added
- **New Architecture**: Complete domain-driven restructure (`devpilot-new/`)
  - `core/` - Bootstrap, configuration, logging, folder management
  - `pilot/` - AI agent management with enhanced configurations
  - `projects/` - Project lifecycle management
  - `insights/` - Analysis and monitoring tools
  - `onboard/` - Platform-specific installers
  - `skills/` - Learning-aware skill profiles

- **Migration Framework** (`.migration/`)
  - Automated file migration executor
  - Compatibility layer with wrapper generation
  - Transformation scripts for code updates
  - Checkpoint-based rollback system
  - Canary deployment support
  - Comprehensive migration testing

- **Enhanced Components**
  - Modern bootstrap system with fresh/upgrade detection
  - Advanced logger with color coding and multiple levels
  - Improved agent setup with registry and MCP support
  - Platform-specific installers without PowerShell dependencies
  - Standardized folder structure creation

### 🔧 Fixed
- **WSL PowerShell Hanging**: Eliminated all PowerShell calls that could hang in WSL
- **Path Dependencies**: Resolved all hardcoded path issues
- **Error Handling**: Added comprehensive error handling throughout
- **Logging**: Consistent logging across all components

### 📈 Improved
- **Modularity**: Clear separation of concerns with domain boundaries
- **Maintainability**: Self-documenting structure with consistent patterns
- **Extensibility**: Easy to add new features without core modifications
- **Performance**: Lazy loading and parallel execution where applicable
- **Safety**: Non-destructive operations with rollback capability

### 📚 Documentation
- Complete README overhaul with new architecture
- Comprehensive migration guide with step-by-step instructions
- Detailed architecture documentation with diagrams
- CLI reference documentation (in progress)
- Quick start guide (in progress)

### 🔄 Migration
- Backward compatibility through wrapper scripts
- Parallel installation (old and new coexist)
- Safe, incremental migration path
- Automated testing and validation
- Emergency rollback procedures

## [1.3.0] - 2024-08-31

### 📚 Documentation
- Added comprehensive architecture analysis documenting current state
- Created DevPilot OS redesign proposal with clean single-entry architecture
- Developed detailed 10-day phased migration plan with zero-downtime approach
- Added complete migration checklist with task tracking
- Created comprehensive rollback procedures with automation scripts

### 🔧 Fixed
- Minor fix to repo_wizard.sh for planning mode functionality

## [1.2.0] - 2024-08-30

### ✨ Features
- Added root-level wrapper scripts for backward compatibility
- Maintained all existing command paths while using new structure

### 🔧 Fixed
- Fixed broken references after reorganization
- Resolved validation script issues
- Updated Makefile with proper test targets

## [1.1.0] - 2024-08-30

### ✨ Features
- Added planning/preview functionality to repository wizard
- Introduced --plan-only flag for dry-run preview
- Added --base flag for custom directory locations
- Implemented --yes flag for auto-confirmation
- Created standalone repo_plan.sh for pure planning

### 🔄 Changes
- Reorganized scripts into categorical directory structure
- Moved 15+ root scripts into organized subdirectories
- Updated all path references in key files

## [1.0.0] - 2024-08-29

### 🎉 Major Release
- Official DevPilot platform launch
- Rebranded from setup-scripts to DevPilot
- Converted to proprietary license for Softsensor.AI

### ✨ Features
- Production-ready AI development platform
- Complete platform stability
- Enterprise-ready features

## [0.7.0] - 2024-08-28

### ✨ Features
- Added mise runtime management for consistent environments
- Enhanced validation across all components
- Improved cross-platform installer compatibility
- Added comprehensive doctor diagnostic script
- Integrated devcontainer support
- Created extensive command catalog

### 🔧 Fixed
- Comprehensive syntax and configuration fixes
- Resolved installer permission issues
- Fixed cross-platform compatibility bugs

## [0.6.0] - 2024-08-27

### ✨ Features
- Introduced learning-aware platform with progressive skill levels
- Added 5-tier skill progression (vibe → beginner → l1 → l2 → expert)
- Implemented system prompt layering architecture
- Added extended thinking controls with reasoning budgets
- Created comprehensive documentation structure
- Added structured audit system with XML tags
- Integrated ticket generation from code analysis

### 📚 Documentation
- Added developer checklist for Claude integration
- Created comprehensive command documentation
- Documented Anthropic best practices

## [0.5.0] - 2024-08-26

### ✨ Features
- Implemented structured chain commands for multi-step workflows
- Added comprehensive design patterns library
- Created prompt registry system
- Enhanced chain patterns with self-correction
- Added parallelization support for chains
- Expanded domain coverage

## [0.4.0] - 2024-08-25

### ✨ Features
- Added prompt engineering suite with best practices
- Integrated Anthropic best practices for Claude
- Added OpenAI Codex CLI for automated fixes
- Implemented security enhancements
- Added prompt auditing capabilities

## [0.3.0] - 2024-08-24

### ✨ Features
- Major production readiness enhancements
- Added productivity extras installer
- Implemented justfile template for task automation
- Added devcontainer configuration
- Integrated MCP (Model Context Protocol)
- Created comprehensive mise setup

### 📚 Documentation
- Added complete productivity suite documentation
- Created MCP integration guide

## [0.2.0] - 2024-08-23

### 🔧 Infrastructure
- Added CI workflow with GitHub Actions
- Integrated pre-commit hooks
- Created audit scripts for code quality
- Added Makefile for development automation
- Implemented CI and pre-commit badges

### 📚 Documentation
- Added Repo Audit & CI section
- Created PR template

## [0.1.0] - 2024-08-22

### 🎉 Initial Release
- Initial WSL & AI Agent setup scripts
- Basic repository structure
- Core installation functionality
- Platform-specific installers (WSL, Linux, macOS)
- Agent configuration scripts
- Repository wizard for project setup

## Version History Summary

| Version | Release Date | Type | Major Changes |
|---------|--------------|------|---------------|
| 1.3.0 | 2024-08-31 | Stable | Documentation & Planning |
| 1.2.0 | 2024-08-30 | Stable | Backward Compatibility |
| 1.1.0 | 2024-08-30 | Stable | Planning & Preview |
| 1.0.0 | 2024-08-29 | Stable | DevPilot Launch |
| 0.7.0 | 2024-08-28 | RC | Enhanced Validation |
| 0.6.0 | 2024-08-27 | RC | Learning Platform |
| 0.5.0 | 2024-08-26 | Beta | Chain Commands |
| 0.4.0 | 2024-08-25 | Beta | AI Enhancement |
| 0.3.0 | 2024-08-24 | Beta | Production Ready |
| 0.2.0 | 2024-08-23 | Alpha | CI/CD Integration |
| 0.1.0 | 2024-08-22 | Alpha | Foundation |

---

[Unreleased]: https://github.com/Softsensor-org/DevPilot/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/Softsensor-org/DevPilot/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/Softsensor-org/DevPilot/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/Softsensor-org/DevPilot/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Softsensor-org/DevPilot/compare/v0.7.0...v1.0.0
[0.7.0]: https://github.com/Softsensor-org/DevPilot/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/Softsensor-org/DevPilot/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/Softsensor-org/DevPilot/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/Softsensor-org/DevPilot/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/Softsensor-org/DevPilot/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/Softsensor-org/DevPilot/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Softsensor-org/DevPilot/releases/tag/v0.1.0