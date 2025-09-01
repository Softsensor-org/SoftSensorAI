# DevPilot - AI-Powered Development Platform

[![CI](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml)

**DevPilot** is a comprehensive AI development platform that transforms how you work with Claude, Gemini, Grok, and Codex. It provides intelligent project setup, skill-based configurations, and powerful automation tools.

## 🚀 Quick Start (2 minutes)

```bash
git clone https://github.com/VivekLmd/setup-scripts.git ~/devpilot
cd ~/devpilot
./setup_all.sh
```

## 🎯 What DevPilot Does

### 1. **AI Agent Configuration**
- **Multi-Agent Support**: Claude, Gemini, Grok, Codex with unified setup
- **Global + Repo Settings**: System-wide defaults with per-project customization
- **MCP Servers**: GitHub, Atlassian, custom integrations
- **Smart Permissions**: Granular tool access control

### 2. **Skill-Based Development Profiles**
Adapts to your experience level with 5 progressive skill tiers:

| Skill Level | Description | Features |
|------------|-------------|----------|
| **Vibe** | Exploration mode | Minimal restrictions, creative freedom |
| **Beginner** | Learning-focused | Teaching mode, guided workflows, safety rails |
| **L1** | Junior developer | Basic tooling, structured patterns |
| **L2** | Mid-level | Advanced tools, CI/CD, testing focus |
| **Expert** | Senior/architect | Full access, complex operations |

### 3. **Project Phase Management**
Automatic configuration based on project maturity:

| Phase | Focus | Automated Setup |
|-------|-------|-----------------|
| **POC** | Rapid prototyping | Minimal CI, flexible structure |
| **MVP** | Core features | Basic tests, simple CI |
| **Beta** | Quality & stability | Full testing, staging deploys |
| **Scale** | Production-ready | Complete CI/CD, monitoring |

### 4. **Advanced Claude Commands**
Pre-configured command library in `.claude/commands/`:

**Thinking & Analysis:**
- `/think-hard` - Deep reasoning with structured output
- `/explore-plan-code-test` - Full development cycle
- `/security-review` - Security vulnerability analysis
- `/audit-full` - Comprehensive code audit

**Patterns & Templates:**
- `/backend-feature` - API endpoint scaffolding
- `/sql-migration` - Database migration patterns
- `/api-contract` - OpenAPI/GraphQL contracts
- `/test-driven` - TDD workflow

**Automation:**
- `/tickets-from-code` - Generate JIRA/GitHub issues
- `/chain-runner` - Multi-step task automation
- `/parallel-map` - Parallel processing patterns

### 5. **Development Tools**

**Core Tools:**
- `ripgrep`, `fd` - Lightning-fast search
- `jq`, `yq` - JSON/YAML processing
- `GitHub CLI` - Repository management
- `direnv` - Auto-loading environments
- `mise` - Runtime version management
- `just` - Universal task runner

**Productivity Extras** (`install/productivity_extras.sh`):
- **API Development**: OpenAPI Generator, GraphQL tools, Newman
- **Databases**: dbt, sqlfluff, pgcli, Prisma, Drizzle
- **ML/Data**: DVC, Weights & Biases, MLflow, nbstripout
- **Security**: trivy, semgrep, gitleaks, hadolint
- **Kubernetes**: kind, kustomize, skaffold, tilt
- **Quality**: ruff, black, mypy, prettier, eslint

### 6. **Repository Wizard**
Intelligent project setup with `setup/repo_wizard.sh`:

```bash
# Interactive mode (recommended)
./setup/repo_wizard.sh

# One-liner with all options
./setup/repo_wizard.sh \
  --url git@github.com:you/repo.git \
  --org work \
  --category backend \
  --skill beginner \
  --phase mvp \
  --teach-mode on
```

**Interactive Profile Selection:**
When you run the wizard, it now prompts you to select:

1. **Skill Level** (with descriptions):
   - `vibe` - Vibecoding: minimal structure, maximum freedom
   - `beginner` - Learning mode with detailed guidance
   - `l1` - Junior developer level
   - `l2` - Mid-level developer
   - `expert` - Senior developer, minimal hand-holding

2. **Project Phase** (with descriptions):
   - `poc` - Proof of concept, rapid prototyping
   - `mvp` - Minimum viable product
   - `beta` - Beta testing, stabilization
   - `scale` - Production, scaling focus

**Features:**
- Organized directory structure (`~/projects/org/category/repo`)
- Automatic dependency detection with detailed reporting
- Shows what dependency files are found (package.json, requirements.txt, etc.)
- Reports what was actually installed (Node modules, Python venv, etc.)
- Git hooks for commit quality
- Profile-based configuration with interactive selection
- MCP server setup
- Environment variable management

**Updating Existing Repos:**
To change your profile on an existing repository:
```bash
# From within your repo
scripts/apply_profile.sh --skill vibe --phase poc

# Or use interactive mode
scripts/apply_profile.sh
```

### 7. **Project Organization**

```
~/projects/
├── work/              # Professional projects
│   ├── backend/       # API services
│   ├── frontend/      # Web apps
│   └── infra/         # Infrastructure
├── personal/          # Side projects
├── learning/          # Tutorials
└── opensource/        # Contributions
```

### 8. **Validation & Auditing**

```bash
# Validate all projects
./validation/validate_agents.sh

# Auto-fix missing configurations
./validation/validate_agents.sh --fix

# JSON output for CI/CD
./validation/validate_agents.sh --json
```

## 📁 Configuration Files

### Global (User Home)
- `~/.claude/settings.json` - Claude global settings
- `~/.gemini/settings.json` - Gemini configuration
- `~/.grok/user-settings.json` - Grok settings
- `~/.codex/config.toml` - Codex configuration
- `~/templates/agent-setup/` - Reusable templates

### Per Repository
- `CLAUDE.md` - Project-specific AI instructions
- `AGENTS.md` - General agent directives
- `.claude/settings.json` - Repository permissions
- `.claude/commands/` - Custom commands
- `.mcp.json` - MCP server configuration
- `.envrc` - Environment variables
- `.gitignore` - Smart exclusions

## 🔧 Installation Options

### Complete Setup
```bash
./setup_all.sh
```

### Individual Components
```bash
# Development tools only
./install/key_software_linux.sh  # or key_software_macos.sh

# AI CLIs only
./install/ai_clis.sh

# Global agent config
./setup/agents_global.sh

# Repository setup
cd /your/project
~/devpilot/setup/agents_repo.sh
```

### Platform Support

| Platform | Installer | Notes |
|----------|-----------|-------|
| **WSL/Ubuntu** | `install/key_software_linux.sh` | Full support |
| **Linux** | `install/key_software_linux.sh` | Cross-distro |
| **macOS** | `install/key_software_macos.sh` | Homebrew-based |

## 🎓 Skill Progression

DevPilot grows with you:

1. **Start as Beginner**: Teaching mode enabled, safety rails active
2. **Progress to L1/L2**: Unlock advanced tools and patterns
3. **Expert Mode**: Full control, complex operations

Change skill level anytime:
```bash
cd /your/project
~/devpilot/scripts/apply_profile.sh --skill l2 --phase beta
```

## 🔌 MCP (Model Context Protocol)

Built-in integrations:
- **GitHub**: Issues, PRs, repos
- **Atlassian**: Jira, Confluence
- **Custom**: Add your own servers

Configure in `.mcp.json` or `.mcp.local.json` (gitignored).

## 🔐 Security Features

- **Secure-by-default**: Sensitive operations require approval
- **Commit sanitization**: Automatic secret detection
- **Gitignore management**: Prevents accidental commits
- **Environment isolation**: `.envrc.local` for secrets

## 📚 Documentation

- [Quickstart Guide](docs/quickstart.md)
- [Repository Wizard](docs/repo-wizard.md)
- [Command Reference](docs/agent-commands.md)
- [Skill Profiles](docs/profiles.md)
- [CI/CD Integration](docs/ci.md)
- [Troubleshooting](docs/validation-troubleshooting.md)

## 🤝 Contributing

DevPilot is actively developed. Contributions welcome!

1. Scripts must be idempotent
2. Use `set -euo pipefail`
3. Provide `--force` flags
4. Document new features

## 📄 License

Proprietary - Copyright © 2024 Softsensor.AI - See [LICENSE](LICENSE) file

---

**Ready to supercharge your development?** Run `./setup_all.sh` and start building with AI! 🚀
