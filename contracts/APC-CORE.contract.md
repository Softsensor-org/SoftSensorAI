---
id: APC-CORE
title: Contract schema, validator, and hash
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - contracts/**
  - .softsensor/**
  - scripts/**
  - package.json
  - package-lock.json
  - pnpm-lock.yaml
  - yarn.lock
forbidden_globs:
  - src/**
  - bin/**
  - docs/**
acceptance_criteria:
  - id: AC-1
    must: MUST define contract file format
    text: A contract file format exists with contracts/<ID>.contract.md with YAML front-matter
    tests:
      - scripts/contract_validate.mjs
  - id: AC-2
    must: MUST validate contracts
    text: Script validates all contracts for missing keys, empty criteria, and duplicate IDs
    tests:
      - scripts/contract_validate.mjs
  - id: AC-3
    must: MUST compute Contract-Hash
    text: Script computes Contract-Hash as sha256 and writes to .softsensor/<ID>.hash
    tests:
      - scripts/contract_validate.mjs
  - id: AC-4
    must: MUST provide npm script
    text: npm run contracts:validate runs the validator and prints short hash
    tests:
      - package.json
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation completed
---

# APC Core: Contract System

This contract introduces human-readable contracts with YAML front-matter, a validator, and a stable Contract-Hash computation system.

## Purpose

Contracts serve as the single source of truth for features, providing:
- Clear ownership and status tracking
- Explicit scope through glob patterns
- Measurable acceptance criteria
- Stable hash for change detection

## Implementation

The contract system consists of:
1. Contract file format (markdown with YAML front-matter)
2. Validation script to ensure contract integrity
3. Hash computation for change tracking
4. NPM scripts for easy execution

## Usage

```bash
# Validate all contracts
npm run contracts:validate
```

This will validate all contracts and compute their hashes, storing them in `.softsensor/` directory.