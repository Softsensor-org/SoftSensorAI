# SoftSensorAI Command Reference

Complete documentation for all SoftSensorAI commands with examples, use cases, and troubleshooting.

## 🎯 Quick Navigation

### Most Used Commands

| Command                       | Purpose                           | Documentation               |
| ----------------------------- | --------------------------------- | --------------------------- |
| [`ssai setup`](ssai/setup.md)     | Add SoftSensorAI to any project   | [Full Guide](ssai/setup.md)   |
| [`ssai init`](ssai/init.md)       | Initialize and configure project  | [Full Guide](ssai/init.md)    |
| [`ssai doctor`](ssai/doctor.md)   | Check system health               | [Full Guide](ssai/doctor.md)  |
| [`ssai palette`](ssai/palette.md) | Browse all commands interactively | [Full Guide](ssai/palette.md) |
| [`ssai review`](ssai/review.md)   | AI code review                    | [Full Guide](ssai/review.md)  |
| [`ssai tickets`](ssai/tickets.md) | Generate backlog from code        | [Full Guide](ssai/tickets.md) |

## 📚 Command Categories

### Setup & Configuration

| Command                       | Description                 | Examples & Details                      |
| ----------------------------- | --------------------------- | --------------------------------------- |
| [`ssai setup`](ssai/setup.md)     | Smart repository setup      | [View Examples](ssai/setup.md#examples)   |
| [`ssai init`](ssai/init.md)       | Full project initialization | [View Examples](ssai/init.md#examples)    |
| [`ssai project`](ssai/project.md) | View/modify project config  | [View Examples](ssai/project.md#examples) |

### Health & Diagnostics

| Command                                   | Description                       | Examples & Details                            |
| ----------------------------------------- | --------------------------------- | --------------------------------------------- |
| [`ssai doctor`](ssai/doctor.md)               | System health check               | [View Examples](ssai/doctor.md#example-output)  |
| [`ssai score`](ssai/score.md)                 | Repository readiness score (DPRS) | [View Examples](ssai/score.md#examples)         |
| [`ssai release-check`](ssai/release-check.md) | Release readiness assessment      | [View Examples](ssai/release-check.md#examples) |

### AI & Development

| Command                       | Description                | Examples & Details                      |
| ----------------------------- | -------------------------- | --------------------------------------- |
| [`ssai review`](ssai/review.md)   | AI code review             | [View Examples](ssai/review.md#examples)  |
| [`ssai tickets`](ssai/tickets.md) | Generate tickets from code | [View Examples](ssai/tickets.md#examples) |
| [`ssai ai`](ssai/ai.md)           | Unified AI CLI interface   | [View Examples](ssai/ai.md#examples)      |
| [`ssai sandbox`](ssai/sandbox.md) | Sandboxed code execution   | [View Examples](ssai/sandbox.md#examples) |

### Personas & Profiles

| Command                       | Description                     | Examples & Details                      |
| ----------------------------- | ------------------------------- | --------------------------------------- |
| [`ssai persona`](ssai/persona.md) | Manage AI personas              | [View Examples](ssai/persona.md#examples) |
| [`ssai profile`](ssai/profile.md) | View/change skill level & phase | [View Examples](ssai/profile.md#examples) |
| [`ssai config`](ssai/config.md)   | Interactive configuration       | [View Examples](ssai/config.md#examples)  |

### Analysis & Planning

| Command                       | Description                | Examples & Details                      |
| ----------------------------- | -------------------------- | --------------------------------------- |
| [`ssai tickets`](ssai/tickets.md) | Create JIRA/GitHub tickets | [View Examples](ssai/tickets.md#examples) |
| [`ssai detect`](ssai/detect.md)   | Detect tech stack          | [View Examples](ssai/detect.md#examples)  |
| [`ssai plan`](ssai/plan.md)       | Preview setup changes      | [View Examples](ssai/plan.md#examples)    |
| [`ssai risk`](ssai/risk.md)       | Analyze PR risk            | [View Examples](ssai/risk.md#examples)    |

### Utilities & Tools

| Command                         | Description              | Examples & Details                       |
| ------------------------------- | ------------------------ | ---------------------------------------- |
| [`ssai palette`](ssai/palette.md)   | Command browser with fzf | [View Examples](ssai/palette.md#examples)  |
| [`ssai chain`](ssai/chain.md)       | Execute command chains   | [View Examples](ssai/chain.md#examples)    |
| [`ssai patterns`](ssai/patterns.md) | Browse design patterns   | [View Examples](ssai/patterns.md#examples) |
| [`ssai worktree`](ssai/worktree.md) | Git worktree management  | [View Examples](ssai/worktree.md#examples) |

## 🎯 Common Workflows

### First Time Setup

```bash
# 1. Install SoftSensorAI
git clone https://github.com/Softsensor-org/SoftSensorAI ~/softsensorai
cd ~/softsensorai && ./setup_all.sh

# 2. Add to PATH
export PATH="$HOME/softsensorai/bin:$PATH"

# 3. Setup your project
cd your-project
ssai setup        # Add SoftSensorAI files
ssai init         # Configure and build

# 4. Explore commands
ssai palette      # Interactive browser
```

### Daily Development

```bash
# Morning setup
ssai doctor       # Check health
ssai project      # View config

# During development
ssai review       # Before commits
ssai tickets      # Generate tasks

# Interactive discovery
ssai palette      # Find commands
```

### Team Onboarding

```bash
# New team member
cd team-project
ssai setup
ssai init --skill l1 --phase beta

# Match team configuration
ssai project      # View settings
```

## 📖 Understanding Command Documentation

Each command documentation includes:

### Structure

- **Overview** - What the command does
- **Usage** - Command syntax and options
- **Examples** - Real-world usage scenarios
- **Options** - All available flags and parameters
- **When to Use** - Specific use cases
- **Troubleshooting** - Common issues and fixes
- **Related Commands** - Similar or complementary commands

### Example Sections

```markdown
## Examples

### Basic Usage

\`\`\`bash ssai command

# Output shown here

\`\`\`

### Advanced Usage

\`\`\`bash ssai command --option value

# Different output

\`\`\`
```

## 🔍 Finding Commands

### By Category

- **Setup**: `ssai setup`, `ssai init`, `ssai project`
- **Health**: `ssai doctor`, `ssai score`
- **AI**: `ssai review`, `ssai tickets`, `ssai ai`
- **Analysis**: `ssai tickets`, `ssai detect`, `ssai plan`

### By Use Case

- **Starting new project**: [`ssai setup`](ssai/setup.md)
- **Checking environment**: [`ssai doctor`](ssai/doctor.md)
- **Code review**: [`ssai review`](ssai/review.md)
- **Generate backlog**: [`ssai tickets`](ssai/tickets.md)

### Interactive Search

```bash
# Use the command palette
ssai palette

# Search for specific functionality
ssai palette review    # Find review commands
ssai palette test      # Find test commands
```

## 📝 Command Naming Conventions

### ssai Commands

- Short, verb-based names
- Common developer actions
- Examples: `setup`, `init`, `review`, `doctor`, `tickets`

### Internal Scripts (Not User-Facing)

- Located in scripts/ and tools/ directories
- Called internally by ssai commands
- Users should use ssai interface instead

## 🚀 Getting Started

1. **New to SoftSensorAI?** Start with [`ssai setup`](ssai/setup.md)
2. **Need help?** Run [`ssai doctor`](ssai/doctor.md)
3. **Want to explore?** Use [`ssai palette`](ssai/palette.md)
4. **Ready to code?** Check [`ssai review`](ssai/review.md)

## 📚 Learning Path

### Beginner

1. [`ssai setup`](ssai/setup.md) - Add SoftSensorAI
2. [`ssai init`](ssai/init.md) - Configure project
3. [`ssai doctor`](ssai/doctor.md) - Verify setup
4. [`ssai palette`](ssai/palette.md) - Explore commands

### Intermediate

1. [`ssai profile`](ssai/profile.md) - Adjust skill level
2. [`ssai review`](ssai/review.md) - AI code review
3. [`ssai tickets`](ssai/tickets.md) - Generate tasks
4. [`ssai score`](ssai/score.md) - Check readiness

### Advanced

1. [`ssai persona`](ssai/persona.md) - Multiple personas
2. [`ssai chain`](ssai/chain.md) - Command chains
3. [`ssai worktree`](ssai/worktree.md) - Parallel work
4. [`ssai release-check`](ssai/release-check.md) - Production prep

## 🔧 Contributing

To add documentation for a new command:

1. Create file in appropriate directory:

   - `docs/commands/ssai/` for ssai commands
   - `docs/commands/scripts/` for scripts
   - `docs/commands/tools/` for tools

2. Use the template structure:

   - Overview
   - Usage
   - Examples
   - Options
   - When to Use
   - Troubleshooting
   - Related Commands

3. Update this index with links

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Softsensor-org/SoftSensorAI/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Softsensor-org/SoftSensorAI/discussions)
- **Documentation**: [Main Docs](../../README.md)
