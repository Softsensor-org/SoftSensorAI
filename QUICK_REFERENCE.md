# 🚀 Quick Reference Card

## Essential Commands (Copy & Paste)

### 🎯 Contract Operations
```bash
# Validate all contracts
npm run contracts:validate

# Check scope for PR
CONTRACT_IDS=APC-CORE npm run contracts:enforce

# Generate PR comment
CONTRACT_IDS=APC-CORE npm run contracts:comment
```

### 🎸 Vibe Flow (Feature Development)
```bash
npm run vibe:start          # Start new feature
npm run vibe:snapshot       # Save progress
npm run vibe:end           # Complete feature
npm run vibe:promote       # Convert to contract
```

### 📊 Quality Checks
```bash
npm run commands:parity    # Check docs completeness
npm run perf:probe        # Performance baseline
npm run budgets:check     # Check perf budgets
```

## Variable Cheat Sheet
```bash
CONTRACT_IDS="A,B,C"      # Multiple contracts
CONTRACT_ID=APC-CORE      # Single contract
BASE_SHA=HEAD~1           # Compare from
HEAD_SHA=HEAD             # Compare to
```

## Common Patterns
```bash
# Multi-contract check
CONTRACT_IDS="APC-CORE,APC-GUARD" npm run contracts:enforce

# PR validation
CONTRACT_IDS=APC-CORE BASE_SHA=main HEAD_SHA=HEAD npm run contracts:enforce

# Local testing
CONTRACT_IDS=APC-ENFORCER npm run contracts:comment | less
```

## All Commands at a Glance
| Category | Commands |
|----------|----------|
| **Contracts** | `validate`, `enforce`, `scope`, `hash`, `comment` |
| **Vibe** | `start`, `snapshot`, `end`, `promote` |
| **Performance** | `budgets:check`, `perf:probe`, `bundle:analyze` |
| **Quality** | `commands:parity`, `test` |
| **Setup** | `hooks:install`, `agent:task` |

## Workflow Examples

### New Feature
```bash
npm run vibe:start && \
  echo "develop..." && \
  npm run vibe:snapshot && \
  npm run vibe:end
```

### PR Check
```bash
npm run contracts:validate && \
  CONTRACT_IDS=APC-CORE npm run contracts:enforce && \
  npm run commands:parity
```

### Performance
```bash
npm run perf:probe && \
  CONTRACT_IDS=APC-BUDGETS npm run budgets:check
```

---
💡 **Tip**: Use `npm run` to list all commands