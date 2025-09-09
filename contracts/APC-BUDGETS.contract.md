---
id: APC-BUDGETS
title: Budgets and telemetry checks in CI
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - scripts/**
  - .github/workflows/**
  - package.json
forbidden_globs:
  - src/**
budgets:
  latency_ms_p50: 200
  bundle_kb_delta_max: 50
telemetry:
  events:
    - "track.pageView"
    - "track.userAction"
    - "error.exception"
acceptance_criteria:
  - id: AC-1
    must: MUST extend contract schema
    text: Add support for budgets and telemetry fields in contracts
    tests:
      - scripts/contract_validate.mjs
  - id: AC-2
    must: MUST check performance budgets
    text: Validate latency and bundle size against budgets
    tests:
      - scripts/contract_budgets_and_telemetry.mjs
  - id: AC-3
    must: MUST verify telemetry events
    text: Search codebase for declared telemetry events
    tests:
      - scripts/contract_budgets_and_telemetry.mjs
  - id: AC-4
    must: MUST integrate with CI
    text: Add budget checks to CI workflow as optional step
    tests:
      - .github/workflows/contract-enforcer.yml
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation with placeholders
---

# APC-BUDGETS: Performance Budgets & Telemetry Checks

This contract adds performance budget enforcement and telemetry verification to the contract system.

## Features

### Budget Types
Contracts can now declare performance budgets:
```yaml
budgets:
  latency_ms_p50: 200        # P50 latency must be <= 200ms
  bundle_kb_delta_max: 50     # Bundle size increase <= 50KB
```

### Telemetry Events
Contracts can require specific telemetry events:
```yaml
telemetry:
  events:
    - "track.pageView"
    - "track.userAction"
    - "error.exception"
```

### Validation
The budget checker (`scripts/contract_budgets_and_telemetry.mjs`):
1. Reads performance metrics from file or runs probe
2. Calculates bundle size changes
3. Searches codebase for telemetry events
4. Reports pass/fail for each budget

## Usage

### In Contracts
Add budgets and telemetry to any contract:
```yaml
---
id: FEATURE-PERF
budgets:
  latency_ms_p50: 150
  bundle_kb_delta_max: 25
telemetry:
  events:
    - "analytics.featureUsed"
    - "perf.timing"
---
```

### Local Testing
```bash
# Run performance probe
npm run perf:probe

# Analyze bundle size
npm run bundle:analyze

# Check budgets for contracts
CONTRACT_IDS="FEATURE-PERF" npm run budgets:check
```

### In CI
The workflow automatically:
1. Extracts Contract-Ids from commits
2. Runs budget checks for those contracts
3. Reports results (non-blocking by default)

## Performance Utilities

### Performance Probe
Placeholder implementation that measures command execution time:
```bash
node scripts/utils/performance_probe.mjs "npm run build" --save
```

Outputs:
- P50 and P95 latency
- Average memory usage
- Saves to `artifacts/performance_metrics.json`

### Bundle Analyzer
Calculates total size of JavaScript/TypeScript files:
```bash
node scripts/utils/bundle_analyzer.mjs ./dist
```

Outputs:
- Total size in KB
- File count
- Breakdown by directory

## Telemetry Verification
Searches codebase for event strings using grep:
- Reports files containing each event
- Shows occurrence count
- Non-blocking (warns if missing)

## Integration Points

### With Contract Validation
- Budgets and telemetry included in contract hash
- Changes to budgets trigger hash updates
- Validation ensures correct format

### With CI Pipeline
- Runs after test suite
- Uses CONTRACT_IDS from commit trailers
- Optional pass (doesn't block merge)

## Future Enhancements
- Real performance testing integration
- Webpack bundle analyzer
- Lighthouse CI integration
- Custom budget types
- Trend analysis over time