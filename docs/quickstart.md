# DevPilot Quickstart

**Goal**: Install DevPilot, configure AI agents, and bootstrap your first project with skill-aware settings.

## Prerequisites
- WSL (Ubuntu), Linux, or macOS shell
- Sudo access for package installs
- API keys (optional now, recommended): `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `XAI_API_KEY`

## One-Command Setup
```bash
# Clone DevPilot
git clone https://github.com/VivekLmd/setup-scripts.git ~/repos/devpilot
cd ~/repos/devpilot

# Install everything
./setup_all.sh
```

Manual Steps
```bash
# Install core tooling
./install_key_software_wsl.sh

# Install AI CLIs (Gemini, Grok, Codex)
./install_ai_clis.sh

# Global agent configuration (Claude/Gemini/Grok/Codex + templates)
./setup_agents_global.sh

# Create standard folders under ~/projects
./make_folders.sh
```

Set API Keys (optional but recommended)
```bash
# Example — add to ~/.bashrc to persist
export OPENAI_API_KEY=...
export ANTHROPIC_API_KEY=...
export GEMINI_API_KEY=...
export XAI_API_KEY=...
```

Create Your First Project
```bash
./repo_setup_wizard.sh
# choose org/category and paste the GitHub URL

# in the cloned repo
# the wizard can apply a profile and ask for Beginner teach mode; if skipped:
scripts/apply_profile.sh --skill beginner --phase mvp --teach-mode on
```

Validate
```bash
./validate_agents.sh ~/projects
```

Next Steps
- Read repo’s `CLAUDE.md` for guardrails
- Explore commands in `.claude/commands/`
- Use `system/active.md` as the layered system prompt if your CLI supports it
