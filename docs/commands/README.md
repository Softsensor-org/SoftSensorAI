# SoftSensorAI Command Reference

Complete documentation for all SoftSensorAI commands with examples, use cases, and troubleshooting.

## 🎯 Quick Navigation

### Most Used Commands

| Command                       | Purpose                           | Documentation               |
| ----------------------------- | --------------------------------- | --------------------------- |
| [`dp setup`](dp/setup.md)     | Add SoftSensorAI to any project   | [Full Guide](dp/setup.md)   |
| [`dp init`](dp/init.md)       | Initialize and configure project  | [Full Guide](dp/init.md)    |
| [`dp doctor`](dp/doctor.md)   | Check system health               | [Full Guide](dp/doctor.md)  |
| [`dp palette`](dp/palette.md) | Browse all commands interactively | [Full Guide](dp/palette.md) |
| [`dp review`](dp/review.md)   | AI code review                    | [Full Guide](dp/review.md)  |
| [`dp tickets`](dp/tickets.md) | Generate backlog from code        | [Full Guide](dp/tickets.md) |

## 📚 Command Categories

### Setup & Configuration

| Command                       | Description                 | Examples & Details                      |
| ----------------------------- | --------------------------- | --------------------------------------- |
| [`dp setup`](dp/setup.md)     | Smart repository setup      | [View Examples](dp/setup.md#examples)   |
| [`dp init`](dp/init.md)       | Full project initialization | [View Examples](dp/init.md#examples)    |
| [`dp project`](dp/project.md) | View/modify project config  | [View Examples](dp/project.md#examples) |

### Health & Diagnostics

| Command                                   | Description                       | Examples & Details                            |
| ----------------------------------------- | --------------------------------- | --------------------------------------------- |
| [`dp doctor`](dp/doctor.md)               | System health check               | [View Examples](dp/doctor.md#example-output)  |
| [`dp score`](dp/score.md)                 | Repository readiness score (DPRS) | [View Examples](dp/score.md#examples)         |
| [`dp release-check`](dp/release-check.md) | Release readiness assessment      | [View Examples](dp/release-check.md#examples) |

### AI & Development

| Command                       | Description                | Examples & Details                      |
| ----------------------------- | -------------------------- | --------------------------------------- |
| [`dp review`](dp/review.md)   | AI code review             | [View Examples](dp/review.md#examples)  |
| [`dp tickets`](dp/tickets.md) | Generate tickets from code | [View Examples](dp/tickets.md#examples) |
| [`dp ai`](dp/ai.md)           | Unified AI CLI interface   | [View Examples](dp/ai.md#examples)      |
| [`dp sandbox`](dp/sandbox.md) | Sandboxed code execution   | [View Examples](dp/sandbox.md#examples) |

### Personas & Profiles

| Command                       | Description                     | Examples & Details                      |
| ----------------------------- | ------------------------------- | --------------------------------------- |
| [`dp persona`](dp/persona.md) | Manage AI personas              | [View Examples](dp/persona.md#examples) |
| [`dp profile`](dp/profile.md) | View/change skill level & phase | [View Examples](dp/profile.md#examples) |
| [`dp config`](dp/config.md)   | Interactive configuration       | [View Examples](dp/config.md#examples)  |

### Analysis & Planning

| Command                       | Description                | Examples & Details                      |
| ----------------------------- | -------------------------- | --------------------------------------- |
| [`dp tickets`](dp/tickets.md) | Create JIRA/GitHub tickets | [View Examples](dp/tickets.md#examples) |
| [`dp detect`](dp/detect.md)   | Detect tech stack          | [View Examples](dp/detect.md#examples)  |
| [`dp plan`](dp/plan.md)       | Preview setup changes      | [View Examples](dp/plan.md#examples)    |
| [`dp risk`](dp/risk.md)       | Analyze PR risk            | [View Examples](dp/risk.md#examples)    |

### Utilities & Tools

| Command                         | Description              | Examples & Details                       |
| ------------------------------- | ------------------------ | ---------------------------------------- |
| [`dp palette`](dp/palette.md)   | Command browser with fzf | [View Examples](dp/palette.md#examples)  |
| [`dp chain`](dp/chain.md)       | Execute command chains   | [View Examples](dp/chain.md#examples)    |
| [`dp patterns`](dp/patterns.md) | Browse design patterns   | [View Examples](dp/patterns.md#examples) |
| [`dp worktree`](dp/worktree.md) | Git worktree management  | [View Examples](dp/worktree.md#examples) |

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
dp setup        # Add SoftSensorAI files
dp init         # Configure and build

# 4. Explore commands
dp palette      # Interactive browser
```

### Daily Development

```bash
# Morning setup
dp doctor       # Check health
dp project      # View config

# During development
dp review       # Before commits
dp tickets      # Generate tasks

# Interactive discovery
dp palette      # Find commands
```

### Team Onboarding

```bash
# New team member
cd team-project
dp setup
dp init --skill l1 --phase beta

# Match team configuration
dp project      # View settings
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

\`\`\`bash dp command

# Output shown here

\`\`\`

### Advanced Usage

\`\`\`bash dp command --option value

# Different output

\`\`\`
```

## 🔍 Finding Commands

### By Category

- **Setup**: `dp setup`, `dp init`, `dp project`
- **Health**: `dp doctor`, `dp score`
- **AI**: `dp review`, `dp tickets`, `dp ai`
- **Analysis**: `dp tickets`, `dp detect`, `dp plan`

### By Use Case

- **Starting new project**: [`dp setup`](dp/setup.md)
- **Checking environment**: [`dp doctor`](dp/doctor.md)
- **Code review**: [`dp review`](dp/review.md)
- **Generate backlog**: [`dp tickets`](dp/tickets.md)

### Interactive Search

```bash
# Use the command palette
dp palette

# Search for specific functionality
dp palette review    # Find review commands
dp palette test      # Find test commands
```

## 📝 Command Naming Conventions

### dp Commands

- Short, verb-based names
- Common developer actions
- Examples: `setup`, `init`, `review`, `doctor`, `tickets`

### Internal Scripts (Not User-Facing)

- Located in scripts/ and tools/ directories
- Called internally by dp commands
- Users should use dp interface instead

## 🚀 Getting Started

1. **New to SoftSensorAI?** Start with [`dp setup`](dp/setup.md)
2. **Need help?** Run [`dp doctor`](dp/doctor.md)
3. **Want to explore?** Use [`dp palette`](dp/palette.md)
4. **Ready to code?** Check [`dp review`](dp/review.md)

## 📚 Learning Path

### Beginner

1. [`dp setup`](dp/setup.md) - Add SoftSensorAI
2. [`dp init`](dp/init.md) - Configure project
3. [`dp doctor`](dp/doctor.md) - Verify setup
4. [`dp palette`](dp/palette.md) - Explore commands

### Intermediate

1. [`dp profile`](dp/profile.md) - Adjust skill level
2. [`dp review`](dp/review.md) - AI code review
3. [`dp tickets`](dp/tickets.md) - Generate tasks
4. [`dp score`](dp/score.md) - Check readiness

### Advanced

1. [`dp persona`](dp/persona.md) - Multiple personas
2. [`dp chain`](dp/chain.md) - Command chains
3. [`dp worktree`](dp/worktree.md) - Parallel work
4. [`dp release-check`](dp/release-check.md) - Production prep

## 🔧 Contributing

To add documentation for a new command:

1. Create file in appropriate directory:

   - `docs/commands/dp/` for dp commands
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
