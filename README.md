# WSL & AI Agent Setup Scripts

A comprehensive collection of setup scripts for WSL development environment and AI CLI agents (Claude, Gemini, Grok, Codex).

## 📁 Repository Structure

```
setup-scripts/
├── setup_agents_global.sh     # One-time global agent configuration
├── setup_agents_repo.sh       # Per-repository agent setup
├── validate_agents.sh          # Audit script for checking agent configs
├── repo_setup_wizard.sh        # Interactive repository setup wizard
├── install_key_software_wsl.sh # Install essential WSL development tools
├── install_ai_clis.sh          # Install AI CLI tools
├── copy_windows_ssh_to_wsl.sh  # Copy SSH keys from Windows to WSL
├── make_folders.sh             # Create standard project directory structure
└── claude_user_defaults.sh     # Set Claude user defaults
```

## 🚀 Quick Start

### 1. Initial System Setup

```bash
# Clone this repository
git clone <your-repo-url> ~/repos/setup-scripts
cd ~/repos/setup-scripts

# Install essential development tools
./install_key_software_wsl.sh

# Install AI CLI tools
./install_ai_clis.sh

# Set up global agent configurations (run once)
./setup_agents_global.sh

# Create project directory structure
./make_folders.sh
```

### 2. Repository Setup

For each new repository:

```bash
# Interactive wizard for cloning and setting up a repo
./repo_setup_wizard.sh

# Or manually set up agent files in an existing repo
cd /path/to/your/repo
~/repos/setup-scripts/setup_agents_repo.sh
```

### 3. Validation

Check all repositories for proper agent configuration:

```bash
./validate_agents.sh

# Or check a specific directory tree
./validate_agents.sh ~/my-projects
```

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
  - `.envrc` - Direnv configuration for auto-loading
  - `.gitignore` - Updated with proper exclusions
- **Options**:
  - `--force` - Overwrite existing files
  - `--template-dir DIR` - Use custom template directory

#### `validate_agents.sh`
- **Purpose**: Audit all repositories for proper agent setup
- **Checks**:
  - Required files presence
  - JSON file validity
  - Tool availability
- **Output**: Color-coded status report with fix suggestions

### Development Environment

#### `repo_setup_wizard.sh`
- **Purpose**: Interactive wizard for repository setup
- **Features**:
  - Organized directory structure (`~/projects/org/category/repo`)
  - GitHub repository cloning (SSH/HTTPS)
  - Automatic agent configuration
  - Commit sanitizer hooks
  - Dependency bootstrapping
- **Options**:
  - `--lite` - Minimal setup (no hooks, scripts, bootstrap)
  - `--no-hooks` - Skip git hooks installation
  - `--no-scripts` - Skip helper scripts
  - `--no-bootstrap` - Skip dependency installation

#### `install_key_software_wsl.sh`
- **Installs**: ripgrep, fd-find, jq, yq, direnv, GitHub CLI, and more
- **Purpose**: Essential tools for development and agent functionality

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
./install_key_software_wsl.sh
./install_ai_clis.sh
./setup_agents_global.sh

# 2. Set up a new project
./repo_setup_wizard.sh
# Choose organization, category, provide GitHub URL
# Script clones repo and configures everything

# 3. Work on the project
cd ~/projects/myorg/backend/myrepo
# Claude/Gemini/Grok will respect the configurations

# 4. Validate setup across all projects
~/repos/setup-scripts/validate_agents.sh

# 5. Fix any misconfigured repos
cd ~/projects/myorg/backend/broken-repo
~/repos/setup-scripts/setup_agents_repo.sh --force
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

## 📄 License

[Your License Here]

## 🆘 Troubleshooting

### Common Issues

**Missing tools**: Run `./install_key_software_wsl.sh`

**Invalid JSON**: Check with `jq -e type <file>`

**Permission denied**: Ensure scripts are executable: `chmod +x *.sh`

**API keys not loading**: Check `.envrc.local` and run `direnv allow`

**Repos not configured**: Run `./validate_agents.sh` to identify and fix

### Support

For issues or questions, please open an issue in this repository.