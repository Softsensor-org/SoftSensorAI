# SoftSensorAI Project Profiles

Zero-friction, per-repository defaults (like Xcode's scheme file, but text).

## Quick Start

```bash
# In any repository
ssai project    # Creates softsensorai.project.yml with sensible defaults
ssai init       # Auto-detects and applies the profile
```

That's it! No flags, no decisions. It just works.

## How It Works

1. **Create**: `ssai project` generates a `softsensorai.project.yml` with smart defaults
2. **Customize**: Edit the YAML file to match your project needs
3. **Apply**: `ssai init` automatically detects and uses your profile
4. **Commit**: Check the file into version control for team consistency

## File Locations (in order of precedence)

- `softsensorai.project.yml` (preferred, visible)
- `softsensorai.project.yaml`
- `.softsensorai.yml` (hidden alternative)
- `.softsensorai.yaml`

## Profile Structure

### Minimal Profile

```yaml
# softsensorai.project.yml
profile:
  skill: l2 # Your team's skill level
  phase: mvp # Current project phase
  teach_mode: false # Verbose AI explanations
```

### Complete Profile

```yaml
# Project metadata
project:
  name: "my-awesome-app"
  description: "AI-first development"
  version: "0.1.0"

# Development profile (auto-applied)
profile:
  skill: l2 # l1=beginner, l2=intermediate, l3=expert, l4=architect
  phase: mvp # poc, mvp, beta, scale
  teach_mode: false

# AI personas to activate
personas:
  primary: pragmatic-coder
  secondary:
    - security-reviewer
    - data-scientist

# CI/CD configuration
ci:
  gates:
    lint: required # required, advisory, or skip
    typecheck: required
    tests: required
    coverage: advisory

  thresholds:
    coverage: 60 # Minimum coverage %
    vulnerabilities:
      critical: 0 # No critical vulns
      high: 3 # Max 3 high

# Development environment
environment:
  runtime: node
  package_manager: pnpm
  required_tools:
    - git
    - docker
```

## Common Profiles

### Frontend Project

```yaml
profile:
  skill: l2
  phase: mvp

personas:
  primary: frontend-specialist
  secondary:
    - accessibility-expert

ci:
  thresholds:
    lighthouse_score: 90
    bundle_size: 2MB
```

### API Service

```yaml
profile:
  skill: l3
  phase: beta

personas:
  primary: backend-architect
  secondary:
    - security-reviewer

ci:
  gates:
    tests: required
    coverage: required
  thresholds:
    coverage: 80
```

### Data/ML Project

```yaml
profile:
  skill: l2
  phase: poc

personas:
  primary: data-scientist

environment:
  runtime: python
  required_tools:
    - python3
    - jupyter
    - docker
```

## CI Integration

The profile automatically configures CI behavior:

```yaml
ci:
  gates:
    lint: required # Fails build
    tests: required # Fails build
    coverage: advisory # Warning only
    security: advisory # Warning only
```

This generates appropriate CI workflows that respect your phase:

- **POC**: Minimal checks, focus on speed
- **MVP**: Core quality gates (lint, test, build)
- **Beta**: + coverage, security scans
- **Scale**: + performance, compliance

## Team Workflows

### Onboarding New Developer

```bash
# New dev clones repo
git clone <repo>
cd <repo>

# One command setup
ssai init  # Reads softsensorai.project.yml, configures everything
```

### Changing Project Phase

```yaml
# Edit softsensorai.project.yml
profile:
  phase: beta  # was: mvp

# Apply changes
ssai init  # Updates CI, permissions, etc.
```

### Per-Developer Overrides

```bash
# Local override (not committed)
cp softsensorai.project.yml .softsensorai.local.yml
# Edit .softsensorai.local.yml with personal preferences

# Add to .gitignore
echo ".softsensorai.local.yml" >> .gitignore
```

## Advanced Features

### Custom Commands

```yaml
commands:
  aliases:
    ship: "just build && just deploy"
    review: "ssai review"
    clean: "rm -rf node_modules dist"
```

Use: `ssai ship`, `ssai clean`

### Feature Flags

```yaml
features:
  use_ai_commits: true # AI generates commit messages
  use_ai_pr_description: true # AI writes PR descriptions
  auto_format_on_save: true # Format before commit
  strict_mode: false # Enforce all conventions
```

### Branch Conventions

```yaml
conventions:
  branches:
    main: main
    feature_prefix: feat/
    bugfix_prefix: fix/

  commits:
    format: conventional # conventional, semantic, custom
```

## Migration Guide

### From Manual Flags

Before:

```bash
scripts/apply_profile.sh --skill l2 --phase mvp --teach-mode off
```

After:

```bash
ssai init  # Reads from softsensorai.project.yml
```

### From Environment Variables

Before:

```bash
export SOFTSENSORAI_SKILL=l2
export SOFTSENSORAI_PHASE=mvp
```

After:

```yaml
# softsensorai.project.yml
profile:
  skill: l2
  phase: mvp
```

## Best Practices

1. **Commit the profile**: Include `softsensorai.project.yml` in version control
2. **Start simple**: Begin with minimal profile, add sections as needed
3. **Document decisions**: Use comments to explain non-obvious choices
4. **Review regularly**: Update phase/skill as project evolves
5. **Team agreement**: Discuss and agree on profile settings

## Comparison to Other Tools

| Tool             | File                      | Approach                     |
| ---------------- | ------------------------- | ---------------------------- |
| **SoftSensorAI** | `softsensorai.project.yml`    | Zero-friction, auto-detected |
| Xcode            | `.xcscheme`               | GUI-based, complex           |
| VS Code          | `.vscode/settings.json`   | Editor-specific              |
| EditorConfig     | `.editorconfig`           | Format-only                  |
| Pre-commit       | `.pre-commit-config.yaml` | Hooks-only                   |

SoftSensorAI profiles are holistic—they configure AI behavior, CI/CD, team conventions, and
development environment in one place.

## Troubleshooting

### Profile not detected

```bash
# Check file exists
ls -la softsensorai.project.yml

# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('softsensorai.project.yml'))"

# Debug mode
SOFTSENSORAI_DEBUG=1 ssai init
```

### Settings not applied

```bash
# Check current profile
cat PROFILE.md

# Force reapply
rm -rf .claude/ system/ PROFILE.md
ssai init
```

### CI not updated

```bash
# Regenerate CI workflow
scripts/apply_profile.sh --phase beta
git add .github/workflows/
git commit -m "chore: Update CI for beta phase"
```

## Examples

See `templates/softsensorai.project.yml` for a complete example with all options documented.
