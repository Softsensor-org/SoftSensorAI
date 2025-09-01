# DevPilot - AI-Powered Development Platform

[![CI](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/VivekLmd/setup-scripts/actions/workflows/ci.yml)

Transform how you work with AI coding assistants. DevPilot automatically configures Claude, Codex, Gemini, Grok, and Copilot for your skill level and project needs - with full parity across all platforms.

## 📋 System Requirements

**Supported Systems:**
- ✅ **Linux** (Ubuntu 20.04+, Debian, Fedora, Arch)
- ✅ **macOS** (Intel & Apple Silicon)
- ✅ **Windows** (via WSL2)
- ✅ **Dev Containers** (GitHub Codespaces, VS Code Remote)
- ✅ **Cloud IDEs** (Gitpod, Cloud9, Coder)

**Prerequisites:**
- `bash` 4.0+ (check with `bash --version`)
- `git` 2.0+ (check with `git --version`)
- Internet connection for tool downloads
- 2GB free disk space

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

**What gets installed:**

Essential Development Tools:
- `git` - Version control
- `gh` - GitHub CLI for PR/issue management
- `curl`, `wget` - Download tools
- `ripgrep` (rg) - Ultra-fast code search
- `fd` - Fast file finder
- `jq` - JSON processor
- `yq` - YAML processor
- `fzf` - Fuzzy finder for interactive selection
- `direnv` - Auto-load project environments
- `mise` - Manage Python/Node/Ruby versions

AI Agent Configurations:
- Claude settings and commands
- Gemini configurations
- Grok settings
- Codex integration

What this does:
- ✅ Installs ALL the tools above globally
- ✅ Creates AI configurations in ~/.claude, ~/.gemini, etc.
- ✅ Sets up the DevPilot toolkit in ~/devpilot
- ❌ Does NOT touch any of your projects
- ❌ Does NOT clone any repositories

**You'll see prompts like:**
```
==> Installing core dependencies...
  ✓ git (already installed)
  ✓ GitHub CLI (installing...)
  ✓ ripgrep (installing...)
==> Setting up AI agents...
  ✓ Claude configuration
  ✓ Gemini configuration
==> Setup complete! Next: run repo_wizard.sh for your projects
```

### Step 2: Set Up Each Project (Run for every project)
```bash
# This sets up a SPECIFIC project with AI configurations
~/devpilot/setup/repo_wizard.sh
```

The wizard will ask you:

1. **GitHub repo URL** → `https://github.com/you/your-project`
   - It will clone this for you

2. **Organization** → Choose or create:
   - `1) org1` - Default organization
   - `2) org2` - Secondary organization
   - `3) work` - Professional projects
   - `4) personal` - Side projects
   - `5) learning` - Tutorials/courses
   - Or type your own: `client-name`, `startup`, etc.

3. **Category** → Choose or create:
   - `1) backend` - API services, servers
   - `2) frontend` - Web apps, UIs
   - `3) mobile` - iOS/Android apps
   - `4) infra` - DevOps, infrastructure
   - `5) ml` - Machine learning projects
   - `6) data` - Data pipelines, analytics
   - Or type your own: `microservice`, `cli-tool`, etc.

4. **Your skill level** → `2` for beginner (shows all options)

5. **Project phase** → `2` for MVP (shows all options)

**What you'll actually see when running the wizard:**
```
==> Repo Setup Wizard
==> Enter repository URL: https://github.com/acme/api-gateway
==> Select organization:
  1) org1
  2) org2
  3) work
  4) personal
  5) learning
  Or type a custom name: 3
==> Select category:
  1) backend
  2) frontend
  3) mobile
  4) infra
  5) ml
  6) data
  Or type a custom name: 1
==> Cloning repository → ~/projects/work/backend/api-gateway
==> Bootstrapping project dependencies...
  Found: Node.js (package.json)
  ✓ Dependencies installed: Node modules
==> Select skill level:
  1) vibe      - Vibecoding: minimal structure, maximum freedom
  2) beginner  - Learning mode with detailed guidance
  3) l1        - Junior developer level
  4) l2        - Mid-level developer
  5) expert    - Senior developer, minimal hand-holding
Enter choice (1-5) [2]: 3
==> Select project phase:
  1) poc    - Proof of concept, rapid prototyping
  2) mvp    - Minimum viable product
  3) beta   - Beta testing, stabilization
  4) scale  - Production, scaling focus
Enter choice (1-4) [2]: 2
==> Applying profile: skill=l1 phase=mvp...
✓ Profile applied
✓ Setup complete!
```

**Where your project ends up:**
```
~/projects/
├── work/
│   ├── backend/
│   │   ├── api-gateway/      # Your cloned project
│   │   └── user-service/     # Another project
│   └── frontend/
│       └── admin-dashboard/
└── personal/
    └── mobile/
        └── fitness-app/
```

What this does:
- ✅ Clones YOUR project to an organized location
- ✅ Adds AI configuration files to THAT project
- ✅ Auto-detects and installs dependencies:
  - **Node.js**: npm, pnpm, yarn, bun
  - **Python**: pip, poetry, uv (creates .venv)
  - **Ruby**: bundler
  - **Rust**: cargo
  - **Go**: go mod
  - **Java**: maven, gradle
- ✅ Sets up git hooks for THAT project
- ✅ Configures direnv for auto-environment loading
- ❌ Does NOT affect other projects
- ❌ Does NOT change global settings

## 📖 For Daily Use

### Commands You'll Use Most Often

| Command | What it does | When to use |
|---------|--------------|-------------|
| `~/devpilot/setup/repo_wizard.sh` | Set up a new project | Starting work on any repo |
| `scripts/apply_profile.sh` | Change skill/phase | Your experience changes |
| `rg "search term"` | Lightning-fast code search | Finding code patterns |
| `fd filename` | Fast file search | Locating files |
| `gh pr create` | Create pull request | Ready to merge |
| `gh issue create` | Create GitHub issue | Tracking bugs/features |

### In Your AI Assistant (Claude/Cursor)

Once set up, these commands work automatically:
- `/think-hard` - Deep analysis of complex problems
- `/explore-plan-code-test` - Full feature development
- `/backend-feature` - Generate API endpoints
- `/test-driven` - Write tests first, then code
- `/security-review` - Check for vulnerabilities
- `/refactor-complex` - Restructure messy code

### Setting Up New Projects
```bash
~/devpilot/setup/repo_wizard.sh
# You'll see these prompts:
# > Enter GitHub URL: https://github.com/you/project
# > Select organization (1-5): 3  [for 'work']
# > Select category (1-6): 1      [for 'backend']
# > Select skill level (1-5): 2   [for 'beginner']
# > Select project phase (1-4): 2 [for 'mvp']
```

### Changing Settings Later
```bash
cd your-project
scripts/apply_profile.sh --skill expert --phase production
```

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

## 🧠 AI Command System - Your Productivity Multiplier

DevPilot provides **60+ specialized AI commands** that transform how Claude, Cursor, and other AI assistants work. These aren't just prompts - they're battle-tested workflows that ensure consistent, high-quality outputs.

### How Commands Work

When you type `/command-name` in Claude or Cursor, it loads a structured prompt that:
1. Sets the right context and constraints
2. Defines clear success criteria
3. Specifies exact output format
4. Includes validation steps

### Command Categories

<details>
<summary><b>🤔 Thinking & Analysis Commands</b></summary>

Deep reasoning and problem-solving:
- `/think-hard` - Extended analysis with decision matrices
- `/think-deep` - Step-by-step reasoning chains
- `/cot-structured` - Chain-of-thought with structured output
- `/explore-plan-code-test` - Full SDLC cycle

Example usage:
```
You: /think-hard Should we use microservices or monolith?
Claude: [Provides detailed analysis with trade-offs, risks, recommendations]
```
</details>

<details>
<summary><b>🔧 Development Pattern Commands</b></summary>

19 specialized patterns for common tasks:
- `/backend-feature` - API endpoint with tests
- `/frontend-feature` - Component-first UI development
- `/bug-fix` - Test-first debugging
- `/safe-refactor` - Behavior-preserving restructuring
- `/test-first` - TDD workflow
- `/api-contract` - OpenAPI/GraphQL schemas
- `/sql-migration` - Safe database changes
- `/data-pipeline` - ETL workflows
- `/ml-experiment` - Reproducible ML experiments
- `/performance-pass` - Profiling and optimization

Example:
```
You: /backend-feature Add user authentication endpoint
Claude: [Creates tests → implements endpoint → validates → creates PR]
```
</details>

<details>
<summary><b>🔒 Security & Quality Commands</b></summary>

Security and code quality:
- `/security-review` - Comprehensive vulnerability scan
- `/secure-fix` - Security-focused fixes
- `/audit-full` - Complete codebase audit
- `/audit-quick` - Rapid quality check
- `/pr-self-review` - Pre-submission checklist

Example:
```
You: /security-review
Claude: [Scans for OWASP Top 10, checks dependencies, reviews auth]
```
</details>

<details>
<summary><b>🔗 Multi-Step Chain Commands</b></summary>

Complex workflows broken into steps:

**Backend Chain** (5 steps):
1. `/backend-1-spec` - Define requirements
2. `/backend-2-tests` - Write tests first
3. `/backend-3-code` - Implement feature
4. `/backend-4-verify` - Validate everything
5. `/backend-5-pr` - Create pull request

**Security Chain** (4 steps):
1. `/security-1-scan` - Identify vulnerabilities
2. `/security-2-prioritize` - Risk assessment
3. `/security-3-fix` - Apply fixes
4. `/security-4-report` - Generate report

**ML Chain** (5 steps):
1. `/ml-1-profile` - Data profiling
2. `/ml-2-features` - Feature engineering
3. `/ml-3-model` - Model training
4. `/ml-4-evaluate` - Performance metrics
5. `/ml-5-errors` - Error analysis

Example:
```
You: Run the backend chain for payment processing
Claude: Starting step 1 of 5... [Guides through entire workflow]
```
</details>

<details>
<summary><b>📋 Ticket & Documentation Commands</b></summary>

Project management:
- `/tickets-from-code` - Generate JIRA/GitHub issues from code
- `/tickets-quick-scan` - Rapid backlog creation
- `/ticket-quality-gates` - Define acceptance criteria
- `/release-changelog` - Generate release notes
- `/postmortem` - Incident analysis template

Example:
```
You: /tickets-from-code
Claude: [Analyzes code, generates prioritized tickets with estimates]
```
</details>

<details>
<summary><b>🚀 Automation Commands</b></summary>

Task automation:
- `/chain-runner` - Execute multi-step workflows
- `/parallel-map` - Parallel task processing
- `/long-context-map-reduce` - Handle large codebases

Example:
```
You: /parallel-map Update all test files
Claude: [Processes multiple files simultaneously]
```
</details>

### How to Use Commands

**In Claude/Cursor:**
1. Type `/` to see available commands
2. Select or type the command name
3. The AI loads the specialized prompt
4. You get consistent, high-quality outputs

**View command details:**
```bash
# See all available commands
ls ~/.claude/commands/

# Read a specific command
cat ~/.claude/commands/think-hard.md

# List pattern commands
ls ~/.claude/commands/patterns/

# Use pattern selector for interactive choice
scripts/pattern_selector.sh
```

### Why These Commands Matter

1. **Consistency**: Same high-quality output every time
2. **Best Practices**: Encoded expertise from senior developers
3. **Speed**: No need to write detailed prompts
4. **Learning**: Each command teaches better development practices
5. **Customizable**: Modify commands to fit your workflow

### Creating Custom Commands

Add your own commands:
```bash
# Create in your project
echo "Your custom prompt" > .claude/commands/my-command.md

# Or globally
echo "Your custom prompt" > ~/.claude/commands/my-command.md
```

## 🛠️ Advanced Features

<details>
<summary><b>Development Tools Installed</b></summary>

**Core Tools:**
- `ripgrep`, `fd` - Lightning-fast search
- `jq`, `yq` - JSON/YAML processing
- `GitHub CLI` - Repository management
- `direnv` - Auto-loading environments
- `mise` - Runtime version management

**Optional Productivity Extras:**

Install additional tools based on your needs:
```bash
# Install ALL productivity extras (takes ~10 minutes)
~/devpilot/install/productivity_extras.sh

# Or install specific categories:
~/devpilot/install/productivity_extras.sh --api      # API tools
~/devpilot/install/productivity_extras.sh --data     # Data/ML tools
~/devpilot/install/productivity_extras.sh --security # Security scanners
~/devpilot/install/productivity_extras.sh --k8s      # Kubernetes tools
```

What each category includes:
- **API**: OpenAPI Generator, GraphQL CLI, Postman CLI, Newman
- **Data**: dbt, sqlfluff, pgcli, DVC, MLflow, Weights & Biases
- **Security**: trivy, semgrep, gitleaks, hadolint
- **K8s**: kind, kustomize, skaffold, helm, k9s
- **Databases**: Prisma, Drizzle, migration tools
- **Quality**: prettier, eslint, black, ruff, mypy
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

## 🧰 Additional Power Tools

DevPilot includes many advanced tools not covered above:

### Diagnostics & Health Checks
```bash
# Check your entire environment setup
~/devpilot/scripts/doctor.sh
# Output: Shows status of all tools, versions, and configurations

# Show your current profile settings
scripts/profile_show.sh
# Output: Current skill level, phase, and active configurations

# Validate all AI agent configurations across projects
~/devpilot/validation/validate_agents.sh --fix
# Finds and fixes missing configurations automatically
```

### Skill Progression
```bash
# Track your progress toward next skill level
scripts/graduate.sh
# Shows checklist of skills to master

# Mark skills as completed
scripts/graduate.sh complete 1  # Complete first skill
scripts/graduate.sh ready       # Check if ready to advance
scripts/graduate.sh advance     # Graduate to next level
```

### Project Planning & Analysis
```bash
# Preview what would be created WITHOUT making changes
~/devpilot/scripts/repo_plan.sh ~/projects work backend my-api https://github.com/you/api

# Analyze codebase and generate tickets
scripts/generate_tickets.sh --mode detailed --format markdown
# Creates prioritized backlog of improvements

# Detect your project's tech stack
scripts/detect_stack.sh
# Identifies languages, frameworks, and tools in use
```

### Task Automation
```bash
# Chain multiple commands together
scripts/chain_runner.sh "task1.yaml"
# Runs complex multi-step workflows

# Select and apply design patterns
scripts/pattern_selector.sh
# Interactive pattern selection for common architectures
```

### Git Worktree Management
```bash
# Manage multiple branches simultaneously
~/devpilot/tools/worktree_helper.sh add feature-branch
~/devpilot/tools/worktree_helper.sh list
~/devpilot/tools/worktree_helper.sh remove feature-branch
```

### Templates & Scaffolding

DevPilot includes templates for:
- **Justfile**: Task runner configuration with pre-defined recipes
- **CLAUDE.md**: AI instruction templates for different project types
- **.devcontainer**: VS Code container configurations
- **Tickets**: GitHub/JIRA issue templates
- **.mise.toml**: Runtime version management
- **CI/CD**: GitHub Actions workflows for testing and security

Access templates:
```bash
ls ~/devpilot/templates/
cp ~/devpilot/templates/justfile ./

# Copy GitHub Actions workflows
cp ~/devpilot/.github/workflows/ci.yml .github/workflows/
cp ~/devpilot/.github/workflows/security-review.yml .github/workflows/
```

### AI CLI Tools
```bash
# Install additional AI command-line tools
~/devpilot/install/ai_clis.sh
# Installs: aider, sgpt, chatgpt-cli, and more

# Install Codex CLI (sandboxed AI execution)
~/devpilot/install/codex_cli.sh
# Provides safe, isolated AI code execution

# Run Codex in sandbox (requires Docker)
scripts/codex_sandbox.sh
# Executes AI-generated code in isolated container
```

### Language-Specific Stacks
```bash
# Install entire language ecosystems
~/devpilot/install/stacks.sh --with-api   # API development stack
~/devpilot/install/stacks.sh --with-ml    # Machine learning stack
~/devpilot/install/stacks.sh --with-sec   # Security tools stack
~/devpilot/install/stacks.sh --with-k8s   # Kubernetes stack
~/devpilot/install/stacks.sh --all        # Everything
```

## 🐳 Dev Container Support

DevPilot works seamlessly in containerized environments:

### GitHub Codespaces
```bash
# In your Codespace terminal
git clone https://github.com/VivekLmd/setup-scripts.git ~/devpilot
cd ~/devpilot
./setup_all.sh
```

### VS Code Dev Containers
Add to `.devcontainer/devcontainer.json`:
```json
{
  "postCreateCommand": "git clone https://github.com/VivekLmd/setup-scripts.git ~/devpilot && ~/devpilot/setup_all.sh",
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/common-utils:2": {}
  }
}
```

### Docker
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y git curl
RUN git clone https://github.com/VivekLmd/setup-scripts.git /devpilot
RUN cd /devpilot && ./setup_all.sh
```

## 🔧 Troubleshooting

### Common Issues

**"Command not found" after installation**
```bash
# Reload your shell configuration
source ~/.bashrc  # or ~/.zshrc for Zsh
```

**"Permission denied" errors**
```bash
# Some tools need sudo for global installation
sudo ~/devpilot/install/key_software_$(uname -s | tr '[:upper:]' '[:lower:]').sh
```

**Wizard can't find apply_profile.sh**
```bash
# Pull latest fixes
cd ~/devpilot
git pull origin main
```

**Dependencies not installing**
```bash
# Check your package manager is working
which npm   # For Node projects
which pip   # For Python projects

# Install missing package managers
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash  # Node
python3 -m ensurepip  # Python
```

**AI commands not working in Claude/Cursor**
- Ensure `.claude/commands/` exists in your project
- Check `.claude/settings.json` has proper permissions
- Run `scripts/apply_profile.sh` to reapply configuration

### Getting Help
- Check existing issues: [GitHub Issues](https://github.com/VivekLmd/setup-scripts/issues)
- Review the [validation script](validation/validate_agents.sh) output
- Run diagnostics: `~/devpilot/scripts/diagnose.sh`

## 🤝 Support & Feedback

- **Report Issues**: [GitHub Issues](https://github.com/VivekLmd/setup-scripts/issues)
- **Feature Requests**: Create an issue with [Feature Request] tag
- **Questions**: Open a discussion in the Issues tab
- **Star the repo** if it helps your productivity!

---

<p align="center">
  <i>Stop configuring. Start building.</i>
</p>
