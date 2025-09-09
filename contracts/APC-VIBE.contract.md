---
id: APC-VIBE
title: Vibe lane scripts for exploration workflow
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - scripts/**
  - .softsensor/**
  - contracts/**
  - tests/contract/**
  - package.json
  - bin/dp
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST implement vibe start command
    text: Create vibe branch, set WARN mode, initialize session
    tests:
      - scripts/vibe_start.mjs
  - id: AC-2
    must: MUST implement vibe snapshot command
    text: Create lightweight tags with diff summaries
    tests:
      - scripts/vibe_snapshot.mjs
  - id: AC-3
    must: MUST implement vibe end command
    text: Generate impact report of exploration
    tests:
      - scripts/vibe_end.mjs
  - id: AC-4
    must: MUST implement vibe promote command
    text: Auto-generate contract and test scaffolds from exploration
    tests:
      - scripts/vibe_promote.mjs
  - id: AC-5
    must: MUST integrate with dp CLI
    text: Add vibe subcommands to main CLI
    tests:
      - bin/dp
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation
---

# APC-VIBE: Vibe Lane Exploration Workflow

This contract implements a "vibe lane" for experimental development with relaxed guards and streamlined promotion to formal contracts.

## Features

### Vibe Commands
- **`dp vibe start "<title>"`** - Start exploration session
  - Creates `vibe/<slug>` branch
  - Sets mode to WARN (non-blocking)
  - Initializes `.softsensor/session.json`

- **`dp vibe snapshot "[note]"`** - Checkpoint progress
  - Creates lightweight git tag
  - Records diff summary
  - Tracks changed files

- **`dp vibe end`** - Complete exploration
  - Generates impact report
  - Groups files by directory
  - Suggests allowed_globs for contract

- **`dp vibe promote`** - Formalize exploration
  - Auto-generates contract from session
  - Creates test scaffolds for each criterion
  - Updates active-task.json
  - Switches mode to BLOCK

### Session Tracking
The system maintains `.softsensor/session.json` throughout the exploration:
```json
{
  "title": "Exploration title",
  "branch": "vibe/exploration-slug",
  "started_at": "2024-12-09T10:00:00Z",
  "snapshots": [...],
  "impact": {
    "files_changed": 15,
    "directories": ["scripts", "tests"],
    "suggested_globs": ["scripts/**", "tests/**"]
  }
}
```

## Workflow

### 1. Start Exploration
```bash
dp vibe start "Try new authentication approach"
# Creates vibe/try-new-authentication-approach branch
# Sets WARN mode for flexibility
```

### 2. Develop Freely
Make changes without strict scope enforcement. The pre-commit hook will warn but not block.

### 3. Take Snapshots
```bash
dp vibe snapshot "Basic auth working"
dp vibe snapshot "Added OAuth support"
```

### 4. End Session
```bash
dp vibe end
# Shows impact report with changed files
# Suggests globs for contract
```

### 5. Promote to Contract
```bash
dp vibe promote
# Creates contracts/F-<ID>.contract.md
# Generates tests/contract/F-<ID>/*.spec.ts
# Updates active-task.json
# Switches to BLOCK mode
```

## Benefits

### For Developers
- Start exploring immediately without planning
- WARN mode allows experimentation
- Snapshots provide checkpoints
- Automatic contract generation

### For Teams
- Exploration is tracked and documented
- Easy transition from prototype to production
- Test scaffolds ensure quality
- Impact analysis shows scope

## NPM Scripts
```bash
npm run vibe:start     # Start session
npm run vibe:snapshot  # Take snapshot
npm run vibe:end       # End session
npm run vibe:promote   # Generate contract
```

## Example Session
```bash
# Start exploring a new feature
dp vibe start "Add real-time notifications"

# Work on the feature...
vim scripts/notify.js

# Checkpoint progress
dp vibe snapshot "WebSocket connection established"

# Continue development...
vim tests/notify.test.js

# Finish exploration
dp vibe end

# Review impact and promote
dp vibe promote
# Contract F-M4K8-A9B2 created!
```