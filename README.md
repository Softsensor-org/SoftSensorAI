# DevPilot - AI Development Platform
[![CI](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://pre-commit.com/)

**DevPilot** is a learning-aware AI development platform that adapts to your skill level and project phase. It provides comprehensive setup and configuration for AI coding assistants (Claude, Gemini, Grok, Codex) with progressive skill-based tooling and guardrails.

## ✨ DevPilot Features
- **Learning-Aware Profiles**: 5 skill levels (vibe → beginner → l1 → l2 → expert) with progressive tooling
- **Project Phase Management**: 4 phases (poc → mvp → beta → scale) with appropriate CI/CD gates
- **Extended Thinking Controls**: Per-skill reasoning budgets and structured prompts
- **Long-Context Management**: Map→Reduce commands for large codebase analysis
- **Structured Output**: Prefill templates and diff-first workflows
- **System Prompt Layering**: Composable global + repo + task prompt system
- **Comprehensive Auditing**: Automated code analysis and ticket generation
- **Cross-Platform Support**: WSL2, Linux, and macOS with unified tooling

## 🚀 Quick Installation
- **Linux/WSL**: `./install/key_software_linux.sh`
- **macOS**: `./install/key_software_macos.sh`
- **Universal**: `./setup_all.sh`

## 📚 Documentation
Complete guides for getting started with DevPilot:
  - docs/quickstart.md
  - docs/repo-wizard.md
  - docs/agent-commands.md
  - docs/profiles.md
  - docs/devcontainer.md
  - docs/system-prompts.md
  - docs/ci.md
  - docs/validation-troubleshooting.md
  - docs/appendix.md

## 📁 DevPilot Structure

```
devpilot/
├── setup_all.sh                     # Master setup script (auto-detects fresh/upgrade)
├── setup/
│   ├── agents_global.sh             # One-time global agent configuration  
│   ├── agents_repo.sh               # Per-repository agent setup
│   ├── repo_wizard.sh               # Interactive/non-interactive repo wizard
│   └── folders.sh                   # Create standard project directory structure
├── install/
│   ├── key_software_wsl.sh          # Install dev tools + agent multipliers
│   ├── key_software_linux.sh        # Linux development tools
│   ├── key_software_macos.sh        # macOS development tools
│   ├── ai_clis.sh                   # Install AI CLI tools
│   └── productivity_extras.sh       # Advanced tooling for all stacks
├── validation/
│   └── validate_agents.sh           # Audit script for checking agent configs
├── utils/
├── install_productivity_extras.sh   # Advanced tooling for all stacks
├── install_ai_clis.sh               # Install AI CLI tools
├── copy_windows_ssh_to_wsl.sh       # Copy SSH keys from Windows to WSL
│   └── copy_windows_ssh_to_wsl.sh   # Copy SSH keys from Windows to WSL
├── claude_user_defaults.sh          # Set Claude user defaults
├── templates/
│   └── justfile                     # Universal task runner template
├── tools/
│   └── audit_setup_scripts.sh      # Shellcheck and lint validator
├── .github/
│   └── workflows/
│       └── ci.yml                   # GitHub Actions CI pipeline
├── .pre-commit-config.yaml          # Pre-commit hooks configuration
├── Makefile                         # Development automation
└── LICENSE                          # MIT License
```

## 🚀 Quick Start

### 1. One-Command Setup (WSL/Linux/macOS)

```bash
# Clone this repository
git clone https://github.com/VivekLmd/setup-scripts.git ~/repos/setup-scripts
cd ~/repos/setup-scripts

# Run master setup (auto-detects OS + fresh vs upgrade)
./setup_all.sh
```

Or manually:

```bash
# Install essential development tools + agent multipliers
./install/key_software_wsl.sh

# Install AI CLI tools
./install_ai_clis.sh

# Set up global agent configurations (run once)
./setup/agents_global.sh

# Create project directory structure
./setup/folders.sh
```

### 2. Repository Setup

#### Interactive Mode
```bash
./setup/repo_wizard.sh
```

#### Preview/Planning Mode
**Preview first** - see what will be created without making changes:
```bash
# Using the wizard with --plan-only
./setup/repo_wizard.sh --plan-only --org myorg --category backend \
  --url git@github.com:user/repo.git --name myapp

# Or use the standalone planner
scripts/repo_plan.sh ~/projects myorg backend myapp git@github.com:user/repo.git
```

Customize location and skip prompts:
```bash
# Custom base directory with auto-confirm
./setup/repo_wizard.sh --base ~/work --org myorg --category backend \
  --url git@github.com:user/repo.git --yes
```

#### Non-Interactive Mode
```bash
# Clone and set up in one command
./setup/repo_wizard.sh --non-interactive \
  --org myorg \
  --category backend \
  --url git@github.com:user/repo.git \
  --branch main \
  --skill beginner \
  --phase mvp \
  --teach-mode on
```

#### Manual Setup (existing repo)
```bash
cd /path/to/your/repo
~/repos/setup-scripts/setup/agents_repo.sh [OPTIONS]

# Options:
#   --force         Overwrite existing files
#   --no-mcp        Skip MCP configuration
#   --no-commands   Skip Claude commands
#   --no-direnv     Skip direnv setup
#   --no-gitignore  Skip .gitignore updates
```

### macOS Quick Install

```bash
cd ~/repos/setup-scripts
./install/key_software_macos.sh    # install prerequisites via Homebrew
./setup/agents_global.sh           # seed global configs + templates
```

Then use the Repo Wizard as below.

### 3. Validation

Check all repositories for proper agent configuration:

```bash
./validation/validate_agents.sh

# Or check a specific directory tree
./validation/validate_agents.sh ~/my-projects
```

## 🧹 Repo Audit & CI

Keep scripts consistent locally and in CI:

```bash
# One-shot local audit
make audit

# Normalize CRLF in shell scripts
make fmt

# (optional) pre-commit hooks
pipx install pre-commit || pip install pre-commit
pre-commit install && pre-commit run --all-files
```

GitHub Actions runs the same pre-commit checks on every push/PR.

## 📋 Script Descriptions

### Core Agent Setup

#### `setup_agents_global.sh`
- **Purpose**: One-time global configuration for all AI agents
- **Creates**:
  - `~/.claude/settings.json` - Claude global permissions
  - `~/.gemini/settings.json` - Gemini CLI settings
  - `~/.grok/user-settings.json` - Grok CLI settings
  - `~/.codex/config.toml` - Codex configuration
  - `~/templates/agent-setup/` - Templates for repo setup

#### `setup_agents_repo.sh`
- **Purpose**: Configure AI agents for a specific repository
- **Creates**:
  - `CLAUDE.md` - Repository-specific Claude guardrails
  - `AGENTS.md` - General agent directives
  - `.claude/settings.json` - Claude permissions
  - `.claude/commands/` - Custom Claude commands
  - `.mcp.json` - MCP server configuration
  - `.mcp.local.json.example` - Template for local MCP overrides
  - `.envrc` - Direnv configuration for auto-loading
  - `.envrc.local.example` - Template for API keys
  - `.gitignore` - Updated with proper exclusions
- **Options**:
  - `--force` - Overwrite existing files
  - `--template-dir DIR` - Use custom template directory
  - `--no-mcp` - Skip MCP configuration
  - `--no-commands` - Skip Claude commands
  - `--no-direnv` - Skip direnv setup
  - `--no-gitignore` - Skip .gitignore updates

#### `validate_agents.sh`
- **Purpose**: Audit all repositories for proper agent setup
- **Checks**:
  - Required files presence
  - JSON file validity
  - Tool availability
- **Output**: Color-coded status report with fix suggestions

### Development Environment

#### `repo_wizard.sh`
- **Purpose**: Interactive/non-interactive repository setup wizard with planning preview
- **New features**: `--plan-only` for dry-run preview, `--base` for custom location, `--yes` for auto-confirm
- **Features**:
  - Organized directory structure (`~/projects/org/category/repo`)
  - GitHub repository cloning (SSH/HTTPS)
  - Automatic agent configuration
  - Commit sanitizer hooks
  - Dependency bootstrapping
- **Options**:
  - `--non-interactive` - Run without prompts
  - `--org ORG` - Organization name
  - `--category CAT` - Category (backend/frontend/mobile/etc)
  - `--url URL` - GitHub repository URL
  - `--branch BRANCH` - Branch to clone
  - `--name NAME` - Local repository name
  - `--lite` - Minimal setup (no hooks, scripts, bootstrap)
  - `--no-hooks` - Skip git hooks installation
  - `--no-scripts` - Skip helper scripts
  - `--no-bootstrap` - Skip dependency installation

#### `install_key_software_wsl.sh`
- **Installs**: 
  - Core tools: ripgrep, fd-find, jq, yq, direnv, GitHub CLI
  - Agent multipliers: mise (runtime manager), just (task runner), devcontainer CLI
  - Package managers: pnpm, uv
  - Cloud tools: AWS CLI, Azure CLI
- **Purpose**: Essential tools for development and agent functionality

#### `install_productivity_extras.sh`
- **Purpose**: Advanced tooling for backend, frontend, DS/ML, and deployment
- **Categories**:
  - **API & Contracts**: OpenAPI/GraphQL toolchain, Newman
  - **Databases**: dbt, sqlfluff, pgcli, Prisma/Drizzle
  - **DS/ML**: DVC, W&B, MLflow, nbstripout
  - **Security**: trivy, semgrep, gitleaks, hadolint, ruff/black/mypy
  - **K8s Dev**: kind, kustomize, skaffold, tilt
  - **Release**: changesets, cloudflared
  - **QoL**: hyperfine, entr, watchexec, cookiecutter
- **Run after**: `install_key_software_wsl.sh`

#### `install_ai_clis.sh`
- **Installs**: Claude, Gemini, Grok, Codex CLI tools
- **Requires**: API keys for each service

### Utilities

#### `copy_windows_ssh_to_wsl.sh`
- **Purpose**: Copy SSH keys from Windows to WSL
- **Features**: Proper permissions, known_hosts transfer

#### `make_folders.sh`
- **Creates**: Standard project directory structure under `~/projects`

#### `claude_user_defaults.sh`
- **Sets**: Default Claude user preferences

## 🎯 Productivity Extras

For advanced development scenarios, install the productivity extras:

```bash
./install_productivity_extras.sh
```

This adds powerful agent multipliers across all stacks:
- **Reproducible environments**: mise + devcontainer ensure consistent toolchains
- **Task automation**: just provides a universal command interface
- **API development**: OpenAPI/GraphQL tools for contract-first development
- **Data engineering**: dbt, DVC for analytics and ML pipelines
- **Security scanning**: trivy, semgrep for shift-left security
- **K8s development**: Local clusters and hot-reload with kind, tilt
- **Quality tools**: Formatters, linters, type checkers for all languages

### Using Justfile

Copy the template justfile to your project:

```bash
cp ~/repos/setup-scripts/templates/justfile ./justfile

# Common commands
just          # Show available commands
just install  # Install dependencies
just test     # Run tests
just lint     # Run linters
just build    # Build project
```

## 🔌 MCP (Model Context Protocol) Setup

### Local MCP Server Configuration

To run local MCP servers (e.g., for Postman, database connections, or custom tools):

1. **Create `.mcp.local.json`** in your repository:
```json
{
  "mcpServers": {
    "postman": {
      "type": "http",
      "url": "http://localhost:3000/mcp",
      "headers": {
        "Authorization": "Bearer ${POSTMAN_API_KEY}"
      }
    },
    "database": {
      "type": "stdio",
      "command": "/usr/local/bin/mcp-postgres",
      "args": ["--connection-string", "${DATABASE_URL}"]
    },
    "custom": {
      "type": "sse",
      "url": "http://localhost:8080/events",
      "env": {
        "API_KEY": "${CUSTOM_API_KEY}"
      }
    }
  }
}
```

2. **Add credentials to `.envrc.local`**:
```bash
export POSTMAN_API_KEY="your-postman-api-key"
export DATABASE_URL="postgresql://user:pass@localhost/dbname"
export CUSTOM_API_KEY="your-custom-key"
```

3. **Merge local config** (automatic if using our setup):
   - `.mcp.local.json` is gitignored
   - Claude will read both `.mcp.json` and `.mcp.local.json`
   - Local settings override global ones

### Available MCP Servers

- **GitHub**: Built-in via `.mcp.json`
- **Atlassian**: Built-in via `.mcp.json`
- **Postman**: Set up local server with Postman API
- **Database**: Use MCP database adapters for PostgreSQL/MySQL
- **Custom**: Build your own MCP server for internal tools

## 🔧 Configuration Files

### Global Configuration
After running `setup_agents_global.sh`:
- `~/.claude/settings.json` - Claude global settings
- `~/.gemini/settings.json` - Gemini settings
- `~/.grok/user-settings.json` - Grok settings
- `~/.codex/config.toml` - Codex configuration

### Per-Repository Files
After running `setup_agents_repo.sh`:
- `CLAUDE.md` - Repository-specific instructions for Claude
- `AGENTS.md` - General agent directives
- `.claude/settings.json` - Claude permissions for this repo
- `.claude/commands/*.md` - Custom Claude commands
- `.mcp.json` - MCP server configuration
- `.mcp.local.json` - Local MCP overrides (gitignored)
- `.envrc` - Auto-load environment variables
- `.envrc.local` - Local environment variables (gitignored)

## 🔐 Security Best Practices

1. **API Keys**: Store in `.envrc.local` (automatically gitignored)
2. **Secrets**: Never commit `.env*` files or `secrets/` directories
3. **Permissions**: Review `.claude/settings.json` permissions
4. **MCP Servers**: Use `.mcp.local.json` for sensitive configurations

## 📝 Workflow Example

```bash
# 1. Initial setup (once per system)
cd ~/repos/setup-scripts
./install/key_software_wsl.sh
./install_ai_clis.sh
./setup/agents_global.sh

# 2. Set up a new project
./setup/repo_wizard.sh
# Choose organization, category, provide GitHub URL
# Script clones repo and configures everything
# In interactive mode, wizard can apply a profile and ask for Beginner teach mode.
# It also prints GitHub repo secrets commands if API keys are missing.

# 3. Work on the project
cd ~/projects/myorg/backend/myrepo
# Claude/Gemini/Grok will respect the configurations

# 4. Validate setup across all projects
~/repos/setup-scripts/validate_agents.sh

# 5. Fix any misconfigured repos
cd ~/projects/myorg/backend/broken-repo
~/repos/setup-scripts/setup/agents_repo.sh --force
```

## 🧪 Testing

Run sanity checks after setup:

```bash
# Check file presence
ls -la CLAUDE.md AGENTS.md .mcp.json .claude/settings.json

# Validate JSON files
jq -e type .claude/settings.json && echo "✓ Valid JSON"
jq -e type .mcp.json && echo "✓ Valid JSON"

# Check tool availability
rg --version && jq --version && pnpm -v

# In Claude REPL
/mcp           # Should show connected MCP servers
/permissions   # Should show your allow/ask/deny rules
```

## 🤝 Contributing

1. Keep scripts idempotent (safe to run multiple times)
2. Use `set -euo pipefail` for error handling
3. Provide `--force` flags for overwrites
4. Maintain backwards compatibility
5. Document new features in this README

#### `setup_all.sh`
- **Purpose**: Master setup script with mode detection
- **Modes**:
  - **Fresh**: Full installation for new systems
  - **Upgrade**: Backs up and updates existing configurations
- **Options**:
  - `--fresh` - Force fresh installation
  - `--upgrade` - Force upgrade mode
  - `--os <wsl|linux|macos>` - Force platform installer (overrides auto-detect)
  - `--yes` - Non-interactive; skip confirmation prompts
  - `--skip-tools` - Skip tool installation
  - `--skip-agents` - Skip agent configuration
  - `--backup-only` - Only backup existing configs

## 📄 License

Proprietary License - Copyright © 2024 Softsensor.AI - See [LICENSE](LICENSE) file for details

## 🆘 Troubleshooting

### Common Issues

**Missing tools**: Run `./install/key_software_wsl.sh`

**Invalid JSON**: Check with `jq -e type <file>`

**Permission denied**: Ensure scripts are executable: `chmod +x *.sh`

**API keys not loading**: Check `.envrc.local` and run `direnv allow`

**Repos not configured**: Run `./validation/validate_agents.sh` to identify and fix

### Support

For issues or questions, please open an issue in this repository.

## 📚 Additional Documentation

- Quick Start: docs/quickstart.md
- Repo Wizard Tutorial: docs/repo-wizard.md
- Commands Catalog (Claude): docs/agent-commands.md
- Profiles & Skill Levels: docs/profiles.md
- System Prompt Layering: docs/system-prompts.md
- CI Integrations: docs/ci.md
- Validation & Troubleshooting: docs/validation-troubleshooting.md
