# dp init

## Overview

Complete project initialization that runs health checks, applies profiles, and builds your project -
everything needed after `dp setup`.

## Usage

```bash
dp init [OPTIONS]
```

## What It Does

Runs three critical steps in sequence:

1. **System Health Check** - Verifies all tools are installed (`dp doctor`)
2. **Profile Configuration** - Sets your skill level and project phase
3. **Project Build** - Installs dependencies and runs build commands

## Examples

### Interactive Initialization

```bash
dp init
# 🚀 Initializing project with full setup...
#
# Step 1/3: Running system health check...
# ✓ OS: Linux (supported)
# ✓ Git: 2.34.1
# ✓ Node.js: 18.17.0
#
# Step 2/3: Configuring profile...
# ? Select skill level:
#   1) beginner - Learning mode with detailed guidance
# > 2) l1 - Junior developer level
#   3) l2 - Mid-level developer
#   4) expert - Senior developer
#
# ? Select project phase:
#   1) poc - Proof of concept
# > 2) mvp - Minimum viable product
#   3) beta - Beta testing
#   4) scale - Production
#
# Step 3/3: Building project...
# ✓ Installing npm dependencies...
# ✓ Initialization complete!
```

### Direct Initialization (Skip Prompts)

```bash
dp init --skill l2 --phase beta
# Applies mid-level developer profile in beta phase
```

## Options

- `--skill [level]` - Set skill level: `beginner`, `l1`, `l2`, `expert`
- `--phase [phase]` - Set project phase: `poc`, `mvp`, `beta`, `scale`
- `--skip-build` - Skip dependency installation
- `--skip-doctor` - Skip health check (not recommended)

## Skill Levels Explained

| Level        | For                    | Features                              | Guard Rails           |
| ------------ | ---------------------- | ------------------------------------- | --------------------- |
| **beginner** | New to coding          | Teaching mode, detailed explanations  | Maximum safety checks |
| **l1**       | Junior dev (0-2 years) | Structured patterns, guided workflows | Basic safety checks   |
| **l2**       | Mid-level (2-5 years)  | Advanced tools, CI/CD integration     | Balanced checks       |
| **expert**   | Senior (5+ years)      | Full access, complex operations       | Minimal restrictions  |

## Project Phases Explained

| Phase     | Use Case          | CI/CD Strictness        | Features         |
| --------- | ----------------- | ----------------------- | ---------------- |
| **poc**   | Rapid prototyping | Minimal - warnings only | Fast iteration   |
| **mvp**   | Initial release   | Basic - linting, tests  | Core quality     |
| **beta**  | User testing      | Strict - security scans | Full validation  |
| **scale** | Production        | Maximum - all gates     | Enterprise ready |

## What Gets Configured

### Based on Skill Level

- Available AI commands (more commands at higher levels)
- Explanation detail (verbose for beginners, concise for experts)
- Safety checks (stricter for beginners)
- Access to destructive operations

### Based on Project Phase

- CI/CD pipeline strictness
- Pre-commit hooks
- Security scanning requirements
- Test coverage thresholds

## Build Process

Automatically detects and runs:

```bash
# Node.js projects
npm install         # or pnpm/yarn if lock files exist

# Python projects
python -m venv .venv && .venv/bin/pip install -r requirements.txt

# Go projects
go mod download

# Rust projects
cargo build

# Ruby projects
bundle install
```

## When to Use

- **After `dp setup`** - Always run init after setup
- **Changing skill level** - As you gain experience
- **Changing project phase** - As project matures
- **New team member** - To match team configuration
- **After cloning** - To set up development environment

## Examples by Scenario

### New Developer Starting

```bash
dp init --skill beginner --phase poc
# Maximum guidance, minimal restrictions
```

### Team Project in Beta

```bash
dp init --skill l2 --phase beta
# Professional setup with quality gates
```

### Production Deployment Prep

```bash
dp init --skill expert --phase scale
# Full security, all CI/CD gates active
```

## Troubleshooting

### "Command not found: npm"

```bash
# Install Node.js first
curl -fsSL https://fnm.vercel.app/install | bash
fnm use --install-if-missing 20
```

### "No profile selected"

```bash
# Run interactive mode
dp init
# Or specify directly
dp init --skill l1 --phase mvp
```

### "Build failed"

```bash
# Check specific build requirements
cat package.json     # Node.js
cat requirements.txt # Python
# Run build manually
npm install --verbose
```

## Related Commands

- [`dp setup`](setup.md) - Add SoftSensorAI to a project (run before init)
- [`dp doctor`](doctor.md) - Health check only
- [`dp project`](project.md) - View current configuration
- [`scripts/apply_profile.sh`](../../scripts/apply_profile.md) - Change profile later

## Implementation

- **Script**: `bin/dp` (cmd_init function)
- **Calls**:
  - `scripts/doctor.sh` - System health check
  - `scripts/apply_profile.sh` - Profile configuration
  - Language-specific build commands
