---
id: APC-PR
title: PR template and commit trailer policy
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - .github/pull_request_template.md
  - docs/**
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST have PR template with contract fields
    text: Template includes Contract-Id, Contract-Hash, and criterion mapping
    tests:
      - .github/pull_request_template.md
  - id: AC-2
    must: MUST document contract policy
    text: Clear documentation of contract-driven development workflow
    tests:
      - docs/contracts.md
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation
---

# APC-PR: PR Template and Commit Trailer Policy

This contract establishes the pull request template and documentation for contract-driven development.

## Features

### PR Template
The template ensures every PR:
- Declares which contracts it implements
- Maps acceptance criteria to files
- Verifies scope compliance
- Confirms test passage

### Documentation
Comprehensive guide covering:
- Contract format and structure
- Development workflow
- Commit trailer format
- Best practices and examples
- Troubleshooting guide

## Usage

### For Contributors
1. Use the PR template when opening PRs
2. Fill in Contract-Id and Contract-Hash fields
3. Map your changes to acceptance criteria
4. Verify all checklist items

### For Reviewers
1. Check that Contract-Id matches the changes
2. Verify acceptance criteria are met
3. Confirm tests pass
4. Ensure scope compliance

## Commit Trailer Format
```
<type>: <description>

<detailed description>

Contract-Id: <id> [<id2>...]
Contract-Hash: <hash>
```

## Benefits
- Clear traceability from requirements to implementation
- Automated scope enforcement
- Consistent PR structure
- Reduced review friction