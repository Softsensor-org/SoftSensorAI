---
id: APC-SEED
title: Seed contracts for regression testing
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - contracts/**
  - tests/contract/**
  - .softsensor/**
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST create F-INIT contract
    text: CLI dp init bootstrap with tests
    tests:
      - contracts/F-INIT.contract.md
      - tests/contract/F-INIT/*.sh
  - id: AC-2
    must: MUST create F-PALETTE contract
    text: dp palette fzf requirement with tests
    tests:
      - contracts/F-PALETTE.contract.md
      - tests/contract/F-PALETTE/*.sh
  - id: AC-3
    must: MUST create F-SETUP contract
    text: Setup workflow standards with tests
    tests:
      - contracts/F-SETUP.contract.md
      - tests/contract/F-SETUP/*.sh
  - id: AC-4
    must: MUST generate hashes
    text: Contract validator creates .softsensor/*.hash files
    tests:
      - .softsensor/F-INIT.hash
      - .softsensor/F-PALETTE.hash
      - .softsensor/F-SETUP.hash
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Three seed contracts with tests created
---

# APC-SEED: Seed Contracts for Testing

This contract establishes three maintained contracts that serve as regression tests for core functionality.

## Seed Contracts

### F-INIT: CLI Bootstrap
- **Purpose**: Ensure dp init works correctly
- **Tests**: Output format, file creation, scope limits
- **Status**: maintained

### F-PALETTE: fzf Dependency
- **Purpose**: Verify proper dependency handling
- **Tests**: Error messages, exit codes, no side effects
- **Status**: maintained

### F-SETUP: Setup Standards
- **Purpose**: Validate branding and workflow
- **Tests**: CLI names, paths, next-steps guidance
- **Status**: maintained

## Test Coverage

Each seed contract includes multiple touchpoint tests:

### F-INIT Tests
- `output.test.sh` - Initialization summary format
- `files.test.sh` - system/active.md creation
- `scope.test.sh` - No writes outside allowed paths

### F-PALETTE Tests
- `fzf-check.test.sh` - Dependency detection
- `error-message.test.sh` - Actionable hints
- `exit-code.test.sh` - Proper exit codes
- `no-side-effects.test.sh` - Clean failure

### F-SETUP Tests
- `banner.test.sh` - Correct CLI naming
- `paths.test.sh` - Proper directory references
- `next-steps.test.sh` - Structured guidance

## Running Tests

### All Seed Tests
```bash
# Run all F-INIT tests
for test in tests/contract/F-INIT/*.sh; do
    bash "$test"
done

# Run all F-PALETTE tests
for test in tests/contract/F-PALETTE/*.sh; do
    bash "$test"
done

# Run all F-SETUP tests
for test in tests/contract/F-SETUP/*.sh; do
    bash "$test"
done
```

### Individual Tests
```bash
bash tests/contract/F-INIT/output.test.sh
bash tests/contract/F-PALETTE/fzf-check.test.sh
bash tests/contract/F-SETUP/banner.test.sh
```

## Validation

All seed contracts are validated with:
```bash
npm run contracts:validate
```

This ensures:
- Contract format is correct
- All required fields present
- Acceptance criteria valid
- Hashes generated in `.softsensor/`

## Benefits

### Regression Prevention
These maintained contracts catch:
- CLI command breaking changes
- Output format regressions
- Dependency handling issues
- Branding inconsistencies
- Path errors

### Documentation as Tests
Each contract serves as:
- Living documentation
- Executable specification
- Regression test suite
- Onboarding guide

### CI Integration
In CI, these contracts:
- Run first (touchpoint tests)
- Provide fast feedback
- Block merges on failure
- Maintain quality baseline