# Existing Repository Setup Guide

The fastest way to add SoftSensorAI to your already-cloned repositories without reorganizing your
directory structure.

## When to Use This

SoftSensorAI automatically detects if you're in an existing repository:

- ✅ Already have a repository cloned locally
- ✅ Want to keep your current directory structure
- ✅ Don't want the wizard to clone/move your code
- ✅ Need to quickly add AI assistance to multiple repos

## Quick Start

```bash
# Navigate to your existing project
cd /path/to/your/project

# Run setup - automatically detects existing repo
dp setup

# Initialize with your preferences
dp init --skill l1 --phase mvp

# That's it! SoftSensorAI is configured for your project
dp palette  # Browse available commands
```

## What Gets Added

The script adds SoftSensorAI configurations **without** moving or cloning your repository:

```
your-existing-repo/
├── CLAUDE.md                    # AI instructions (created)
├── AGENTS.md                    # Agent directives (created)
├── .claude/                     # (created)
│   ├── settings.json           # Project permissions
│   ├── commands/               # 60+ AI commands
│   └── personas/               # Active personas
├── scripts/                     # (created)
│   ├── apply_profile.sh        # Profile management
│   └── run_checks.sh           # Quality checks
├── system/                      # (created)
│   └── active.md               # Merged prompt
└── [your existing files remain untouched]
```

## Usage Options

### Interactive Mode (Default)

```bash
cd your-project
~/softsensorai/setup/existing_repo_setup.sh
```

You'll be prompted for:

1. Skill level (beginner, l1, l2, expert)
2. Project phase (poc, mvp, beta, scale)
3. Whether to install git hooks

### Command-Line Mode

```bash
cd your-project
~/softsensorai/setup/existing_repo_setup.sh \
  --skill l2 \
  --phase beta \
  --no-hooks
```

### Parameters

| Parameter    | Options                        | Default  | Description                |
| ------------ | ------------------------------ | -------- | -------------------------- |
| `--skill`    | vibe, beginner, l1, l2, expert | beginner | Your experience level      |
| `--phase`    | poc, mvp, beta, scale          | mvp      | Project maturity           |
| `--hooks`    | (flag)                         | false    | Install git hooks          |
| `--no-hooks` | (flag)                         | true     | Skip git hooks             |
| `--force`    | (flag)                         | false    | Overwrite existing configs |

## Common Scenarios

### Scenario 1: Microservices (Multiple Repos)

```bash
# Setup all services with consistent configuration
for service in auth-service user-service payment-service; do
  cd ~/microservices/$service
  ~/softsensorai/setup/existing_repo_setup.sh --skill l2 --phase beta

  # Add same personas to all services
  for persona in software-architect backend-developer devops-engineer; do
    ~/softsensorai/scripts/persona_manager.sh add $persona
  done
done
```

### Scenario 2: Monorepo

```bash
# Setup at monorepo root
cd ~/company/monorepo
~/softsensorai/setup/existing_repo_setup.sh --skill expert --phase scale

# Add all relevant personas
~/softsensorai/scripts/persona_manager.sh add software-architect
~/softsensorai/scripts/persona_manager.sh add backend-developer
~/softsensorai/scripts/persona_manager.sh add frontend-developer
~/softsensorai/scripts/persona_manager.sh add devops-engineer
```

### Scenario 3: Legacy Project

```bash
# Start with low skill level for safety
cd ~/legacy/old-app
~/softsensorai/setup/existing_repo_setup.sh --skill beginner --phase poc

# Add security persona for vulnerability scanning
~/softsensorai/scripts/persona_manager.sh add security-engineer

# Run security audit
claude --system-prompt .claude/commands/security-review.md "audit entire codebase"
```

### Scenario 4: Open Source Contribution

```bash
# Fork and clone first
git clone git@github.com:you/forked-project.git
cd forked-project

# Setup with appropriate level
~/softsensorai/setup/existing_repo_setup.sh --skill l1 --phase mvp

# Use to understand codebase
claude --system-prompt system/active.md "/explore-codebase explain the architecture"
```

## What Happens During Setup

1. **Detection Phase**

   ```
   ✓ Detects: Node.js, Python, Go, Rust, Ruby, Java, PHP
   ✓ Finds: package.json, requirements.txt, go.mod, etc.
   ✓ Identifies: Git repository status
   ```

2. **Configuration Phase**

   ```
   ✓ Creates CLAUDE.md with project-specific instructions
   ✓ Adds AGENTS.md with general directives
   ✓ Sets up .claude/ directory with commands and settings
   ```

3. **Profile Application**

   ```
   ✓ Applies skill level (controls available commands)
   ✓ Sets project phase (determines CI strictness)
   ✓ Merges prompts into system/active.md
   ```

4. **Optional: Dependency Bootstrap**
   ```
   ✓ Installs Node modules if package.json exists
   ✓ Creates Python venv if requirements.txt exists
   ✓ Runs bundle install if Gemfile exists
   ```

## Comparison with repo_wizard.sh

| Feature                          | existing_repo_setup.sh | repo_wizard.sh |
| -------------------------------- | ---------------------- | -------------- |
| **Clones repository**            | ❌ No                  | ✅ Yes         |
| **Organizes into ~/projects**    | ❌ No                  | ✅ Yes         |
| **Works with current directory** | ✅ Yes                 | ❌ No          |
| **Interactive prompts**          | ✅ Optional            | ✅ Always      |
| **Command-line args**            | ✅ Yes                 | ✅ Yes         |
| **Best for**                     | Existing repos         | New projects   |

## Post-Setup Steps

### 1. Verify Installation

```bash
# Check what was created
ls -la CLAUDE.md .claude/ scripts/

# View your profile
scripts/profile_show.sh

# See available commands
ls .claude/commands/ | head -20
```

### 2. Test AI Integration

```bash
# Test with a simple command
claude --system-prompt system/active.md "explain this project structure"

# Try a specialized command
claude --system-prompt .claude/commands/think-hard.md "how should we improve this codebase?"
```

### 3. Customize for Your Project

```bash
# Edit project-specific instructions
nano CLAUDE.md

# Add custom commands
echo "Your custom prompt" > .claude/commands/custom/my-command.md

# Adjust profile if needed
scripts/apply_profile.sh --skill l2 --phase beta
```

## Troubleshooting

### "Not a git repository"

The script works with non-git directories but shows a warning:

```bash
# Initialize git if needed
git init
git add .
git commit -m "Initial commit with SoftSensorAI"
```

### "Configuration already exists"

If SoftSensorAI was previously configured:

```bash
# Force overwrite (careful!)
~/softsensorai/setup/existing_repo_setup.sh --force

# Or remove old config first
rm -rf .claude/ CLAUDE.md AGENTS.md scripts/apply_profile.sh
~/softsensorai/setup/existing_repo_setup.sh
```

### "Dependencies not installing"

The script attempts to install dependencies but won't fail if they don't install:

```bash
# Install manually if needed
npm install          # Node.js
pip install -r requirements.txt  # Python
bundle install       # Ruby
```

## Advanced Usage

### Batch Setup with Find

```bash
# Setup all Python projects
find ~/code -name "requirements.txt" -type f | while read req; do
  dir=$(dirname "$req")
  echo "Setting up $dir"
  cd "$dir"
  ~/softsensorai/setup/existing_repo_setup.sh --skill l2 --phase mvp --no-hooks
done
```

### Custom Profile Application

```bash
# Create a custom setup function
setup_my_project() {
  local project_dir="$1"
  cd "$project_dir"

  # Apply SoftSensorAI
  ~/softsensorai/setup/existing_repo_setup.sh --skill expert --phase scale

  # Add standard personas
  for persona in software-architect backend-developer devops-engineer security-engineer; do
    ~/softsensorai/scripts/persona_manager.sh add $persona
  done

  # Custom configurations
  echo "Company-specific instructions" >> CLAUDE.md
  cp ~/company/templates/.claude/commands/* .claude/commands/
}

# Use it
setup_my_project ~/projects/new-service
```

### CI/CD Integration

```bash
# In your CI pipeline (e.g., GitHub Actions)
- name: Setup SoftSensorAI
  run: |
    git clone https://github.com/Softsensor-org/SoftSensorAI.git ~/softsensorai
    ~/softsensorai/setup/existing_repo_setup.sh --skill l2 --phase beta --no-hooks

- name: Run AI Security Review
  run: |
    claude --system-prompt .claude/commands/security-review.md "review all changes"
```

## Best Practices

1. **Start Conservative**: Use `--skill beginner` or `--skill l1` initially
2. **Graduate Phases**: Move from mvp → beta → scale as project matures
3. **Add Personas Gradually**: Start with 1-2, add more as needed
4. **Version Control**: Commit `.claude/`, `CLAUDE.md`, and `AGENTS.md`
5. **Team Alignment**: Ensure all team members use same skill/phase

## Next Steps

After setup, explore:

- [ARCHITECTURE_OVERVIEW.md](ARCHITECTURE_OVERVIEW.md) - Understand the full system
- [WEEK_WITH_DEVPILOT.md](WEEK_WITH_DEVPILOT.md) - Daily workflow examples
- [agent-commands.md](agent-commands.md) - Browse all available commands
- [PERSONAS_GUIDE.md](PERSONAS_GUIDE.md) - Add specialized expertise

---

_existing_repo_setup.sh: The fastest path to AI-assisted development for your existing projects._
