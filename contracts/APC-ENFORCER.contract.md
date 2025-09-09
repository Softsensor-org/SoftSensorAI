---
id: APC-ENFORCER
title: CI Contract Enforcer workflow
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - .github/workflows/**
  - scripts/**
  - package.json
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST have GitHub Actions workflow
    text: Workflow validates contracts and enforces scope on PRs
    tests:
      - .github/workflows/contract-enforcer.yml
  - id: AC-2
    must: MUST verify commit trailers
    text: Check for Contract-Id and Contract-Hash in commits
    tests:
      - scripts/contract_scope_and_hash.mjs
  - id: AC-3
    must: MUST enforce scope across multiple contracts
    text: Union allowed globs from all referenced contracts
    tests:
      - scripts/contract_scope_and_hash.mjs
  - id: AC-4
    must: MUST run touchpoint tests first
    text: Execute contract-specific tests before full suite
    tests:
      - .github/workflows/contract-enforcer.yml
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation
---

# APC-ENFORCER: CI Contract Enforcer

This contract implements GitHub Actions workflow to enforce contract compliance on pull requests.

## Features

### Commit Trailers
Commits must include trailers indicating which contracts they implement:
```
feat: Add new feature

Contract-Id: FEATURE-ABC
Contract-Hash: a1b2c3d4
```

### Scope Enforcement
- Changes must fall within the union of `allowed_globs` from all referenced contracts
- No changes allowed in `forbidden_globs` patterns
- Multiple contracts can be referenced in a single PR

### Test Prioritization
1. Touchpoint tests from referenced contracts run first
2. If touchpoint tests pass, full test suite runs
3. Faster feedback for contract-specific changes

## Usage

### In Pull Requests
The workflow automatically runs on all PRs to enforce:
1. Contract validation (schema correctness)
2. Commit trailer verification
3. Scope enforcement
4. Test execution

### Local Testing
```bash
# Validate all contracts
npm run contracts:validate

# Test scope enforcement
CONTRACT_IDS="APC-CORE APC-GUARD" \
CONTRACT_HASH="12345678" \
BASE_SHA="main" \
HEAD_SHA="HEAD" \
npm run contracts:enforce
```

## Commit Message Format
```
<type>: <description>

<body>

Contract-Id: <contract-id> [<another-id>...]
Contract-Hash: <combined-hash>
```