# DevPilot Quickstart Guide

## 🚀 2-Minute Setup

```bash
# Clone DevPilot
git clone https://github.com/VivekLmd/setup-scripts.git ~/devpilot

# Run setup
cd ~/devpilot && ./setup_all.sh

# Create your first AI-powered project
./setup/repo_wizard.sh
```

## 📋 What Gets Installed

### Step 1: Core Tools
- **Search**: ripgrep, fd-find for lightning-fast code search
- **Processing**: jq, yq for JSON/YAML manipulation
- **Environment**: direnv for auto-loading project settings
- **Package Management**: pnpm for Node.js, uv for Python
- **Runtime Management**: mise for version control
- **Task Runner**: just for unified commands

### Step 2: AI Assistants
- **Claude**: Anthropic's coding assistant with MCP support
- **Gemini**: Google's AI with advanced reasoning
- **Grok**: X.AI's assistant with custom commands
- **Codex**: OpenAI-powered completions

### Step 3: Global Configuration
Creates in your home directory:
- `~/.claude/settings.json` - Claude permissions
- `~/.gemini/settings.json` - Gemini settings
- `~/.grok/user-settings.json` - Grok config
- `~/.codex/config.toml` - Codex setup
- `~/templates/` - Reusable project templates

### Step 4: Project Structure
```
~/projects/
├── work/          # Professional projects
├── personal/      # Side projects
├── learning/      # Tutorials
└── opensource/    # Open source contributions
```

## 🎯 Your First AI Project

### Interactive Setup (Recommended)
```bash
cd ~/devpilot
./setup/repo_wizard.sh
```

You'll be asked:
1. **Organization**: work, personal, learning, or custom
2. **Category**: backend, frontend, mobile, ml, etc.
3. **Repository URL**: Your GitHub repo (or we'll create one)

### One-Line Setup
```bash
./setup/repo_wizard.sh \
  --url git@github.com:you/awesome-project.git \
  --org work \
  --category backend \
  --skill beginner \
  --phase mvp
```

## 🎓 Skill Levels Explained

DevPilot adapts to your experience:

| Level | Who It's For | What You Get |
|-------|-------------|--------------|
| **beginner** | New to coding | Teaching mode, guided help, safety rails |
| **l1** | Junior dev | Basic tools, structured patterns |
| **l2** | Mid-level | Advanced tools, CI/CD, testing |
| **expert** | Senior/architect | Full access, complex operations |

Start with `beginner` if unsure - you can change anytime!

## 🤖 Using AI Assistants

After setup, in any project:

```bash
# Claude - Best for complex coding
claude "refactor this function for better performance"

# Gemini - Great for explanations
gemini "explain how this authentication works"

# Grok - Good for quick tasks
grok "add error handling to this script"

# Codex - Completions and generation
codex "generate unit tests"
```

## 🔑 API Keys (Optional but Recommended)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export GEMINI_API_KEY="..."
export XAI_API_KEY="..."

# Reload shell
source ~/.bashrc
```

**No API keys?** Tools still work locally with reduced features.

## 📦 Project Commands

Every DevPilot project gets these commands:

```bash
just          # Show available tasks
just test     # Run tests
just lint     # Check code quality
just build    # Build project
just dev      # Start development server
```

## 🛠️ Advanced Features

### Use Claude Commands
In Claude, type `/` to see available commands:
- `/think-hard` - Deep problem solving
- `/security-review` - Find vulnerabilities
- `/audit-full` - Complete code review
- `/tickets-from-code` - Generate JIRA tickets

### Apply Profiles
```bash
# Change skill level
cd your-project
~/devpilot/scripts/apply_profile.sh --skill l2

# Change project phase
~/devpilot/scripts/apply_profile.sh --phase beta
```

### Install Extra Tools
```bash
# Database, ML, Kubernetes tools
~/devpilot/install/productivity_extras.sh
```

## ✅ Verify Setup

```bash
# Check everything is configured
~/devpilot/validation/validate_agents.sh

# See all your projects
ls ~/projects/
```

## 🆘 Troubleshooting

### Command not found
```bash
# Reload your shell
exec bash
# or
source ~/.bashrc
```

### Permission denied
```bash
# Make scripts executable
chmod +x ~/devpilot/**/*.sh
```

### Missing tools
```bash
# Re-run setup for your platform
~/devpilot/install/key_software_linux.sh  # Linux/WSL
~/devpilot/install/key_software_macos.sh  # macOS
```

## 📚 Next Steps

1. **Explore Commands**: Check `.claude/commands/` in any project
2. **Read CLAUDE.md**: See project-specific AI instructions
3. **Try Profiles**: Experiment with different skill levels
4. **Setup MCP**: Add Jira, Confluence integrations

## 🎉 You're Ready!

Start coding with AI assistance:
```bash
cd ~/projects/[your-project]
claude "let's build something amazing"
```

---

**Need help?** Run `~/devpilot/validation/validate_agents.sh` to diagnose issues.
