# Contract-Driven Development Guide

## Overview
This repository uses a contract-driven development approach where every change must be tied to a specific contract that defines its scope, acceptance criteria, and testing requirements.

## Quick Start
1. **Explore**: `ssai vibe start "new feature"` - Start with exploration
2. **Formalize**: `ssai vibe promote` - Generate contract from exploration
3. **Implement**: Make changes within contract scope
4. **Commit**: Include `Contract-Id` and `Contract-Hash` trailers
5. **Pass CI**: Automated scope and budget checks

## What is a Contract?
A contract is a markdown file in the `contracts/` directory that specifies:
- **ID**: Unique identifier for the contract
- **Allowed globs**: File patterns where changes are permitted
- **Forbidden globs**: File patterns where changes are prohibited
- **Acceptance criteria**: Specific requirements that must be met
- **Tests**: Touchpoint tests that verify the implementation

## Workflow

### 1. Before Starting Work
1. Identify or create the contract for your feature
2. Run `npm run contracts:validate` to ensure contract is valid
3. Note the contract hash from `.softsensor/<CONTRACT-ID>.hash`

### 2. During Development
1. Set your active task: Edit `.softsensor/active-task.json`
   ```json
   {
     "contract_id": "YOUR-CONTRACT-ID",
     "allowed_globs": [],
     "forbidden_globs": []
   }
   ```
2. The pre-commit hook will warn if you modify out-of-scope files
3. Use `vibe/` branch prefix for WARN mode during exploration

### 3. Committing Changes
Include contract trailers in your commit message:
```
feat: Implement new feature

Detailed description of changes...

Contract-Id: FEATURE-ABC
Contract-Hash: a1b2c3d4
```

### 4. Creating Pull Requests
The PR template will guide you to:
1. Declare Contract-Id(s) and Contract-Hash(es)
2. Map acceptance criteria to implementation files
3. Verify scope compliance
4. Confirm test passage

### 5. CI Enforcement
GitHub Actions will automatically:
1. Validate all contracts
2. Verify commit trailers exist
3. Check that all changes fall within contract scope
4. Run touchpoint tests before full suite

## Commands

### Validation
```bash
# Validate all contracts
npm run contracts:validate

# Check scope locally (set environment variables)
CONTRACT_IDS="CONTRACT-1 CONTRACT-2" \
BASE_SHA="main" \
HEAD_SHA="HEAD" \
npm run contracts:enforce
```

### Pre-commit Hook
```bash
# Install the pre-commit hook
npm run hooks:install

# Set mode (WARN or BLOCK)
echo "WARN" > .softsensor/mode

# Or use vibe/ branch prefix for automatic WARN mode
git checkout -b vibe/exploration
```

## Complete Workflow Example

### Step 1: Start with Exploration
```bash
# Begin vibe session for experimentation
ssai vibe start "Add user authentication"

# Work freely - WARN mode won't block commits
vim src/auth.js
npm test

# Take snapshots at milestones
ssai vibe snapshot "Basic auth working"
ssai vibe snapshot "Added JWT tokens"

# End session and review impact
ssai vibe end
```

### Step 2: Promote to Contract
```bash
# Auto-generate contract from exploration
ssai vibe promote

# Output:
# ✅ Created contract: contracts/F-M4K8-A9B2.contract.md
# ✅ Created test scaffolds: tests/contract/F-M4K8-A9B2/*.spec.ts
# ✅ Updated active task
# ✅ Switched mode to BLOCK
```

### Step 3: Review and Refine Contract
```yaml
# contracts/F-M4K8-A9B2.contract.md
---
id: F-M4K8-A9B2
title: Add user authentication
status: in_progress
owner: developer
version: 0.1.0
allowed_globs:
  - src/auth/**
  - tests/auth/**
  - config/auth.json
forbidden_globs:
  - src/legacy/**
budgets:                      # Optional performance budgets
  latency_ms_p50: 100
  bundle_kb_delta_max: 25
telemetry:                    # Optional telemetry events
  events:
    - "auth.login"
    - "auth.logout"
acceptance_criteria:
  - id: AC-1
    must: MUST authenticate users
    text: Implement JWT-based authentication
    tests:
      - tests/contract/F-M4K8-A9B2/auth.spec.ts
---
```

### Step 4: Implement and Test
```bash
# Work within contract scope (BLOCK mode active)
vim src/auth/jwt.js  # ✅ Allowed
vim src/legacy.js    # ❌ Blocked by pre-commit hook

# Run contract validation
npm run contracts:validate

# Check budgets if defined
npm run budgets:check
```

### Step 5: Commit with Trailers
```bash
git add .
git commit -m "feat: Implement JWT authentication

- Add JWT token generation and validation
- Configure auth middleware
- Add login/logout endpoints

Contract-Id: F-M4K8-A9B2
Contract-Hash: abc12345"
```

### Step 6: Create Pull Request
The PR template guides you through:
- Declaring Contract-Id and Hash
- Mapping acceptance criteria to files
- Confirming scope compliance

### Step 7: CI Validation
GitHub Actions automatically:
1. Validates contract format
2. Verifies commit trailers
3. Checks file changes against scope
4. Runs touchpoint tests
5. Checks performance budgets
6. Verifies telemetry events

## Contract Format
```yaml
---
id: UNIQUE-ID
title: Human-readable title
status: planned|in_progress|achieved|maintained|deprecated
owner: team-or-person
version: 1.0.0
allowed_globs:
  - src/feature/**
  - tests/feature/**
forbidden_globs:
  - src/legacy/**
budgets:                      # Optional
  latency_ms_p50: 200
  bundle_kb_delta_max: 50
telemetry:                    # Optional
  events:
    - "event.name"
acceptance_criteria:
  - id: AC-1
    must: MUST do something specific
    text: Detailed requirement description
    tests:
      - tests/feature.test.js
checkpoints:                  # Optional progress tracking
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation
---

# Contract Title

Detailed documentation...
```

## Best Practices

### 1. Scope Management
- Keep contracts focused and minimal
- Use specific glob patterns
- Avoid overlapping scopes between contracts

### 2. Commit Messages
- Always include Contract-Id trailer
- Include Contract-Hash for verification
- Reference specific acceptance criteria in the body

### 3. Testing
- Write touchpoint tests for each acceptance criterion
- Keep tests fast and focused
- Run touchpoint tests frequently during development

### 4. Multiple Contracts
When a PR spans multiple contracts:
- List all Contract-Ids in the commit trailer
- The scope is the union of all allowed_globs
- All forbidden_globs still apply
- All touchpoint tests will run

## Examples

### Single Contract Commit
```
fix: Resolve authentication bug

Fixed token refresh logic in auth middleware

Contract-Id: AUTH-FIX-001
Contract-Hash: abc12345
```

### Multiple Contract Commit
```
feat: Add user management system

Implements full CRUD operations for users with RBAC

Contract-Id: USER-CRUD USER-RBAC
Contract-Hash: def67890
```

### Branch Naming
```bash
# Feature development (BLOCK mode by default)
git checkout -b feature/user-management

# Exploration/experimentation (auto WARN mode)
git checkout -b vibe/try-new-auth-approach
```

## Troubleshooting

### "Changes exceed contract scope"
- Verify you're using the correct Contract-Id
- Check if files match allowed_globs patterns
- Ensure no files match forbidden_globs
- Consider if changes belong in a different contract

### "Contract hash mismatch"
- The contract has changed since you started work
- Re-run `npm run contracts:validate` to get new hash
- Update your commit trailer with the new hash

### Pre-commit hook blocking valid changes
- Check `.softsensor/active-task.json` configuration
- Verify contract globs are correct
- Use WARN mode temporarily: `echo "WARN" > .softsensor/mode`

## Migration Guide
For existing code without contracts:
1. Create a legacy contract with broad allowed_globs
2. Gradually refactor into specific contracts
3. Use deprecation status for contracts being phased out