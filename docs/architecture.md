# DevPilot Architecture Guide

## Table of Contents
- [Overview](#overview)
- [Design Principles](#design-principles)
- [System Architecture](#system-architecture)
- [Component Architecture](#component-architecture)
- [Data Flow](#data-flow)
- [Security Architecture](#security-architecture)
- [Extension Points](#extension-points)
- [Performance Considerations](#performance-considerations)

## Overview

DevPilot 2.0 is built on a modular, domain-driven architecture that separates concerns while maintaining cohesion. The system is designed to be extensible, maintainable, and platform-agnostic.

### Architectural Goals

1. **Modularity**: Clear separation of concerns with well-defined interfaces
2. **Extensibility**: Easy to add new features without modifying core
3. **Maintainability**: Self-documenting structure with consistent patterns
4. **Portability**: Platform-agnostic with platform-specific adapters
5. **Safety**: Non-destructive operations with rollback capability
6. **Performance**: Lazy loading and parallel execution where possible

## Design Principles

### 1. Domain-Driven Design
Components are organized by business domain rather than technical layers:
- **Core**: Essential system functionality
- **Pilot**: AI agent management
- **Projects**: Project lifecycle management
- **Insights**: Analysis and monitoring
- **Skills**: User capability profiles
- **Onboard**: Platform setup and tooling

### 2. Convention over Configuration
- Predictable directory structures
- Standardized naming conventions
- Sensible defaults with override capability

### 3. Progressive Enhancement
- Start with minimal viable functionality
- Layer additional features based on skill level
- Graceful degradation when features unavailable

### 4. Fail-Safe Operations
- All operations are non-destructive by default
- Explicit confirmation for destructive operations
- Checkpoint and rollback mechanisms

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        CLI Interface                         │
│                    (devpilot router)                        │
└─────────────┬───────────────────────────────────┬───────────┘
              │                                   │
              ▼                                   ▼
┌──────────────────────────┐       ┌──────────────────────────┐
│      Core Domain         │       │     Feature Domains       │
│  ┌──────────────────┐    │       │  ┌──────────────────┐    │
│  │   Bootstrap      │    │       │  │      Pilot       │    │
│  ├──────────────────┤    │       │  ├──────────────────┤    │
│  │   Configuration  │    │       │  │    Projects      │    │
│  ├──────────────────┤    │       │  ├──────────────────┤    │
│  │     Logger       │    │       │  │    Insights      │    │
│  ├──────────────────┤    │       │  ├──────────────────┤    │
│  │     Folders      │    │       │  │     Skills       │    │
│  └──────────────────┘    │       │  ├──────────────────┤    │
│                          │       │  │     Onboard      │    │
└──────────────────────────┘       │  └──────────────────┘    │
              │                     └──────────────────────────┘
              │                                   │
              ▼                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Platform Adapters                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │    WSL     │  │   Linux    │  │   macOS    │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
              │                                   │
              ▼                                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Systems                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │  AI APIs   │  │   GitHub   │  │    MCP     │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## Component Architecture

### Core Domain (`core/`)

The foundational layer providing essential services:

```
core/
├── bootstrap.sh    # System initialization and upgrade
├── config.sh       # Configuration management
├── logger.sh       # Logging utilities
├── folders.sh      # Directory structure management
└── utils.sh        # Common utilities (future)
```

#### Bootstrap Component
- **Purpose**: Orchestrate system installation and upgrades
- **Responsibilities**:
  - Platform detection
  - Mode detection (fresh vs upgrade)
  - Component coordination
  - State management

#### Configuration Component
- **Purpose**: Centralized configuration management
- **Responsibilities**:
  - Environment variable management
  - Configuration file parsing
  - Default value provision
  - Configuration validation

#### Logger Component
- **Purpose**: Consistent logging across all components
- **Features**:
  - Color-coded output
  - Log levels (INFO, WARN, ERROR, DEBUG)
  - File logging capability
  - Structured log format

### Pilot Domain (`pilot/`)

AI agent management and configuration:

```
pilot/
└── agents/
    ├── setup.sh     # Global agent configuration
    ├── repo.sh      # Repository-specific setup
    └── registry.sh  # Agent registry management
```

#### Agent Setup
- **Purpose**: Configure AI assistants globally
- **Managed Agents**:
  - Claude (Anthropic)
  - Gemini (Google)
  - Grok (xAI)
  - Codex (OpenAI)

#### Agent Registry
- **Purpose**: Track installed agents and versions
- **Features**:
  - Agent discovery
  - Version tracking
  - Configuration mapping
  - Status monitoring

### Projects Domain (`projects/`)

Project lifecycle and management:

```
projects/
├── wizard.sh        # Interactive project creator
├── templates/       # Project templates
└── init.sh          # Project initialization
```

#### Project Wizard
- **Purpose**: Guide users through project setup
- **Features**:
  - Interactive and non-interactive modes
  - Template selection
  - Agent configuration
  - Git integration

### Insights Domain (`insights/`)

Analysis, monitoring, and diagnostics:

```
insights/
├── audit.sh         # Code quality auditor
├── doctor.sh        # System health checker
└── metrics.sh       # Usage metrics collector
```

#### Audit Component
- **Purpose**: Analyze code quality and compliance
- **Checks**:
  - Agent configurations
  - Security vulnerabilities
  - Code standards
  - Dependencies

#### Doctor Component
- **Purpose**: Diagnose system issues
- **Diagnostics**:
  - Tool availability
  - Configuration validity
  - Permission checks
  - Network connectivity

### Skills Domain (`skills/`)

User capability profiling and progression:

```
skills/
├── profiles.sh      # Skill profile management
└── progression.sh   # Skill advancement tracking
```

#### Skill Profiles
- **Levels**:
  1. **Vibe**: Exploration mode
  2. **Beginner**: Learning basics
  3. **L1**: Junior developer
  4. **L2**: Mid-level developer
  5. **Expert**: Senior developer

### Onboard Domain (`onboard/`)

Platform setup and tool installation:

```
onboard/
├── platforms/       # Platform-specific installers
│   ├── wsl.sh
│   ├── linux.sh
│   └── macos.sh
└── tools/           # Tool installations
    ├── ai-clis.sh
    └── dev-tools.sh
```

## Data Flow

### Installation Flow

```
User Input → CLI Router → Bootstrap
                ↓
        Platform Detection
                ↓
        Mode Detection
                ↓
    ┌───────────┴───────────┐
    ▼                       ▼
Fresh Install           Upgrade
    │                       │
    ├─ Create Folders       ├─ Backup Configs
    ├─ Install Tools        ├─ Update Tools
    ├─ Setup Agents         ├─ Update Agents
    └─ Save State           └─ Save State
```

### Configuration Flow

```
Environment Variables
        ↓
Configuration Files → Config Manager → Component
        ↓                               ↑
Default Values ─────────────────────────┘
```

### Agent Setup Flow

```
Global Config → Template Generation → Project Config
                        ↓
                  Agent Registry
                        ↓
                  MCP Servers
```

## Security Architecture

### Principle of Least Privilege

Each component operates with minimal required permissions:

1. **Read-only by default**: Components start in read-only mode
2. **Explicit elevation**: Write operations require confirmation
3. **Scoped permissions**: Agent permissions are context-specific

### Secret Management

```
┌─────────────────────────────────────┐
│         Never Stored in:            │
│  - Source code                      │
│  - Configuration files              │
│  - Logs                            │
└─────────────────────────────────────┘
            ↓
┌─────────────────────────────────────┐
│         Stored Only in:             │
│  - Environment variables            │
│  - Secure credential stores         │
│  - User-specific .env files         │
└─────────────────────────────────────┘
```

### Guardrails

Built-in protections against common issues:

1. **Path Traversal**: Validated paths, no arbitrary file access
2. **Command Injection**: Quoted parameters, validated inputs
3. **Secret Exposure**: Redaction in logs, deny patterns
4. **Destructive Operations**: Explicit confirmation required

## Extension Points

### Adding New Platforms

1. Create platform script in `onboard/platforms/`
2. Implement required functions:
   - `detect_platform()`
   - `install_base_tools()`
   - `configure_platform()`
3. Update bootstrap platform detection

### Adding New AI Agents

1. Add configuration in `pilot/agents/setup.sh`
2. Update agent registry schema
3. Create template configuration
4. Add to documentation

### Adding New Commands

1. Create script in appropriate domain
2. Add routing in main `devpilot` script
3. Implement help text
4. Add to CLI reference

### Custom Skill Profiles

1. Define profile in `skills/profiles.sh`
2. Set tool allowlist
3. Configure guardrails
4. Document progression path

## Performance Considerations

### Lazy Loading

Components are loaded only when needed:

```bash
# Logger loaded only if logging needed
[[ -f "$DEVPILOT_HOME/core/logger.sh" ]] && source "$DEVPILOT_HOME/core/logger.sh"
```

### Parallel Execution

Operations that can run concurrently:

```bash
# Parallel tool checks
{
    check_tool "git" &
    check_tool "curl" &
    check_tool "jq" &
    wait
}
```

### Caching

Frequently accessed data is cached:

- Platform detection result
- Agent installation status
- Configuration values

### Optimization Strategies

1. **Minimize subprocess spawning**: Use built-ins where possible
2. **Batch operations**: Group related operations
3. **Early termination**: Fail fast on critical errors
4. **Conditional execution**: Skip unnecessary operations

## Best Practices

### Component Development

1. **Single Responsibility**: Each component does one thing well
2. **Clear Interfaces**: Well-defined inputs and outputs
3. **Error Handling**: Graceful failure with informative messages
4. **Documentation**: Self-documenting code with clear comments
5. **Testing**: Include test cases for critical paths

### Script Standards

```bash
#!/usr/bin/env bash
set -euo pipefail  # Strict mode

# Header comment explaining purpose
# Source dependencies
# Define functions
# Main execution
# Handle cleanup
```

### Naming Conventions

- **Scripts**: `lowercase-with-dashes.sh`
- **Functions**: `snake_case()`
- **Variables**: `UPPER_CASE` for globals, `lower_case` for locals
- **Directories**: `lowercase` for domains

## Future Enhancements

### Planned Features

1. **Plugin System**: Dynamic loading of third-party extensions
2. **Remote Configuration**: Centralized configuration management
3. **Telemetry**: Optional usage analytics
4. **Update System**: Self-updating capability
5. **GUI Interface**: Web-based configuration UI

### Architecture Evolution

1. **Microservices**: Decompose into smaller services
2. **API Layer**: RESTful API for programmatic access
3. **Event System**: Pub/sub for component communication
4. **State Machine**: Formal state management
5. **Dependency Injection**: Improved testability

---

*Architecture guide for DevPilot 2.0 - Building a sustainable AI-augmented development platform*