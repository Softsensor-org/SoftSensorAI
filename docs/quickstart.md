# DevPilot Quickstart Guide

## 🚀 2-Minute Setup

```bash
# 1. Clone and install DevPilot
git clone https://github.com/Softsensor-org/DevPilot.git ~/devpilot
cd ~/devpilot && ./setup_all.sh

# 2. Add dp command to PATH
export PATH="$HOME/devpilot/bin:$PATH"  # Add to ~/.bashrc

# 3. Setup your project
cd your-project
dp setup   # Smart detection for any project
dp init    # Initialize with full configuration

# 4. Start using DevPilot
dp palette  # Discover all available commands
```

## 🆕 New Features

- **🎮 GPU Detection**: Automatically detects NVIDIA/AMD/Apple Silicon GPUs
- **🤖 AI Frameworks**: One-command installation of LangChain, AutoGen, CrewAI
- **🔒 Checksum Verification**: Secure downloads with hash verification
- **🎭 Multi-Persona System**: Combine multiple AI personas for specialized help
- **📦 Python 3.12**: Latest Python for better performance
- **🧪 Data Science Support**: GPU optimization insights and ML workflow tools
- **🏗️ Architecture Tools**: System design and scalability analysis
- **🤖 Codex Integration**: Full AI assistant support with sandboxed execution

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

### ⭐ RECOMMENDED: Existing Repository Setup

**Most teams should use this approach** - it works with your current directory structure:

```bash
# Navigate to your already-cloned repo
cd /path/to/your/existing/repo

# Run setup without cloning (keeps your structure intact)
~/devpilot/setup/existing_repo_setup.sh --skill l1 --phase mvp

# Add personas for your project type
~/devpilot/scripts/persona_manager.sh add backend-developer
~/devpilot/scripts/persona_manager.sh add devops-engineer
```

**Why this is better:**

- ✅ Works with your existing directory structure
- ✅ No repo cloning or moving
- ✅ Keeps your current workflow
- ✅ Perfect for teams with established repos

### Alternative: New Project (Clone & Setup)

Only use this if you need to clone a repository first:

```bash
# Interactive wizard that clones then sets up
~/devpilot/setup/repo_wizard.sh
```

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

| Level        | Who It's For     | What You Get                             |
| ------------ | ---------------- | ---------------------------------------- |
| **beginner** | New to coding    | Teaching mode, guided help, safety rails |
| **l1**       | Junior dev       | Basic tools, structured patterns         |
| **l2**       | Mid-level        | Advanced tools, CI/CD, testing           |
| **expert**   | Senior/architect | Full access, complex operations          |

Start with `beginner` if unsure - you can change anytime!

## 🤖 Using AI Assistants (CLI-First)

**Important**: DevPilot uses the **CLI versions** of AI assistants, not raw APIs. Each assistant
points to `system/active.md` for consistent behavior.

### Installing AI CLIs (Required)

**Important**: DevPilot requires CLI tools, not direct API access. See
[AI CLI Installation Guide](./AI_CLI_INSTALL.md) for detailed instructions.

```bash
# Quick install (Anthropic recommended)
pip install anthropic
export ANTHROPIC_API_KEY="sk-ant-..."

# Verify installation
command -v anthropic && echo "✓ Ready to use AI features"
```

For other providers (OpenAI, Gemini, Grok) and troubleshooting, see the
[AI CLI Installation Guide](./AI_CLI_INSTALL.md).

### Daily Usage: Always Target system/active.md

**Key Point**: Always point CLI tools at `system/active.md` - this contains your merged prompts
(global + repo + task).

```bash
# Claude - Best for complex coding
claude --system-prompt system/active.md "refactor this function for better performance"

# Gemini - Great for explanations
gemini --context system/active.md "explain how this authentication works"

# Grok - Good for quick tasks
grok --prompt system/active.md "add error handling to this script"

# Codex - Completions and generation (with sandboxed execution)
codex --system system/active.md --sandbox "generate unit tests"
```

**Why system/active.md?**

- ✅ Contains your skill level, project phase, and personas
- ✅ Merges global DevPilot guidance + your project specifics
- ✅ Ensures consistent AI behavior across all assistants
- ✅ Automatically updated when you change profiles/personas

### Using Slash Commands

```bash
# Use specific commands from the catalog
claude --system-prompt .claude/commands/security-review.md "review auth flow"
claude --system-prompt .claude/commands/think-hard.md "should we use microservices?"
codex --system .claude/commands/patterns/arch-spike.md "design payment service"
```

### 🎭 Managing Personas

```bash
# Add personas to your project
cd your-project
~/devpilot/scripts/persona_manager.sh add data-scientist
~/devpilot/scripts/persona_manager.sh add software-architect

# View active personas
~/devpilot/scripts/persona_manager.sh show

# Remove a persona
~/devpilot/scripts/persona_manager.sh remove data-scientist
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
# Interactive profile selection
cd your-project
~/devpilot/scripts/apply_profile.sh

# Direct profile application
~/devpilot/scripts/apply_profile.sh --skill l2 --phase beta

# Add specialized personas
~/devpilot/scripts/persona_manager.sh add data-scientist
~/devpilot/scripts/persona_manager.sh add software-architect
```

### Install Extra Tools

```bash
# Database, ML, Kubernetes tools
~/devpilot/install/productivity_extras.sh

# AI Frameworks (with GPU optimization)
~/devpilot/scripts/setup_ai_frameworks.sh
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
3. **Try Personas**: Add data-scientist or software-architect personas
4. **Setup AI Frameworks**: Install LangChain, AutoGen for agent development
5. **Learn Security**: Read [Security Guide](SECURITY.md) for best practices
6. **Build AI Apps**: Check [AI Frameworks Guide](AI_FRAMEWORKS.md) for examples

## 🎉 You're Ready!

Start coding with AI assistance:

```bash
cd ~/projects/[your-project]
claude "let's build something amazing"
```

---

**Need help?** Run `~/devpilot/validation/validate_agents.sh` to diagnose issues.
