# DevPilot Quick Start Guide

Get up and running with DevPilot in 5 minutes! This guide covers the essential steps to install DevPilot and start using AI-augmented development.

## Prerequisites

Before starting, ensure you have:
- **OS**: WSL 2, Ubuntu 20.04+, or macOS 11+
- **Shell**: Bash 4.0 or higher
- **Tools**: Git and curl/wget installed
- **API Keys**: At least one AI service API key ready

## 🚀 Installation (2 minutes)

### Option 1: DevPilot 2.0 (Recommended)

```bash
# Clone DevPilot
git clone https://github.com/yourusername/devpilot.git ~/repos/devpilot
cd ~/repos/devpilot

# Run bootstrap (auto-detects your system)
./devpilot-new/devpilot bootstrap --yes

# Add to PATH
echo 'export PATH="$HOME/repos/devpilot/devpilot-new:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Option 2: Legacy Install

```bash
# Use the traditional installer
cd ~/repos/devpilot
./setup_all.sh

# Or run components individually:
./install/key_software_wsl.sh    # Platform tools
./install/ai_clis.sh              # AI CLIs
./setup/agents_global.sh          # Agent configs
./setup/folders.sh                 # Directory structure
```

## 🔑 Configure API Keys (1 minute)

Add your API keys to your shell configuration:

```bash
# Add to ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'
# AI API Keys
export ANTHROPIC_API_KEY='sk-ant-...'  # Claude
export GEMINI_API_KEY='AI...'           # Gemini
export XAI_API_KEY='xai-...'            # Grok
export OPENAI_API_KEY='sk-...'          # GPT/Codex
EOF

# Reload configuration
source ~/.bashrc
```

## 🤖 Setup AI Agents (1 minute)

Configure AI assistants globally:

```bash
# DevPilot 2.0
devpilot pilot setup

# Or legacy method
./setup/agents_global.sh

# Verify setup
devpilot insights audit --agents
# Or: ./validation/validate_agents.sh
```

## 📁 Create Project Structure (1 minute)

Set up your development workspace:

```bash
# DevPilot 2.0
devpilot core folders --orgs "mycompany" --personal "personal"

# Or legacy method
./setup/folders.sh

# Open workspace in VS Code
code ~/workspaces/personal.code-workspace
```

## 🎯 Start Your First Project

### Option 1: Interactive Wizard (DevPilot 2.0)

```bash
# Navigate to projects directory
cd ~/projects/personal

# Run interactive wizard
devpilot project wizard

# Follow the prompts to:
# - Choose project type
# - Select AI agents
# - Configure settings
```

### Option 2: Repository Wizard (Legacy)

```bash
# Run the setup wizard
./setup/repo_wizard.sh

# Choose org/category and paste GitHub URL
# The wizard will:
# - Clone the repository
# - Setup AI agents
# - Apply skill profile
```

### Option 3: Quick Manual Setup

```bash
# Create a new project
mkdir ~/projects/personal/my-api && cd $_
git init

# Initialize with agents
devpilot pilot repo-setup
# Or: ~/repos/devpilot/setup/agents_repo.sh

# Apply skill profile
echo "DEVPILOT_SKILL_LEVEL=l1" >> .env
echo "DEVPILOT_PROJECT_PHASE=mvp" >> .env
```

## 📋 Essential Commands

### Daily Workflow

```bash
# Start coding with AI
claude "Help me create a REST API with Express"
gemini "Optimize this database query"
grok "Explain this error message"
codex "Generate unit tests for this function"

# Check system health
devpilot insights doctor       # System diagnostics
devpilot insights audit        # Code quality check
```

### Project Management

```bash
# Create new project
devpilot project wizard

# Setup existing project
cd existing-project
devpilot pilot repo-setup

# Update folder structure
devpilot core folders
```

### System Maintenance

```bash
# Update DevPilot
devpilot upgrade

# Check for issues
devpilot insights doctor

# Validate agent configurations
./validation/validate_agents.sh ~/projects

# View help
devpilot help
```

## 🎓 Skill Profiles

DevPilot adapts to your skill level. Set your profile:

```bash
# Set skill level (vibe|beginner|l1|l2|expert)
export DEVPILOT_SKILL_LEVEL="l1"

# Set project phase (poc|mvp|beta|scale)
export DEVPILOT_PROJECT_PHASE="mvp"

# Or use the profile script
./scripts/apply_profile.sh --skill beginner --phase mvp --teach-mode on
```

### Profile Features

| Level | Description | Key Features |
|-------|------------|--------------|
| **vibe** | Exploration | Maximum freedom, minimal guardrails |
| **beginner** | Learning | Guided workflows, helpful explanations |
| **l1** | Junior | Standard tooling, basic CI/CD |
| **l2** | Mid-level | Advanced tools, full CI/CD |
| **expert** | Senior | All features, custom configurations |

## 🔧 Common Workflows

### Starting a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/user-auth

# 2. Setup AI agents for the task
cat > CLAUDE.md << 'EOF'
Task: Implement user authentication
- Use JWT tokens
- Add password hashing with bcrypt
- Create login/register endpoints
- Add input validation
EOF

# 3. Start development with AI
claude "Let's implement the user authentication system"
```

### Code Review with AI

```bash
# Stage your changes
git add .

# Get AI review
claude "Review my staged changes for security and best practices"

# Apply suggestions and commit
git commit -m "feat: add user authentication system"
```

### Debugging with AI

```bash
# Describe the issue
gemini "My API returns 500 error when POSTing to /users. Here's the error log:"

# Or analyze specific files
claude "Debug this controller:" --file src/controllers/user.ts
```

## 🚨 Troubleshooting

### Command Not Found

```bash
# For DevPilot 2.0
echo $PATH | grep devpilot-new
export PATH="$HOME/repos/devpilot/devpilot-new:$PATH"

# For legacy commands
export PATH="$HOME/repos/devpilot:$PATH"
```

### API Key Issues

```bash
# Check if keys are set
env | grep -E "(ANTHROPIC|GEMINI|XAI|OPENAI)_API_KEY"

# Test API connection
claude "Hello, are you working?"
```

### WSL PowerShell Hanging

```bash
# DevPilot 2.0 avoids PowerShell entirely
# If using legacy scripts and they hang:
ps aux | grep powershell
kill -9 <PID>

# Use DevPilot 2.0 instead:
devpilot bootstrap --platform wsl
```

## 📚 Next Steps

Now that you're set up:

1. **Explore Features**: Read the [full documentation](../README.md)
2. **Migrate to 2.0**: Follow the [migration guide](migration.md)
3. **Customize**: Configure your [skill profile](profiles.md)
4. **Learn**: Check out [agent commands](agent-commands.md)
5. **Integrate**: Set up [CI/CD](ci.md) for your projects

## 💡 Pro Tips

### Batch Operations
```bash
# Configure multiple projects at once
for dir in ~/projects/personal/*/; do
  (cd "$dir" && devpilot pilot repo-setup)
done
```

### Agent Shortcuts
```bash
# Add to ~/.bashrc for quick access
alias c='claude'
alias g='gemini'
alias gk='grok'
alias cx='codex'
```

### Quick Migration
```bash
# Migrate from legacy to DevPilot 2.0
cd ~/repos/devpilot
.migration/scripts/migrate-files.sh
.migration/scripts/test-migration.sh
```

## 🆘 Getting Help

- **Built-in Help**: `devpilot help` or `devpilot <command> --help`
- **Documentation**: Check `/docs` folder in the repository
- **Validation**: Run `./validation/validate_agents.sh` to check setup
- **Issues**: [GitHub Issues](https://github.com/yourusername/devpilot/issues)
- **Community**: [GitHub Discussions](https://github.com/yourusername/devpilot/discussions)

---

**Welcome to DevPilot!** You're now ready to supercharge your development with AI assistance. 🚀

*For detailed information, see the [complete documentation](../README.md).*