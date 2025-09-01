# DevPilot - AI-Powered Development Platform

[![CI](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml)

Transform how you work with AI coding assistants. DevPilot automatically configures Claude, Gemini, Grok, and Codex for your skill level and project needs.

## 🤔 Why DevPilot?

**Without DevPilot:**
- Manually configure each AI tool for every project
- Copy-paste the same instructions repeatedly
- No consistency across projects
- Dependencies installed differently each time
- AI doesn't understand your project structure

**With DevPilot:**
- One command sets up everything
- AI automatically knows your skill level
- Projects organized in `~/projects/work/backend/my-api`
- Dependencies detected and installed automatically
- Consistent AI behavior across all your projects

## 👀 What You Get

DevPilot works at two levels:

### 1️⃣ Global Setup (One-time, on YOUR computer)
After running `setup_all.sh`, you get:
```
Your Home Directory:
├── ~/.claude/           # Global Claude settings
├── ~/.gemini/           # Global Gemini settings
├── ~/devpilot/          # DevPilot tools & wizards
│   ├── setup/           # Project setup wizards
│   ├── scripts/         # Helper scripts
│   └── templates/       # Reusable templates
└── /usr/local/bin/      # Installed tools: ripgrep, jq, gh, etc.
```

### 2️⃣ Per-Project Setup (For EACH project)
After running `repo_wizard.sh` on a project:
```
your-project/
├── CLAUDE.md           # AI understands THIS project
├── AGENTS.md           # Consistent AI behavior
├── .claude/
│   ├── settings.json   # Project-specific permissions
│   └── commands/       # 30+ powerful commands like /think-hard
├── scripts/
│   ├── apply_profile.sh    # Change skill level anytime
│   └── run_checks.sh        # Automated quality checks
└── (your existing code, now AI-ready)
```

## 🚀 Getting Started

### Step 1: Install DevPilot Globally (One-time only!)
```bash
# This installs tools on YOUR computer, not in any project
git clone https://github.com/VivekLmd/setup-scripts.git ~/devpilot
cd ~/devpilot
./setup_all.sh
```

What this does:
- ✅ Installs development tools (ripgrep, jq, GitHub CLI, etc.)
- ✅ Creates global AI configurations in your home directory
- ✅ Sets up the DevPilot toolkit for future use
- ❌ Does NOT touch any of your projects
- ❌ Does NOT clone any repositories

### Step 2: Set Up Each Project (Run for every project)
```bash
# This sets up a SPECIFIC project with AI configurations
~/devpilot/setup/repo_wizard.sh
```

The wizard will:
1. Ask for GitHub repo URL → Clone it for you
2. Ask for organization → Organize it in `~/projects/work/backend/`
3. Ask for category → Keep similar projects together
4. Ask your skill level → Configure AI for your experience
5. Ask project phase → Configure for POC vs production

What this does:
- ✅ Clones YOUR project from GitHub
- ✅ Adds AI configuration files to THAT project
- ✅ Installs THAT project's dependencies (npm, pip, etc.)
- ✅ Sets up git hooks for THAT project
- ❌ Does NOT affect other projects
- ❌ Does NOT change global settings

## 📖 For Daily Use

### Setting Up New Projects
```bash
~/devpilot/setup/repo_wizard.sh
# Answer the prompts, everything else is automatic
```

### Changing Your Skill Level
```bash
cd your-project
scripts/apply_profile.sh --skill expert --phase production
```

### Quick Reference
| Command | What it does |
|---------|--------------|
| `~/devpilot/setup/repo_wizard.sh` | Set up a new project |
| `scripts/apply_profile.sh` | Change skill/phase settings |
| `~/devpilot/validation/validate_agents.sh` | Check all projects are configured |

## 🎯 Skill Levels Explained

DevPilot adapts to YOUR experience level:

| Level | Who it's for | What changes |
|-------|--------------|--------------|
| **vibe** | Exploring, experimenting | No restrictions, maximum freedom |
| **beginner** | Learning to code | AI teaches you, explains everything |
| **l1** | Junior developer | Structured patterns, safety rails |
| **l2** | Mid-level developer | More tools, CI/CD access |
| **expert** | Senior developer | Full power, all tools available |

## 📈 Project Phases Explained

DevPilot adapts to your PROJECT's maturity:

| Phase | When to use | What changes |
|-------|-------------|--------------|
| **poc** | Just started, exploring ideas | Move fast, break things OK |
| **mvp** | Building core features | Basic testing, simple CI |
| **beta** | Getting ready for users | Full testing, staging deploys |
| **scale** | Production with real users | Complete CI/CD, careful changes |

## 🛠️ Advanced Features

<details>
<summary><b>Pre-configured AI Commands</b> (30+ commands)</summary>

Once installed, your AI assistants have access to powerful commands:

**Thinking & Analysis:**
- `/think-hard` - Deep reasoning with structured output
- `/explore-plan-code-test` - Full development cycle
- `/security-review` - Security vulnerability analysis

**Development:**
- `/backend-feature` - API endpoint scaffolding
- `/test-driven` - TDD workflow
- `/refactor-complex` - Intelligent refactoring

**Automation:**
- `/tickets-from-code` - Generate JIRA/GitHub issues
- `/chain-runner` - Multi-step task automation
</details>

<details>
<summary><b>Development Tools Installed</b></summary>

**Core Tools:**
- `ripgrep`, `fd` - Lightning-fast search
- `jq`, `yq` - JSON/YAML processing
- `GitHub CLI` - Repository management
- `direnv` - Auto-loading environments
- `mise` - Runtime version management

**Optional Productivity Extras:**
- API Development: OpenAPI Generator, GraphQL tools
- Databases: dbt, sqlfluff, pgcli, Prisma
- ML/Data: DVC, Weights & Biases, MLflow
- Security: trivy, semgrep, gitleaks
- Kubernetes: kind, kustomize, skaffold
</details>

<details>
<summary><b>Command-Line Options</b></summary>

Skip the interactive prompts:
```bash
~/devpilot/setup/repo_wizard.sh \
  --url git@github.com:you/repo.git \
  --org work \
  --category backend \
  --skill beginner \
  --phase mvp
```

For existing projects (without cloning):
```bash
cd /your/existing/project
~/devpilot/scripts/apply_profile.sh --skill expert --phase scale
```
</details>

<details>
<summary><b>Project Organization</b></summary>

DevPilot organizes your projects intelligently:
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
</details>

## 📚 Configuration Files

<details>
<summary><b>What gets installed where</b></summary>

**Global (Home Directory):**
- `~/.claude/settings.json` - Claude global settings
- `~/.gemini/settings.json` - Gemini configuration
- `~/templates/agent-setup/` - Reusable templates

**Per Repository:**
- `CLAUDE.md` - Project-specific AI instructions
- `AGENTS.md` - General agent directives
- `.claude/settings.json` - Repository permissions
- `.claude/commands/` - Custom commands
- `.mcp.json` - MCP server configuration
</details>

## 🤝 Contributing

DevPilot is open source! Contributions welcome:
- Report issues: [GitHub Issues](https://github.com/VivekLmd/setup-scripts/issues)
- Submit PRs: Fork and create a pull request
- Share feedback: Star the repo if it helps you!

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

<p align="center">
  <i>Stop configuring. Start building.</i>
</p>
