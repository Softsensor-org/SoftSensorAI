---
id: F-SETUP
title: Single-user setup next-steps
status: maintained
owner: system
version: 1.0.0
allowed_globs:
  - bin/dp
  - setup/**
  - tests/contract/F-SETUP/**
forbidden_globs:
  - src/**
budgets:
  latency_ms_p50: 500
acceptance_criteria:
  - id: AC-1
    must: MUST show correct CLI name
    text: Banner displays 'dp' as primary command, not legacy names
    tests:
      - tests/contract/F-SETUP/banner.test.sh
  - id: AC-2
    must: MUST use correct paths
    text: Paths point to softsensorai directories, not softsensorai
    tests:
      - tests/contract/F-SETUP/paths.test.sh
  - id: AC-3
    must: MUST print next-steps block
    text: Shows structured next-steps guidance after setup
    tests:
      - tests/contract/F-SETUP/next-steps.test.sh
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: maintained
    notes: Branding and workflow preserved
---

# F-SETUP: Setup Workflow Standards

This contract ensures the `dp setup` command provides correct branding, paths, and guidance.

## Features

### Correct Branding
- Uses "dp" as primary command
- References SoftSensorAI, not legacy names
- Consistent naming throughout output

### Path Validation
- Points to `~/softsensorai` for installation
- Uses `.softsensor/` for configuration
- No references to old `softsensorai` paths

### Next-Steps Guidance
Structured output block containing:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SETUP COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Next Steps
  ──────────
  1. dp init       → Initialize project settings
  2. dp palette    → Browse available commands
  3. dp review     → Review your changes with AI

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## How to Test

### Manual Testing
```bash
# Test setup in current directory
mkdir test-project && cd test-project
dp setup

# Verify output:
# - Shows "SOFTSENSORAI SETUP" or "SETUP COMPLETE" banner
# - Uses "dp" in command examples
# - No "softsensorai" paths shown

# Test with repository URL
dp setup https://github.com/example/repo
```

### Automated Tests
```bash
# Run touchpoint tests
bash tests/contract/F-SETUP/banner.test.sh
bash tests/contract/F-SETUP/paths.test.sh
bash tests/contract/F-SETUP/next-steps.test.sh
```

## Expected Behavior

### Setup Banner
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SOFTSENSORAI SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Completion Banner
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SETUP COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Next Steps
  ──────────
  1. dp init       → Initialize project settings
  2. dp palette    → Browse available commands
  3. dp review     → Review your changes with AI

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Correct Commands
All examples use `dp`:
- `dp init` (not `softsensorai init`)
- `dp setup` (not `softsensorai setup`)
- `dp review` (not `softsensorai review`)

### Correct Paths
- Installation: `~/softsensorai`
- Config: `.softsensor/`
- Artifacts: `artifacts/`

## Implementation Notes

### Setup Modes
The command detects context and adapts:
1. **Existing repo**: Adds configuration files
2. **New URL**: Clones and configures
3. **No repo**: Interactive mode with options

### Workflow Options
```
1) Setup current directory as new project
2) Clone a repository and setup
3) Setup customer project (multiple repos)
4) Exit
```

### Files Created
After successful setup:
- `CLAUDE.md` - Project instructions
- `.claude/` - Command definitions
- `softsensorai.project.yml` - Project configuration
- `.softsensor/` - Runtime configuration

## Performance Budget

The setup command has a performance budget:
- P50 latency: 500ms max
- This ensures quick initialization

## Common Issues

### Wrong CLI Name
If seeing old names, check:
- `bin/dp` script version
- Environment PATH order
- Aliases in shell config

### Wrong Paths
If seeing softsensorai paths:
- Check installation directory
- Verify symlinks
- Review environment variables

### Missing Next Steps
If next-steps block missing:
- Ensure setup completed successfully
- Check for errors in output
- Verify all required files exist