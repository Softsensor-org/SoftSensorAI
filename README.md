# DevPilot - AI-Powered Development Platform

[![CI](https://github.com/Softsensor-org/DevPilot/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Softsensor-org/DevPilot/actions/workflows/ci.yml)

Transform how you work with AI coding assistants. DevPilot automatically configures Claude, Codex,
Gemini, Grok, and Copilot for your skill level and project needs - with full parity across all
platforms.

## 🆕 Latest Features

- **🎯 Multi-Persona System** - Combine multiple AI personas (Data Scientist, Software Architect,
  etc.)
- **🎮 GPU Detection & Optimization** - Automatic NVIDIA/AMD/Apple Silicon detection with ML
  insights
- **🤖 AI Frameworks** - One-command installation of LangChain, AutoGen, CrewAI
- **🔒 Checksum Verification** - Secure downloads with SHA256/SHA1/MD5 verification
- **🧪 Sandboxed Execution** - Safe execution environment for AI-generated code

## 📋 System Requirements

**Supported Systems:** ([Full compatibility guide](docs/OS_COMPATIBILITY.md))

- ✅ **Linux** (Ubuntu 20.04+, Debian, Fedora, RHEL/CentOS/Rocky, Arch, Alpine)
- ✅ **macOS** (Intel & Apple Silicon)
- ✅ **Windows** (via WSL2, limited support for Cygwin/MinGW/MSYS)
- ✅ **BSD** (FreeBSD, OpenBSD, NetBSD)
- ✅ **Dev Containers** (GitHub Codespaces, VS Code Remote)
- ✅ **Cloud IDEs** (Gitpod, Cloud9, Coder)
- ✅ **Unix** (Solaris/illumos - experimental)

**Prerequisites:**

- `bash` 4.0+ (check with `bash --version`)
- `git` 2.0+ (check with `git --version`)
- Internet connection for tool downloads
- 2GB free disk space

## 🚀 What DevPilot Actually Unlocks

### Concrete Gains (Measurable Impact)

| **Pain Today**                      | **DevPilot Capability**                       | **Typical Impact**                                    |
| ----------------------------------- | --------------------------------------------- | ----------------------------------------------------- |
| Inconsistent AI prompts per dev     | Single prompt stack (`system/active.md`)      | ↓ variance, fewer "why did it say that?" moments      |
| Spinning up a repo takes hours      | Repo wizard + profiles/phases                 | **60-90 min → 10-15 min**                             |
| Backlog grooming is slow/subjective | `/tickets-from-code` → strict JSON/CSV        | **2-3 hrs PM time → 10-15 min**                       |
| Long PRs stall reviews              | AI PR reviewer (CLI-first, neutral if absent) | First pass in **~1-2 min**, humans focus on hard bits |
| Security posture unclear            | Phase gates (gitleaks/semgrep/trivy)          | **Faster triage**, **fewer regressions** at Beta+     |
| Knowledge is tribal                 | SOP commands with acceptance criteria         | **Better handoffs**, faster onboarding                |
| Compliance needs evidence           | All outputs in `artifacts/`, prompt history   | **Full audit trail** for SOC2/ISO (see BENEFITS.md)   |

### What You Can Do Now (That You Couldn't Before)

- **Turn any codebase into an actionable plan** in one shot with `/tickets-from-code`
- **Make architecture reviews reproducible** with `/architect-spike`
- **Digest 10k-line diffs/logs** with `/long-context-map-reduce`
- **Enforce maturity, not opinions** - Beta repos block HIGH/CRIT vulns automatically
- **Run AI reviews in CI without secrets** - Stock CLIs, neutral fallback
- **Onboard juniors at senior velocity** - Commands encode senior expectations

### Why DevPilot vs "Just Using CLIs"

1. **Deterministic org-wide AI behavior** - One canonical system file across
   Claude/Codex/Gemini/Grok
2. **Policy-as-code** - Profiles & Phases change commands and CI gates automatically
3. **SOP-grade commands** - Not ad-hoc prompting but repeatable processes with "done" checks
4. **CLI-first, zero-secrets CI** - AI reviews without API keys in repos
5. **Scaled onboarding** - Seed dozens of repos identically in minutes
6. **Evidence & auditability** - All outputs materialized under `artifacts/` for compliance
7. **Cross-provider portability** - Switch providers with no process change

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

### Step 0: Check Your System (Optional but Recommended)

Before installing, run our diagnostic tool to ensure your system is ready:

```bash
# Option 1: If you have access to the repository, clone and run locally
git clone https://github.com/Softsensor-org/DevPilot.git ~/devpilot
bash ~/devpilot/scripts/doctor.sh

# Option 2: Quick download and run (when repository is public)
# curl -sL https://raw.githubusercontent.com/Softsensor-org/DevPilot/main/scripts/doctor.sh | bash
```

**All green? You're ready!** 🟢

```
✓ OS: Linux (supported)
✓ Shell: bash 5.1.16
✓ Git: 2.34.1
✓ Package manager: apt (available)
✓ Python: 3.10.12
✓ Node.js: 18.17.0
✓ Docker: 24.0.5 (running)
✓ GPU: NVIDIA RTX 4090 (CUDA 12.2)
✓ Disk space: 42G available

All checks passed! Ready for DevPilot installation.
```

### Step 1: Install DevPilot Globally (One-time only!)

```bash
# This installs tools on YOUR computer, not in any project
git clone https://github.com/Softsensor-org/DevPilot.git ~/devpilot
cd ~/devpilot
./setup_all.sh

# Optional: Only if building AI/ML applications
# ./scripts/install_ai_frameworks.sh  # Skip for web/backend projects
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
- Codex integration with sandboxed execution

AI Development Environment: **[Optional Module]**

- GPU detection (NVIDIA CUDA, AMD ROCm, Apple Silicon)
- AI frameworks (LangChain, AutoGen, CrewAI)
- Vector databases (ChromaDB, FAISS)
- Secure package verification

> 💡 **Not building AI/ML?** Skip this module - it's completely optional. See
> [AI Frameworks Guide](docs/AI_FRAMEWORKS.md) if you need it later.

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

### Step 2: Set Up Your Project

#### Option A: Existing Repository (Recommended for Teams)

If you already have a cloned repository, use this approach:

```bash
# Navigate to your existing project
cd /path/to/your/project

# Run setup without cloning
~/devpilot/setup/existing_repo_setup.sh --skill l1 --phase mvp

# Add personas for your project type (e.g., backend API)
for p in software-architect backend-developer devops-engineer; do
  ~/devpilot/scripts/persona_manager.sh add $p
done

# Check what got configured
scripts/profile_show.sh
```

#### Option B: New Repository (Clone and Setup)

If you need to clone a repository first:

```bash
# Run the interactive wizard
~/devpilot/setup/repo_wizard.sh

# After setup completes, verify your configuration
cd /path/to/cloned/project
scripts/profile_show.sh
```

> **Note**: AI review features require a CLI to be installed (claude, codex, gemini, or grok). If no
> CLI is found, the workflow will exit neutrally without failing your CI.

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

> **🚀 New!** Check out the [After Clone Playbook](docs/after-clone-playbook.md) for a complete
> 10-minute repo review workflow

### Commands You'll Use Most Often

| Command                           | What it does               | When to use               |
| --------------------------------- | -------------------------- | ------------------------- |
| `~/devpilot/setup/repo_wizard.sh` | Set up a new project       | Starting work on any repo |
| `scripts/apply_profile.sh`        | Change skill/phase         | Your experience changes   |
| `just review-local`               | AI review of your changes  | Before opening PR         |
| `just tickets`                    | Generate tickets from code | Planning sprint work      |
| `rg "search term"`                | Lightning-fast code search | Finding code patterns     |
| `fd filename`                     | Fast file search           | Locating files            |
| `gh pr create`                    | Create pull request        | Ready to merge            |
| `gh issue create`                 | Create GitHub issue        | Tracking bugs/features    |

### In Your AI Assistant (Claude/Cursor)

Once set up, these commands work automatically:

- `/think-hard` - Deep analysis of complex problems
- `/explore-plan-code-test` - Full feature development
- `/backend-feature` - Generate API endpoints
- `/test-driven` - Write tests first, then code
- `/security-review` - Check for vulnerabilities
- `/refactor-complex` - Restructure messy code

**How it works under the hood:**

```
system/active.md    → Sets baseline behavior (skill level, phase)
.claude/commands/*  → Specialized prompts for each command
```

### Setting Up Projects

**For existing repos (most teams):**

```bash
cd your-project
~/devpilot/setup/existing_repo_setup.sh --skill l2 --phase beta
```

**For new repos (need to clone):**

```bash
~/devpilot/setup/repo_wizard.sh
# Prompts: URL, organization, category, skill, phase
```

### Changing Settings Later

```bash
cd your-project
scripts/apply_profile.sh --skill expert --phase scale
```

### AI PR Review (Optional)

Enable automatic AI-powered PR reviews without API keys:

```bash
# Set repository variable for all PRs
gh variable set AI_REVIEW_ENABLED --body true

# Or add label to specific PRs
gh pr edit 123 --add-label ai-review
```

See [CI Integrations](docs/ci.md#ai-pr-review-setup) for details.

## 🎯 Skill Levels Explained

DevPilot adapts to YOUR experience level:

| Level        | Who it's for             | What changes                        |
| ------------ | ------------------------ | ----------------------------------- |
| **vibe**     | Exploring, experimenting | No restrictions, maximum freedom    |
| **beginner** | Learning to code         | AI teaches you, explains everything |
| **l1**       | Junior developer         | Structured patterns, safety rails   |
| **l2**       | Mid-level developer      | More tools, CI/CD access            |
| **expert**   | Senior developer         | Full power, all tools available     |

## 📈 Project Phases Explained

DevPilot adapts to your PROJECT's maturity:

| Phase     | When to use                   | What changes                    |
| --------- | ----------------------------- | ------------------------------- |
| **poc**   | Just started, exploring ideas | Move fast, break things OK      |
| **mvp**   | Building core features        | Basic testing, simple CI        |
| **beta**  | Getting ready for users       | Full testing, staging deploys   |
| **scale** | Production with real users    | Complete CI/CD, careful changes |

## 🎭 AI Personas - Specialized Expertise

DevPilot's **Multi-Persona System** lets you activate specialized AI personalities that understand
domain-specific best practices. You can combine multiple personas for comprehensive assistance.

### Available Personas

| Persona                | Specialization    | Key Features                                                    |
| ---------------------- | ----------------- | --------------------------------------------------------------- |
| **data-scientist**     | ML/AI Development | GPU optimization, distributed training, process impact analysis |
| **software-architect** | System Design     | Architecture reviews, scalability patterns, performance audits  |
| **backend-developer**  | API Development   | CRUD operations, authentication, database optimization          |
| **frontend-developer** | UI/UX Development | Component design, state management, accessibility               |
| **devops-engineer**    | Infrastructure    | CI/CD, monitoring, deployment automation                        |
| **security-engineer**  | Security          | Vulnerability scanning, authentication, encryption              |

### Managing Personas

```bash
# Add a single persona
./scripts/persona_manager.sh add data-scientist

# View active personas
./scripts/persona_manager.sh show
```

### Persona Starter Stacks

Quick setup for common project types:

| Project Type        | Personas to Add                      | One-Line Setup                                                                                                                           |
| ------------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **Backend API**     | architect, backend, devops           | `for p in software-architect backend-developer devops-engineer; do ~/devpilot/scripts/persona_manager.sh add $p; done`                   |
| **Microservices**   | architect, backend, devops, security | `for p in software-architect backend-developer devops-engineer security-engineer; do ~/devpilot/scripts/persona_manager.sh add $p; done` |
| **ML/Data Science** | data-scientist, backend, devops      | `for p in data-scientist backend-developer devops-engineer; do ~/devpilot/scripts/persona_manager.sh add $p; done`                       |
| **Full Stack App**  | frontend, backend, devops            | `for p in frontend-developer backend-developer devops-engineer; do ~/devpilot/scripts/persona_manager.sh add $p; done`                   |
| **Infrastructure**  | devops, security, architect          | `for p in devops-engineer security-engineer software-architect; do ~/devpilot/scripts/persona_manager.sh add $p; done`                   |

### Persona-Specific Commands

Each persona adds specialized commands:

**Data Scientist:**

- `/gpu-optimize` - Optimize code for GPU execution
- `/parallel-explain` - Explain parallelization strategies
- `/process-impact` - Analyze process termination impact

**Software Architect:**

- `/architecture-review` - Review system design
- `/performance-audit` - Identify bottlenecks
- `/scalability-assessment` - Evaluate scaling strategies

### Full Codex Integration

Codex has complete parity with Claude, including:

- Same persona system and configurations
- Repository-specific settings
- Sandboxed execution for safety
- Unified command structure

See [Codex Integration Guide](docs/CODEX_INTEGRATION.md) and
[Multi-Persona Guide](docs/MULTI_PERSONA_GUIDE.md) for details.

## 🔒 CI/CD Security Gates by Phase

Quick reference for what gets enforced at each project phase:

| Security Tool          | POC      | MVP      | Beta                     | Scale              |
| ---------------------- | -------- | -------- | ------------------------ | ------------------ |
| **Unit Tests**         | Optional | Required | Required                 | Required           |
| **Linting**            | Optional | Required | Required                 | Required           |
| **Coverage**           | None     | None     | ≥ 60%                    | ≥ 80%              |
| **Gitleaks** (secrets) | None     | Advisory | **Blocks any**           | **Blocks any**     |
| **Semgrep** (SAST)     | None     | Advisory | **Blocks HIGH+**         | **Blocks MEDIUM+** |
| **Trivy** (containers) | None     | Advisory | **Blocks CRITICAL/HIGH** | **Blocks all**     |
| **License Check**      | None     | None     | Check                    | **Enforce**        |
| **Dependency Audit**   | None     | Advisory | **Blocks HIGH+**         | **Blocks all**     |

**CI Pipeline Behavior:**

- **Default CI** (this repo): Light validation - shellcheck, basic tests
- **Phase CI** (your projects): Full security gates activated by `apply_profile.sh`
- Run `scripts/apply_profile.sh --phase beta` to install strict CI with blocking gates

**Managing Legacy Issues:**

- Set `SEMGREP_BASELINE_REF` repo variable to suppress pre-existing findings
- Create `.trivyignore` file to suppress known/accepted CVEs
- Use `scripts/apply_profile.sh --phase beta` to change enforcement level

## 🚀 AI Development Environment **[Optional Module]**

> **Note:** This section is for AI/ML projects only. Most web/backend projects can skip this
> entirely. Run `~/devpilot/scripts/install_ai_frameworks.sh` only if you need ML capabilities.

DevPilot includes comprehensive AI/ML development support with GPU acceleration and secure package
management.

### GPU Detection & Optimization

DevPilot automatically detects your GPU hardware and optimizes installations:

- **NVIDIA GPUs** - CUDA detection and PyTorch CUDA builds
- **AMD GPUs** - ROCm support for ML workloads
- **Apple Silicon** - Metal Performance Shaders optimization
- **CPU Fallback** - Optimized CPU builds when no GPU detected

The setup script automatically detects your hardware:

```bash
./setup_all.sh
# Output: Detected GPU: NVIDIA: RTX 4090 (CUDA 12.1)
```

### AI Frameworks Installer

Install a complete AI development stack with one command:

```bash
./scripts/setup_ai_frameworks.sh
```

Includes:

- **LLM APIs**: OpenAI, Anthropic, Groq, Mistral
- **Frameworks**: LangChain, AutoGen, CrewAI, LangGraph
- **ML Tools**: PyTorch, Transformers, scikit-learn
- **Vector DBs**: ChromaDB, FAISS
- **Dev Tools**: Jupyter, Streamlit, Gradio

See [AI Frameworks Guide](docs/AI_FRAMEWORKS.md) for detailed setup.

### Secure Downloads

All downloads now support checksum verification for security:

```bash
source utils/checksum_verify.sh
download_and_verify "$url" "$file" "$sha256_checksum"
```

See [Security Guide](docs/SECURITY.md#checksum-verification) for details.

## 🧠 AI Command System - Your Productivity Multiplier

DevPilot provides **60+ specialized AI commands** that transform how Claude, Cursor, and other AI
assistants work. These aren't just prompts - they're battle-tested workflows that ensure consistent,
high-quality outputs.

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

**CLI Integration:**

```bash
# Use AI command files with CLI-first approach
just tickets                          # Uses .claude/commands/tickets-from-code.md
scripts/generate_tickets.sh --quick   # Direct CLI execution

# Outputs (integration-ready):
# tickets/tickets.json      - Raw AI output
# tickets/backlog.csv       - Import to Jira/GitHub
# tickets/backlog.md        - Human-readable
# tickets/quick-wins.md     - Low effort, high impact
# tickets/pr-plan.md        - Implementation roadmap
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

<details>
<summary><b>Project Profiles</b></summary>

DevPilot supports per-project customization through profile YAML files:

```yaml
# .devpilot/project.yml
project:
  name: ocr-service
  type: ml-pipeline

profiles:
  default_phase: beta
  default_skill: l2

  # Project-specific thresholds
  thresholds:
    min_coverage: 75
    min_dprs_score: 80
    min_schema_pass_rate: 0.95 # OCR accuracy requirement
    max_response_time_ms: 500

  # Active personas for this project
  personas:
    - ml-engineer
    - backend-developer
    - devops-engineer

  # Security requirements
  security:
    require_secrets_scan: true
    block_on_high_vulns: true
    allowed_licenses:
      - MIT
      - Apache-2.0
      - BSD-3-Clause

  # Custom quality gates
  quality_gates:
    - name: "OCR Accuracy"
      command: "python tests/accuracy_test.py"
      threshold: 0.95
    - name: "API Performance"
      command: "just benchmark"
      threshold: "p99 < 500ms"
```

Apply project-specific settings:

```bash
# Load project profile
devpilot profile --from-file .devpilot/project.yml

# Or auto-detect and apply
devpilot setup --auto-detect
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
# Check your entire environment setup (already covered in Step 0)
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
# IMPORTANT: Preview setup without making changes (dry run)
~/devpilot/scripts/repo_plan.sh ~/projects work backend my-api https://github.com/you/api
# Shows exactly what files would be created, where they'd go

# Then run actual setup after reviewing the plan
~/devpilot/setup/repo_wizard.sh --dry-run  # Preview first
~/devpilot/setup/repo_wizard.sh            # Actual setup

# Generate tickets from codebase (CLI-first, JSON→CSV)
scripts/generate_tickets.sh --quick
# Output: tickets/tickets.json, tickets/backlog.csv, tickets/backlog.md

# Or use justfile shortcut
just tickets
# Same output, uses system/active.md + command files

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

- Check existing issues: [GitHub Issues](https://github.com/Softsensor-org/DevPilot/issues)
- Review the [validation script](validation/validate_agents.sh) output
- Run diagnostics: `~/devpilot/scripts/diagnose.sh`

## 🧪 Testing & CI

DevPilot includes comprehensive testing across all supported platforms:

### OS Compatibility Testing

- **Automated CI Tests**: Runs on every push and PR
- **Test Matrix**: Ubuntu, macOS, Windows (WSL), and 6+ container environments
- **Local Testing**: Run `./tests/test_os_compatibility.sh` to validate your system
- **Full Guide**: See [OS Compatibility Guide](docs/OS_COMPATIBILITY.md)

### CI Workflows

- **Quality Gates**: Linting, type checking, unit tests
- **Security Scanning**: Dependency audits, secret detection
- **OS Compatibility**: Cross-platform validation
- **AI PR Review**: Automated code review (when AI CLI available)

View test results:
[![CI](https://github.com/Softsensor-org/DevPilot/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Softsensor-org/DevPilot/actions/workflows/ci.yml)

## 📚 Essential Reading

### Getting Started

- **[DevPilot Overview (PDF)](docs/DevPilot.pdf)** - Comprehensive platform overview and strategy
- **[Day in the Life Guide](tutorials/day-in-the-life.md)** - See real before/after scenarios
- **[Quick Start This Week](tutorials/quick-start-this-week.md)** - Start seeing value in 5 days
- **[Benefits & ROI](docs/BENEFITS.md)** - Detailed metrics and cost savings

### Deep Dives

- **[OS Compatibility](docs/OS_COMPATIBILITY.md)** - Platform support and testing
- **[Security Guide](docs/SECURITY.md)** - Comprehensive security practices
- **[Architecture](docs/ARCHITECTURE.md)** - System design and decisions
- **[AI Command System](docs/AI_COMMAND_SYSTEM.md)** - How commands work
- **[Power Tools](docs/POWER_TOOLS.md)** - Advanced features

### Team Resources

- **[Team Onboarding](docs/CLI_FIRST_PHILOSOPHY.md)** - CLI-first approach explained
- **[Contribution Guide](CONTRIBUTING.md)** - How to contribute
- **[Code of Conduct](CODE_OF_CONDUCT.md)** - Community standards

## 🤝 Support & Feedback

- **Report Issues**: [GitHub Issues](https://github.com/Softsensor-org/DevPilot/issues)
- **Feature Requests**: Create an issue with [Feature Request] tag
- **Questions**: Open a discussion in the Issues tab
- **Star the repo** if it helps your productivity!

---

<p align="center">
  <i>Stop configuring. Start building.</i>
</p>
