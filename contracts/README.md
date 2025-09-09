# Contract System

Contracts define features as human-readable markdown files with YAML front-matter. They serve as the single source of truth for all features.

## Format

Each contract lives at `contracts/<ID>.contract.md` with required YAML front-matter:

```yaml
---
id: FEATURE-ID
title: Human readable title
status: planned | in_progress | achieved | maintained | deprecated
owner: owner-name
version: 1.0.0
allowed_globs:
  - src/feature/**
  - tests/feature/**
forbidden_globs:  # optional
  - src/legacy/**
acceptance_criteria:
  - id: AC-1
    must: MUST do something specific
    text: Detailed description of the criterion
    tests:
      - test/feature.test.js
checkpoints:  # optional
  - id: CP-1
    date: 2024-01-01
    status: completed
    notes: Initial implementation done
---

# Feature Name

Full markdown documentation of the feature...
```

## Example Contract

```yaml
---
id: AUTH-CORE
title: Authentication Core Module
status: in_progress
owner: team-auth
version: 1.0.0
allowed_globs:
  - src/auth/**
  - tests/auth/**
  - contracts/auth/**
forbidden_globs:
  - src/legacy/auth/**
acceptance_criteria:
  - id: AC-AUTH-1
    must: MUST validate JWT tokens
    text: System validates incoming JWT tokens and rejects invalid/expired ones
    tests:
      - tests/auth/jwt.test.js
  - id: AC-AUTH-2
    must: MUST support refresh tokens
    text: System provides refresh token mechanism with 7-day expiry
    tests:
      - tests/auth/refresh.test.js
checkpoints:
  - id: CP-1
    date: 2024-01-15
    status: completed
    notes: JWT validation implemented
---

# Authentication Core Module

This contract defines the authentication system requirements...
```

## Validation

Run validation with:
```bash
npm run contracts:validate
```

This will:
1. Validate all contract files for required fields
2. Check for duplicate IDs
3. Ensure acceptance criteria are not empty
4. Compute and store Contract-Hash in `.softsensor/<ID>.hash`

## Contract-Hash

The Contract-Hash is computed as `sha256(JSON.stringify({id, allowed_globs, acceptance_criteria}))` and stored in `.softsensor/<ID>.hash`. This provides a stable fingerprint of the contract's core requirements.