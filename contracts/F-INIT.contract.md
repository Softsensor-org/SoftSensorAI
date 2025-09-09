---
id: F-INIT
title: CLI dp init bootstrap summary
status: maintained
owner: system
version: 1.0.0
allowed_globs:
  - bin/dp
  - scripts/doctor.sh
  - scripts/apply_profile.sh
  - scripts/system_build.sh
  - system/**
  - tests/contract/F-INIT/**
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST print initialization summary
    text: Shows mode summary with environment details
    tests:
      - tests/contract/F-INIT/output.test.sh
  - id: AC-2
    must: MUST create or update system/active.md
    text: Generates active system prompt file
    tests:
      - tests/contract/F-INIT/files.test.sh
  - id: AC-3
    must: MUST NOT write outside system directory
    text: All file operations confined to system/ and artifacts/
    tests:
      - tests/contract/F-INIT/scope.test.sh
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: maintained
    notes: Core functionality preserved
---

# F-INIT: dp init Bootstrap

This contract ensures the `dp init` command correctly initializes a project with proper configuration and output.

## Features

### Initialization Summary
The command outputs a formatted summary including:
- Project setup status
- Environment configuration
- Mode (single-user vs multi-user)
- Artifacts location
- Next steps guidance

### System File Generation
Creates or updates `system/active.md` containing:
- Merged system prompts
- Project configuration
- Skill level settings
- Phase information

### Scope Constraints
- Writes only to `system/` directory
- Creates `artifacts/` if needed
- No modifications outside these paths

## How to Test

### Manual Testing
```bash
# Run init command
dp init

# Verify output contains:
# - "INITIALIZATION COMPLETE" banner
# - Environment section
# - Next Steps section

# Check files created
ls -la system/active.md
ls -la artifacts/
```

### Automated Tests
```bash
# Run touchpoint tests
bash tests/contract/F-INIT/output.test.sh
bash tests/contract/F-INIT/files.test.sh
bash tests/contract/F-INIT/scope.test.sh
```

## Expected Behavior

### Success Case
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  INITIALIZATION COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Project Setup
  ─────────────
  ✓ Default profile applied (skill=l1, phase=mvp)
  ✓ System prompt built
  ✓ Repository analyzed

  Environment
  ───────────
  Mode         : Single-user
  Artifacts    : ./artifacts

  Next Steps
  ──────────
  1. dp tickets    → Generate structured backlog
  2. dp review     → Review your changes with AI
  3. just dev      → Start development server
  4. dp palette    → Browse all commands

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### File Structure After Init
```
project/
├── system/
│   └── active.md      # Generated system prompt
├── artifacts/         # Working directory for outputs
└── devpilot.project.yml  # Optional project config
```

## Implementation Notes

The init command orchestrates several sub-scripts:
1. `scripts/doctor.sh` - System health check
2. `scripts/apply_profile.sh` - Profile configuration
3. `scripts/system_build.sh` - System prompt generation

All operations are idempotent - running init multiple times is safe.