# DevPilot - AI-Powered Development Setup

[![CI](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml)

**Get your AI-powered development environment running in 2 minutes.**

DevPilot sets up Claude, Gemini, Grok, and Codex with smart defaults for your projects. It handles the configuration so you can start coding with AI assistance immediately.

## Quick Start

```bash
# Clone and run
git clone https://github.com/VivekLmd/setup-scripts.git ~/devpilot
cd ~/devpilot
./setup_all.sh
```

That's it! DevPilot will:
- ✅ Install essential development tools
- ✅ Configure AI assistants (Claude, Gemini, Grok, Codex)
- ✅ Set up your project structure
- ✅ Create smart templates and commands

## Setting Up Your First Project

```bash
# Interactive setup - answer 3 questions
./setup/repo_wizard.sh

# Or one-liner with your GitHub repo
./setup/repo_wizard.sh --url git@github.com:you/your-repo.git
```

The wizard will:
1. Clone your repository
2. Configure AI agents for your codebase
3. Set up development tools
4. Install dependencies

## What You Get

### 🤖 AI Assistants Ready to Use
- **Claude**: Advanced coding with MCP integrations
- **Gemini**: Google's AI with project context
- **Grok**: X.AI assistant with custom commands
- **Codex**: OpenAI-powered completions

### 🛠️ Essential Tools
- **ripgrep**, **fd**: Lightning-fast search
- **jq**, **yq**: JSON/YAML processing
- **direnv**: Auto-loading project environments
- **GitHub CLI**: Repository management
- **pnpm**: Fast package manager
- **mise**: Runtime version management

### 📁 Smart Project Structure
```
~/projects/
├── work/          # Professional projects
├── personal/      # Side projects
├── learning/      # Tutorials and experiments
└── opensource/    # Contributions
```

## Platform Support

| Platform | Command |
|----------|---------|
| **Linux/WSL** | `./install/key_software_linux.sh` |
| **macOS** | `./install/key_software_macos.sh` |
| **Universal** | `./setup_all.sh` (auto-detects) |

## API Keys (Optional)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export GEMINI_API_KEY="..."
export XAI_API_KEY="..."
```

Don't have keys? The tools work locally too - just with reduced AI features.

## Common Tasks

### Add AI to Existing Project
```bash
cd /your/project
~/devpilot/setup/agents_repo.sh
```

### Check Setup Health
```bash
~/devpilot/validation/validate_agents.sh
```

### Install Extra Tools
```bash
# Database tools, linters, K8s utilities
~/devpilot/install/productivity_extras.sh
```

## Project Commands

After setup, your projects get these commands:

| Command | What it does |
|---------|-------------|
| `just` | Show available tasks |
| `just test` | Run tests |
| `just lint` | Check code quality |
| `just build` | Build project |
| `just dev` | Start development |

## Troubleshooting

**Installation fails?**
```bash
# Check prerequisites
which git curl || echo "Install git and curl first"
```

**API keys not working?**
```bash
# Reload environment
source ~/.bashrc
# Or for zsh
source ~/.zshrc
```

**Need help?**
```bash
# Check setup status
./validation/validate_agents.sh

# See all available scripts
ls -la setup/ install/ validation/
```

## Learn More

- **Quick Setup**: [docs/quickstart.md](docs/quickstart.md)
- **Repository Wizard**: [docs/repo-wizard.md](docs/repo-wizard.md)
- **Custom Commands**: [docs/agent-commands.md](docs/agent-commands.md)
- **Advanced Features**: [docs/profiles.md](docs/profiles.md)

## License

MIT - See [LICENSE](LICENSE) file

---

**Ready to code with AI?** Run `./setup_all.sh` and start building! 🚀