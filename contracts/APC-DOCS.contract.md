---
id: APC-DOCS
title: Contract workflow and vibe lane documentation
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - docs/**
  - README.md
  - contracts/README.md
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST document complete workflow
    text: Step-by-step guide with examples in docs/contracts.md
    tests:
      - docs/contracts.md
  - id: AC-2
    must: MUST document vibe lane
    text: Vibe exploration flow, WARN/BLOCK modes, Q&A
    tests:
      - docs/vibe-lane.md
  - id: AC-3
    must: MUST update README
    text: Quickstart section linking both docs
    tests:
      - README.md
  - id: AC-4
    must: MUST update contracts README
    text: Reference docs and list implemented contracts
    tests:
      - contracts/README.md
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Complete documentation created
---

# APC-DOCS: Contract System Documentation

This contract provides comprehensive documentation for the contract-driven development system.

## Documentation Structure

### docs/contracts.md
Complete guide covering:
- Quick start workflow
- Full example from vibe to CI
- Contract format with all fields
- Best practices
- Troubleshooting

### docs/vibe-lane.md
Vibe exploration guide:
- What is vibe lane
- WARN vs BLOCK modes
- Complete workflow
- Common Q&A
- Tips and tricks
- Integration with other tools

### README.md
Updated with:
- Contract-driven development section
- Quick workflow example
- Links to documentation

### contracts/README.md
Enhanced with:
- Documentation links
- Implemented contracts table
- Quick reference
- Workflow commands

## Key Topics Covered

### Contract Workflow
1. Start with vibe exploration
2. Take snapshots during development
3. Promote to formal contract
4. Refine acceptance criteria
5. Implement within scope
6. Commit with trailers
7. Pass CI checks

### Vibe Lane Features
- Exploration without barriers
- Automatic WARN mode
- Session tracking
- Impact analysis
- Contract generation
- Test scaffolding

### Modes Explained
- **WARN**: Shows warnings, allows commits
- **BLOCK**: Enforces scope, blocks violations
- Automatic mode selection
- Manual override options

### CI Integration
- Contract validation
- Trailer verification
- Scope enforcement
- Touchpoint tests
- Budget checks
- Telemetry verification

## Usage Examples

### Quick Start
```bash
dp vibe start "new idea"
dp vibe promote
git commit -m "feat: implement

Contract-Id: F-ABC123"
```

### Full Workflow
Documented in docs/contracts.md with:
- Real contract examples
- Command outputs
- CI behavior
- Error handling

## Benefits
- Clear onboarding path
- Reduced friction for new developers
- Consistent workflow across team
- Comprehensive reference material