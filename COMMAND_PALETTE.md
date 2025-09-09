# 🎯 Command Palette Reference

## Quick Start
All commands are available via `npm run` or `pnpm`. Use tab completion for discovery.

```bash
npm run <command>    # Run any command
npm run             # List all available commands
```

## 📋 Contract Management

### Core Contract Commands
| Command | Description | Usage |
|---------|-------------|-------|
| `contracts:validate` | Validate contract YAML syntax | `npm run contracts:validate` |
| `contracts:enforce` | Check scope violations | `CONTRACT_IDS=APC-CORE npm run contracts:enforce` |
| `contracts:scope` | Analyze file scope | `CONTRACT_IDS=APC-CORE npm run contracts:scope` |
| `contracts:hash` | Generate contract hash | `CONTRACT_IDS=APC-CORE npm run contracts:hash` |
| `contracts:comment` | Generate PR comment | `CONTRACT_IDS=APC-CORE npm run contracts:comment` |

### Contract Examples
```bash
# Validate all contracts
npm run contracts:validate

# Check scope for multiple contracts
CONTRACT_IDS="APC-CORE,APC-GUARD" npm run contracts:enforce

# Generate PR comment locally
CONTRACT_IDS=APC-ENFORCER BASE_SHA=HEAD~1 HEAD_SHA=HEAD npm run contracts:comment
```

## 🎸 Vibe Lane (Development Flow)

### Vibe Commands
| Command | Description | Usage |
|---------|-------------|-------|
| `vibe:start` | Start new vibe session | `npm run vibe:start` |
| `vibe:snapshot` | Save progress snapshot | `npm run vibe:snapshot` |
| `vibe:end` | Complete vibe session | `npm run vibe:end` |
| `vibe:promote` | Promote vibe to contract | `npm run vibe:promote` |

### Vibe Workflow
```bash
# Start a new feature
npm run vibe:start
# Enter: FEAT-LOGIN
# Enter: Add OAuth login support

# Save progress
npm run vibe:snapshot

# Complete and promote
npm run vibe:end
npm run vibe:promote
```

## 🤖 Agent & Automation

### Agent Commands
| Command | Description | Usage |
|---------|-------------|-------|
| `agent:task` | Run contract-bound agent | `CONTRACT_ID=APC-CORE npm run agent:task` |
| `hooks:install` | Install git hooks | `npm run hooks:install` |

### Agent Examples
```bash
# Run agent with specific contract
CONTRACT_ID=APC-ENFORCER TASK="Review PR changes" npm run agent:task

# Install contract hooks
npm run hooks:install
```

## 📊 Performance & Quality

### Performance Commands
| Command | Description | Usage |
|---------|-------------|-------|
| `budgets:check` | Check performance budgets | `CONTRACT_IDS=APC-BUDGETS npm run budgets:check` |
| `perf:probe` | Run performance analysis | `npm run perf:probe` |
| `bundle:analyze` | Analyze bundle size | `npm run bundle:analyze` |
| `commands:parity` | Check command/docs parity | `npm run commands:parity` |

### Performance Examples
```bash
# Check contract budgets
CONTRACT_IDS=APC-BUDGETS npm run budgets:check

# Save performance baseline
npm run perf:probe

# Analyze bundle sizes
npm run bundle:analyze
```

## 🧪 Testing

### Test Commands
| Command | Description | Usage |
|---------|-------------|-------|
| `test` | Run test suite | `npm test` |

## 🔧 Environment Variables

### Common Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `CONTRACT_IDS` | Comma-separated contract IDs | `APC-CORE,APC-GUARD` |
| `CONTRACT_ID` | Single contract ID | `APC-ENFORCER` |
| `BASE_SHA` | Base commit for comparison | `HEAD~1` or `main` |
| `HEAD_SHA` | Head commit for comparison | `HEAD` |
| `PR_NUMBER` | GitHub PR number | `123` |
| `GITHUB_TOKEN` | GitHub access token | `ghp_xxxx` |
| `TASK` | Task description for agent | `"Review changes"` |

## 📁 Configuration Files

### Key Files
- `.softsensor/` - Runtime state and hashes
- `contracts/` - Contract definitions
- `.github/workflows/` - CI/CD workflows
- `scripts/` - Implementation scripts

## 🚀 Common Workflows

### 1. Start New Feature
```bash
npm run vibe:start              # Start vibe
# work on feature...
npm run vibe:snapshot           # Save progress
npm run contracts:validate      # Validate contracts
npm run vibe:end                # Complete vibe
npm run vibe:promote            # Promote to contract
```

### 2. Validate PR Changes
```bash
# Check scope violations
CONTRACT_IDS=APC-CORE npm run contracts:enforce

# Check command/docs parity
npm run commands:parity

# Generate PR comment
CONTRACT_IDS=APC-CORE npm run contracts:comment
```

### 3. Performance Check
```bash
# Run performance probe
npm run perf:probe

# Check against budgets
CONTRACT_IDS=APC-BUDGETS npm run budgets:check

# Analyze bundle
npm run bundle:analyze
```

### 4. Contract Development
```bash
# Create new contract
echo "id: NEW-FEATURE" > contracts/NEW-FEATURE.contract.md

# Validate syntax
npm run contracts:validate

# Test enforcement
CONTRACT_IDS=NEW-FEATURE npm run contracts:enforce
```

## 🎨 Command Patterns

### Pattern 1: Environment + Command
```bash
ENV_VAR=value npm run command
```

### Pattern 2: Multiple Environment Variables
```bash
CONTRACT_IDS="A,B" BASE_SHA=main npm run contracts:enforce
```

### Pattern 3: Piped Output
```bash
npm run contracts:comment | head -20
```

### Pattern 4: Conditional Execution
```bash
npm run contracts:validate && npm run contracts:enforce
```

## 💡 Pro Tips

1. **Tab Completion**: Use tab to discover commands
   ```bash
   npm run cont<TAB>  # Shows all contract commands
   ```

2. **List All Commands**: Run without arguments
   ```bash
   npm run  # Lists all available scripts
   ```

3. **Verbose Output**: Add DEBUG for more info
   ```bash
   DEBUG=* npm run contracts:enforce
   ```

4. **Dry Run**: Test commands with echo
   ```bash
   echo "CONTRACT_IDS=APC-CORE npm run contracts:enforce"
   ```

5. **Chain Commands**: Use && for sequences
   ```bash
   npm run contracts:validate && npm run contracts:enforce
   ```

## 🆘 Troubleshooting

### Common Issues

**No contract IDs found**
```bash
# Ensure CONTRACT_IDS is set
export CONTRACT_IDS=APC-CORE
npm run contracts:enforce
```

**Command not found**
```bash
# Install dependencies first
npm install
```

**Permission denied**
```bash
# Make scripts executable
chmod +x scripts/*.mjs
```

**Git diff issues**
```bash
# Ensure you have commits to compare
git log --oneline -5
```

## 📚 Reference

### Contract IDs
- `APC-CORE` - Core functionality
- `APC-GUARD` - Git hooks and guards
- `APC-ENFORCER` - CI enforcement
- `APC-BUDGETS` - Performance budgets
- `APC-PARITY` - Command/docs parity
- `APC-VIBE` - Vibe lane workflow
- `APC-AGENT` - Agent automation
- `APC-DOCS` - Documentation
- `APC-PR` - PR automation
- `APC-DANGER` - PR comments

### File Patterns
- `**/*.js` - All JavaScript files
- `scripts/**` - All scripts
- `*.contract.md` - Contract files
- `.github/workflows/**` - Workflows

---
*Last updated: 2025-09-09*