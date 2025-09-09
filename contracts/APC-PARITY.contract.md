---
id: APC-PARITY
title: Command documentation parity check
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - scripts/**
  - .github/workflows/**
  - docs/commands/**
  - package.json
forbidden_globs:
  - src/**
  - bin/**  # read-only, no logic changes
acceptance_criteria:
  - id: AC-1
    must: MUST enumerate bin/dp commands
    text: Extract all commands from bin/dp case statement
    tests:
      - scripts/commands_parity.mjs
  - id: AC-2
    must: MUST enumerate docs/commands pages
    text: List all documentation files in docs/commands/dp/
    tests:
      - scripts/commands_parity.mjs
  - id: AC-3
    must: MUST fail on parity mismatch
    text: Exit with error if commands missing documentation or vice versa
    tests:
      - scripts/commands_parity.mjs
  - id: AC-4
    must: MUST run in CI
    text: GitHub Actions workflow checks parity on PRs
    tests:
      - .github/workflows/commands-parity.yml
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation with CI integration
---

# APC-PARITY: Command/Documentation Parity

This contract ensures that all implemented commands have corresponding documentation and vice versa.

## Features

### Command Extraction
The parity checker extracts commands from two sources:
1. **bin/dp** - Parses cmd_* functions and case statement
2. **docs/commands/dp/** - Lists all .md documentation files

### Parity Validation
Compares the two lists and identifies:
- **Undocumented commands** - Implemented but no docs
- **Unimplemented commands** - Docs exist but no implementation

### CI Integration
Runs automatically on pull requests when:
- Commands are added/modified in bin/
- Documentation changes in docs/commands/
- The parity script itself is modified

## How to Use

### Local Check
```bash
# Run parity check
npm run commands:parity

# Get detailed report
node scripts/commands_parity.mjs --detailed
```

### CI Workflow
The check runs automatically on PRs. If parity is broken:
1. CI fails with detailed report
2. Shows which commands need documentation
3. Suggests fix commands

### Fix Parity Issues

#### For Undocumented Commands
```bash
# Create documentation file
touch docs/commands/dp/newcommand.md

# Add content with structure:
# - Description
# - Usage
# - Options
# - Examples
```

#### For Unimplemented Commands
Either:
1. Implement the command in bin/dp
2. Remove stale documentation

## Current Status

As of implementation, the following commands need documentation:
- Core commands: agent, apiize, testgen
- Utility commands: palette, patterns, worktree
- Management: profile, persona, score
- Workflow: vibe, review, tickets
- Setup: customer-project, migrate

This is expected as the project focuses on infrastructure first, documentation second.

## Benefits

### Prevents Documentation Drift
- Catches when new commands lack documentation
- Identifies stale documentation for removed commands
- Ensures users can find help for all commands

### Maintains Quality
- Forces documentation as part of feature development
- Makes missing documentation visible in CI
- Provides clear fix instructions

### Supports Discovery
- Users can trust docs match implementation
- Developers know what needs documenting
- Automated tracking reduces manual review

## Implementation Notes

### Command Detection
Uses regex patterns to find:
```javascript
// Function definitions
/^cmd_[a-z_]+\(\)/gm

// Case statement entries
/^\s+([a-z-]+)\)\s*shift;\s*cmd_/gm
```

### Documentation Detection
Scans `docs/commands/dp/*.md` files and maps to command names.

### Edge Cases Handled
- Filters out help flags (-h, --help)
- Ignores internal functions
- Validates command name format
- Handles missing directories gracefully

## Future Enhancements

- Auto-generate documentation stubs
- Extract help text from commands
- Validate documentation quality
- Cross-reference with README
- Generate command index page