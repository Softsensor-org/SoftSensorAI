# SoftSensorAI Architecture & Usage Guide

A CLI-first AI development platform that standardizes how teams work with Claude, Codex, Gemini,
Grok, and other AI assistants.

## Architecture at a Glance

### 1. Two-Tier Install Model

SoftSensorAI separates global tooling from project-specific configuration:

```
┌─────────────────────────────────────────────────────────┐
│                    GLOBAL LAYER (once)                   │
│  ~/softsensorai/         - Scripts, wizards, templates       │
│  ~/.claude/          - Claude global settings            │
│  ~/.gemini/          - Gemini configuration              │
│  ~/.grok/            - Grok settings                     │
│  ~/.codex/           - Codex config                      │
│  /usr/local/bin/     - ripgrep, jq, gh, fd, etc.        │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│               PER-PROJECT LAYER (each repo)              │
│  CLAUDE.md           - Project AI instructions           │
│  AGENTS.md           - General agent directives          │
│  .claude/            - Settings, commands, personas      │
│  .mcp.json           - MCP server configuration          │
│  scripts/            - Profile & check scripts           │
└─────────────────────────────────────────────────────────┘
```

### 2. Prompt System Layering

Prompts compose from global → repo → task specifics:

```bash
# How prompts merge
00-global.md + 10-repo.md + 20-task.md → system/active.md

# Point CLIs at the merged prompt
claude --system-prompt system/active.md "your request"
codex --system system/active.md "your request"
gemini --context system/active.md "your request"
```

### 3. Profiles & Phases (Policy Engine)

Skills and phases control capabilities and CI gates:

| Skill Level  | Who It's For  | Available Tools  | Safety Rails |
| ------------ | ------------- | ---------------- | ------------ |
| **vibe**     | Experimenting | Everything       | None         |
| **beginner** | Learning      | Basic + teaching | Maximum      |
| **l1**       | Junior dev    | Core tools       | Strong       |
| **l2**       | Mid-level     | Advanced tools   | Moderate     |
| **expert**   | Senior dev    | Full access      | Minimal      |

| Project Phase | Use Case       | CI Requirements | Security |
| ------------- | -------------- | --------------- | -------- |
| **poc**       | Prototyping    | None            | Advisory |
| **mvp**       | Core features  | Tests required  | Advisory |
| **beta**      | Pre-production | Coverage ≥60%   | Blocking |
| **scale**     | Production     | Coverage ≥80%   | Strict   |

### 4. Personas (Capability Packs)

Composable expertise modules that add specialized commands:

```bash
# Common combinations
Backend API:        architect + backend + devops
Microservices:      architect + backend + devops + security
ML Application:     data-scientist + backend + devops
Infrastructure:     devops + security + architect
```

### 5. Command Catalog

60+ prebuilt workflows under `.claude/commands/`:

```
commands/
├── thinking/          # /think-hard, /explore-plan-code-test
├── patterns/          # /backend-feature, /api-contract
├── security/          # /security-review, /threat-model
├── architecture/      # /design-review, /scale-analysis
└── automation/        # /tickets-from-code, /map-reduce
```

## CLI-First Usage

SoftSensorAI is designed for **CLI usage**, not API integration. Here's how to use each assistant:

### AI CLI Integration

For detailed installation and usage, see the [AI CLI Installation Guide](./AI_CLI_INSTALL.md).

```bash
# Quick setup with Anthropic CLI
pip install anthropic
export ANTHROPIC_API_KEY="sk-ant-..."

# Use with SoftSensorAI
dp review  # Uses AI for code review
dp agent new --goal "implement user authentication"  # Creates AI-guided task
```

### Codex CLI

```bash
# Use with sandboxed execution
codex --system system/active.md --sandbox "generate test suite"

# Architecture generation
codex --system .claude/commands/patterns/arch-spike.md "design payment service"
```

### Gemini CLI

```bash
# With context
gemini --context system/active.md "explain this codebase structure"

# With specific persona
gemini --context .claude/personas/data-scientist/config.md "optimize this ML pipeline"
```

### Grok CLI

```bash
# Quick tasks
grok --prompt system/active.md "add error handling to this function"

# With commands
grok --prompt .claude/commands/patterns/bug-fix.md "fix null pointer issue"
```

## Playbooks

### A) First-Time Setup (Developer Laptop)

```bash
# 1. Clone and install globally (one time only)
git clone https://github.com/Softsensor-org/SoftSensorAI.git ~/softsensorai
cd ~/softsensorai
./setup_all.sh

# 2. Verify installation
~/softsensorai/scripts/doctor.sh
```

### B) Make a Repo "AI-Ready"

#### Option 1: New Project (Clone & Setup)

```bash
# Interactive wizard
~/softsensorai/setup/repo_wizard.sh

# Or one-liner
~/softsensorai/setup/repo_wizard.sh \
  --url git@github.com:org/repo.git \
  --org work \
  --category backend \
  --skill l1 \
  --phase mvp
```

#### Option 2: Existing Project (Setup Only)

```bash
# Navigate to your existing repo
cd /path/to/your/repo

# Run setup for existing repo
~/softsensorai/setup/existing_repo_setup.sh \
  --skill l2 \
  --phase beta

# Add personas
~/softsensorai/scripts/persona_manager.sh add backend-developer
~/softsensorai/scripts/persona_manager.sh add devops-engineer
```

### C) Daily Development Flow

```bash
# Morning: Check profile and personas
scripts/profile_show.sh
scripts/persona_manager.sh show

# Feature development
claude --system-prompt system/active.md "/explore-plan-code-test implement OAuth2"

# Security check before commit
claude --system-prompt .claude/commands/security-review.md "review changes"

# Generate tickets for remaining work
claude --system-prompt .claude/commands/tickets-from-code.md "analyze TODO comments"

# Architecture decisions
codex --system .claude/commands/patterns/arch-spike.md "evaluate caching strategies"

# Long context handling
claude --system-prompt .claude/commands/automation/long-context-map-reduce.md "summarize all test failures"
```

### D) Architecture Work

```bash
# 1. Generate system design
codex --system .claude/commands/patterns/arch-spike.md \
  "design multi-tenant SaaS platform"

# 2. Review with architect persona
~/softsensorai/scripts/persona_manager.sh add software-architect
claude --system-prompt system/active.md "/architecture-review proposed-design.md"

# 3. Generate IaC
codex --system .claude/commands/think-hard.md \
  "create Terraform for the approved design"

# 4. Security review
claude --system-prompt .claude/commands/security/threat-model.md \
  "analyze attack vectors"
```

### E) CI/CD Integration

```bash
# Apply appropriate phase
scripts/apply_profile.sh --phase beta  # Enables security blocking

# Check what will be enforced
cat .github/workflows/ci.yml | grep -A5 "Security Checks"

# Run local validation
scripts/run_checks.sh --all

# Manage legacy noise (for existing codebases)
gh variable set SEMGREP_BASELINE_REF --body "main"  # Suppress pre-existing findings
echo "CVE-2021-44228" >> .trivyignore              # Accept known CVE

# Fix new issues before push
semgrep --config=auto --baseline-ref=main --autofix .
trivy fs . --ignorefile .trivyignore
gitleaks detect --baseline-path .gitleaksignore
```

## Team Standardization Guide

### 1. Baseline Configuration

Start all projects with:

```bash
--skill l1 --phase mvp  # Safe defaults with room to grow
```

### 2. Persona Stacks

| Project Type        | Recommended Personas                 | Command                                                                                                                                  |
| ------------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **Backend API**     | architect, backend, devops           | `for p in software-architect backend-developer devops-engineer; do ~/softsensorai/scripts/persona_manager.sh add $p; done`                   |
| **Microservices**   | architect, backend, devops, security | `for p in software-architect backend-developer devops-engineer security-engineer; do ~/softsensorai/scripts/persona_manager.sh add $p; done` |
| **ML/Data Science** | data-scientist, backend, devops      | `for p in data-scientist backend-developer devops-engineer; do ~/softsensorai/scripts/persona_manager.sh add $p; done`                       |
| **Full Stack**      | frontend, backend, devops            | `for p in frontend-developer backend-developer devops-engineer; do ~/softsensorai/scripts/persona_manager.sh add $p; done`                   |

### 3. CI Gates by Phase

| Tool         | MVP      | Beta                 | Scale          |
| ------------ | -------- | -------------------- | -------------- |
| **Tests**    | Required | Required             | Required       |
| **Linting**  | Required | Required             | Required       |
| **Coverage** | None     | ≥60%                 | ≥80%           |
| **Gitleaks** | Advisory | Blocks any           | Blocks any     |
| **Semgrep**  | Advisory | Blocks HIGH+         | Blocks MEDIUM+ |
| **Trivy**    | Advisory | Blocks CRITICAL/HIGH | Blocks all     |
| **License**  | None     | Check                | Enforce        |

### 4. Command Usage Priority

Top 5 daily commands teams should use:

1. `/explore-plan-code-test` - Full feature development cycle
2. `/security-review` - Pre-commit security check
3. `/tickets-from-code` - Backlog generation
4. `/api-contract` - OpenAPI/GraphQL updates
5. `/long-context-map-reduce` - Handle large diffs/logs

## Week with SoftSensorAI

### Day 1: Setup & Orientation

```bash
# Morning: Global install
~/softsensorai/setup_all.sh

# Afternoon: Setup first project
~/softsensorai/setup/repo_wizard.sh

# Explore commands
ls .claude/commands/
cat .claude/commands/think-hard.md
```

### Day 2: Feature Development

```bash
# Use exploration workflow
claude --system-prompt system/active.md \
  "/explore-plan-code-test add user preferences API"

# Review security
claude --system-prompt .claude/commands/security-review.md \
  "check the new endpoint"
```

### Day 3: Architecture & Design

```bash
# Add architect persona
~/softsensorai/scripts/persona_manager.sh add software-architect

# Design review
claude --system-prompt system/active.md \
  "/architecture-review should we use Redis or Memcached?"
```

### Day 4: Testing & Quality

```bash
# Generate comprehensive tests
claude --system-prompt .claude/commands/patterns/test-first.md \
  "cover all edge cases"

# Run quality audit
claude --system-prompt .claude/commands/audit-full.md \
  "review entire codebase"
```

### Day 5: Documentation & Tickets

```bash
# Generate tickets from TODOs
claude --system-prompt .claude/commands/tickets-from-code.md \
  "scan for technical debt"

# Update API documentation
claude --system-prompt .claude/commands/patterns/api-contract.md \
  "sync OpenAPI spec with implementation"
```

## Advanced Patterns

### Multi-Repo Management

```bash
# Apply consistent setup across repos
for repo in api-gateway user-service payment-service; do
  cd ~/projects/work/backend/$repo
  ~/softsensorai/scripts/apply_profile.sh --skill l2 --phase beta
  ~/softsensorai/scripts/persona_manager.sh add backend-developer
  ~/softsensorai/scripts/persona_manager.sh add devops-engineer
done
```

### Custom Commands

```bash
# Add project-specific command
cat > .claude/commands/custom-deploy.md << 'EOF'
Deploy to staging environment with proper checks:
1. Run tests
2. Check security
3. Build Docker image
4. Push to registry
5. Deploy to K8s
6. Run smoke tests
EOF

# Use it
claude --system-prompt .claude/commands/custom-deploy.md "deploy feature-xyz"
```

### Hook Integration

```bash
# Install git hooks
~/softsensorai/setup/install_hooks.sh

# Configure commit template
git config commit.template .gitmessage

# Setup pre-push validation
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
scripts/run_checks.sh --security --tests
EOF
chmod +x .git/hooks/pre-push
```

**Cross-Platform Compatibility:**

- All SoftSensorAI scripts use BSD-safe `sed` commands
- Works on macOS, Linux, and BSD systems
- Use `sed -i ''` (with empty string) for macOS compatibility
- Git hooks are portable across all platforms

## Troubleshooting

### CLI Not Finding System Prompt

```bash
# Ensure system/active.md exists
ls -la system/active.md

# Regenerate if missing
scripts/apply_profile.sh --skill l1 --phase mvp
```

### Persona Commands Not Available

```bash
# Check active personas
~/softsensorai/scripts/persona_manager.sh show

# Verify command installation
ls .claude/commands/personas/
```

### CI Failing Unexpectedly

```bash
# Check current phase
grep "PROJECT_PHASE" .env

# Review what's enforced
cat .github/workflows/ci.yml | grep "exit-code"
```

## Next Steps

1. **Review Detailed Guides**:

   - [Quickstart](quickstart.md) - Initial setup
   - [Profiles Guide](profiles.md) - Skill levels & phases
   - [Personas Guide](PERSONAS_GUIDE.md) - Specialized expertise
   - [Command Catalog](agent-commands.md) - All available commands
   - [CI Integration](ci.md) - Pipeline configuration

2. **Customize for Your Team**:

   - Create custom personas in `.claude/personas/custom/`
   - Add team-specific commands to `.claude/commands/team/`
   - Define organization standards in `templates/`

3. **Scale Adoption**:
   - **Always preview first**:
     `~/softsensorai/scripts/repo_plan.sh [base] [org] [category] [name] [url]`
   - Use `--dry-run` flags: `~/softsensorai/setup/repo_wizard.sh --dry-run`
   - Batch apply with `find` and `xargs`
   - Monitor with `validation/validate_agents.sh`

---

_DevPilot: CLI-first AI development that scales with your team._
