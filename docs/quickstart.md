# DevPilot Quickstart

**Time to setup**: 2 minutes  
**Result**: AI-powered development environment ready to use

## Step 1: Install DevPilot

```bash
git clone https://github.com/VivekLmd/setup-scripts.git ~/devpilot
cd ~/devpilot
./setup_all.sh
```

## Step 2: Add Your First Project

```bash
./setup/repo_wizard.sh
```

Answer 3 simple questions:
1. Organization name (e.g., "work", "personal")
2. Project type (e.g., "backend", "frontend")
3. GitHub repo URL

## Step 3: Start Coding with AI

```bash
cd ~/projects/[your-project]

# Claude is ready
claude "explain this codebase"

# Gemini is ready
gemini "add error handling to main.py"

# Grok is ready
grok "write tests for the API"
```

## What Just Happened?

DevPilot configured:
- ✅ AI assistants with your project context
- ✅ Development tools (ripgrep, jq, GitHub CLI)
- ✅ Project structure and commands
- ✅ Environment auto-loading

## Optional: Add API Keys

For enhanced AI features, add to `~/.bashrc`:

```bash
export ANTHROPIC_API_KEY="your-key"
export OPENAI_API_KEY="your-key"
export GEMINI_API_KEY="your-key"
export XAI_API_KEY="your-key"
```

## Next Steps

- Run `just` in any project to see available commands
- Check `CLAUDE.md` in your project for AI guidelines
- Explore `docs/` for advanced features

**Questions?** Run `./validation/validate_agents.sh` to check your setup.