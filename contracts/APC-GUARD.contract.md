---
id: APC-GUARD
title: Pre-commit scope guard with WARN/BLOCK modes
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - .git/hooks/**
  - scripts/**
  - .softsensor/**
  - package.json
  - package-lock.json
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST use active-task.json convention
    text: Add .softsensor/active-task.json with contract_id, allowed_globs, forbidden_globs
    tests:
      - scripts/precommit_guard.mjs
  - id: AC-2
    must: MUST implement pre-commit hook
    text: Pre-commit hook reads active-task.json and enforces scope based on mode
    tests:
      - scripts/precommit_guard.mjs
  - id: AC-3
    must: MUST support WARN and BLOCK modes
    text: WARN mode prints warnings but allows commit, BLOCK mode aborts on violations
    tests:
      - scripts/precommit_guard.mjs
  - id: AC-4
    must: MUST provide cross-platform installer
    text: npm run hooks:install installs the hook on all platforms
    tests:
      - scripts/install_hooks.mjs
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation completed
---

# APC-GUARD: Pre-commit Scope Guard

This contract implements a pre-commit hook that enforces scope boundaries based on the active contract's allowed and forbidden globs.

## Features

### Active Task Configuration
The system uses `.softsensor/active-task.json` to define the current working context:
```json
{
  "contract_id": "FEATURE-ID",
  "allowed_globs": ["src/feature/**"],
  "forbidden_globs": ["src/legacy/**"]
}
```

### Modes
- **WARN mode**: Prints warnings for out-of-scope files but allows commit
- **BLOCK mode**: Aborts commit if files are out of scope or forbidden

Mode is determined by:
1. Branch prefix `vibe/` → WARN mode
2. `.softsensor/mode` file content
3. Default: BLOCK mode

### Installation
```bash
npm run hooks:install
```

This installs the pre-commit hook that:
1. Reads `.softsensor/active-task.json`
2. If missing, skips check
3. If present, loads contract globs
4. Checks staged files against allowed/forbidden patterns
5. In WARN mode: prints warnings
6. In BLOCK mode: aborts on violations

## Usage

1. Run `npm run hooks:install` to set up the hook
2. Edit `.softsensor/active-task.json` to set your active contract
3. The hook will automatically enforce scope on commits