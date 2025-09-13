# Vibe Lane: Exploration-First Development

## What is Vibe Lane?

Vibe Lane is a workflow for exploratory development that lets you experiment freely before formalizing your work into a contract. It provides:

- **WARN mode**: Pre-commit hooks warn but don't block
- **Session tracking**: Records your exploration journey
- **Automatic promotion**: Generates contracts from your work
- **Test scaffolding**: Creates test templates automatically

## Quick Start

```bash
# 1. Start exploring
ssai vibe start "Try new caching strategy"

# 2. Work freely (WARN mode active)
vim src/cache.js
npm test

# 3. Take snapshots
ssai vibe snapshot "Redis integration working"

# 4. Review and promote
ssai vibe end      # See impact report
ssai vibe promote  # Generate contract
```

## Detailed Workflow

### Starting a Vibe Session

```bash
ssai vibe start "Experiment with WebSockets"
```

This command:
1. Creates branch `vibe/experiment-with-websockets`
2. Sets mode to WARN (non-blocking)
3. Initializes `.softsensor/session.json`
4. Starts tracking your exploration

### Working in WARN Mode

In WARN mode, the pre-commit hook will:
- **Warn** about out-of-scope files
- **Allow** commits to proceed
- **Track** all changes for later analysis

```bash
$ git commit -m "test websocket connection"

🔍 Scope Guard (WARN mode)
   Active contract: none

Warnings:
   ⚠️  Out of scope: src/experimental/websocket.js
   ⚠️  Out of scope: tests/websocket.test.js

# Commit proceeds anyway ✅
```

### Taking Snapshots

Capture milestones during exploration:

```bash
ssai vibe snapshot "Basic connection established"
ssai vibe snapshot "Implemented pub/sub pattern"
ssai vibe snapshot "Added reconnection logic"
```

Each snapshot:
- Creates a lightweight git tag
- Records diff summary
- Tracks changed files
- Adds note to session

### Ending a Session

```bash
ssai vibe end
```

Generates an impact report:

```
🏁 Ending vibe session
   Title: Experiment with WebSockets
   Started: 2024-12-09T10:00:00Z
   Snapshots: 3

📊 Impact Report
   Total files changed: 8

📁 Files by directory:
   src/websocket/
     - client.js
     - server.js
     - events.js
   tests/
     - websocket.test.js

💡 Suggested allowed_globs for contract:
   - src/websocket/**
   - tests/**
```

### Promoting to Contract

```bash
ssai vibe promote
```

Automatically:
1. Generates contract from session data
2. Creates test scaffolds for each criterion
3. Updates `.softsensor/active-task.json`
4. Switches mode to BLOCK

Output:
```
🚀 Promoting vibe session to contract
   Contract ID: F-M5N9-B2C3

✅ Created contract: contracts/F-M5N9-B2C3.contract.md
✅ Created test scaffold: tests/contract/F-M5N9-B2C3/core.spec.ts
✅ Created test scaffold: tests/contract/F-M5N9-B2C3/config.spec.ts
✅ Updated active task
✅ Switched mode to BLOCK

Next steps:
1. Review the contract in contracts/F-M5N9-B2C3.contract.md
2. Refine acceptance criteria as needed
3. Implement tests in tests/contract/F-M5N9-B2C3/
4. Commit with Contract-Id: F-M5N9-B2C3
```

## WARN vs BLOCK Modes

### WARN Mode (Exploration)
- **Purpose**: Allow experimentation
- **Behavior**: Shows warnings but allows commits
- **When**: During vibe sessions or exploration
- **Activation**:
  - Automatic on `vibe/*` branches
  - Manual: `echo "WARN" > .softsensor/mode`

### BLOCK Mode (Implementation)
- **Purpose**: Enforce contract scope
- **Behavior**: Blocks commits with violations
- **When**: During formal implementation
- **Activation**:
  - Default mode
  - After `ssai vibe promote`
  - Manual: `echo "BLOCK" > .softsensor/mode`

## Common Q&A

### Q: Can I switch between modes manually?
**A:** Yes! Use:
```bash
echo "WARN" > .softsensor/mode   # Switch to WARN
echo "BLOCK" > .softsensor/mode  # Switch to BLOCK
```

### Q: What if I forget to end a vibe session?
**A:** No problem! `ssai vibe promote` will automatically end the session first:
```bash
ssai vibe promote  # Runs 'ssai vibe end' if needed
```

### Q: Can I have multiple vibe sessions?
**A:** One at a time. End the current session before starting a new one:
```bash
ssai vibe end      # Close current
ssai vibe start "New exploration"
```

### Q: How do I resume an interrupted session?
**A:** Checkout the vibe branch and continue:
```bash
git checkout vibe/my-exploration
ssai vibe snapshot "Resuming work"
```

### Q: What happens to snapshots after promotion?
**A:** Git tags remain for history. The session file is preserved with the contract reference.

### Q: Can I skip vibe and create contracts directly?
**A:** Yes! Vibe is optional. You can:
- Write contracts manually in `contracts/`
- Use existing contract templates
- Start with strict mode from the beginning

### Q: How do I handle merge conflicts in vibe branches?
**A:** Same as regular branches:
```bash
git checkout main
git pull origin main
git checkout vibe/my-feature
git rebase main  # or merge
```

### Q: Can I convert an existing branch to vibe?
**A:** Yes! Just rename it:
```bash
git branch -m my-feature vibe/my-feature
echo "WARN" > .softsensor/mode
```

## Tips and Tricks

### 1. Use Descriptive Snapshot Notes
```bash
ssai vibe snapshot "Added error handling for network failures"
# Better than: ssai vibe snapshot "fixed bugs"
```

### 2. Review Before Promoting
```bash
ssai vibe end        # Review impact
git diff main      # Check all changes
ssai vibe promote    # Then promote
```

### 3. Clean Up Failed Experiments
```bash
ssai vibe end                    # Close session
git checkout main              # Switch away
git branch -D vibe/experiment  # Delete branch
```

### 4. Combine with Agent
```bash
ssai vibe start "AI-assisted feature"
npm run agent:task "implement caching layer"
ssai vibe snapshot "AI implementation"
ssai vibe promote
```

### 5. Track Performance During Exploration
```bash
ssai vibe start "Performance optimization"
npm run perf:probe
ssai vibe snapshot "Baseline metrics"
# ... make changes ...
npm run perf:probe
ssai vibe snapshot "After optimization"
ssai vibe promote  # Contract will include performance data
```

## Integration with Other Tools

### With Pre-commit Hooks
```bash
npm run hooks:install  # Install hooks
# Vibe branches automatically use WARN mode
```

### With Contract Validation
```bash
ssai vibe promote              # Creates contract
npm run contracts:validate   # Validates it
```

### With CI/CD
Vibe branches can be pushed for CI testing:
```bash
git push origin vibe/my-feature
# CI runs but won't enforce contract scope
```

### With Agent Wrapper
```bash
ssai vibe promote  # Creates contract and active task
npm run agent:task "implement the remaining criteria"
# Agent respects the contract scope
```

## Best Practices

1. **Start with Vibe**: When requirements are unclear
2. **Snapshot Often**: Document your thought process
3. **End Sessions**: Don't leave sessions hanging
4. **Review Impact**: Understand scope before promoting
5. **Refine Contracts**: Edit after promotion if needed
6. **Test Early**: Implement tests before leaving vibe

## Example: Complete Feature Development

```bash
# Monday: Start exploration
ssai vibe start "Add real-time notifications"
vim src/notifications.js
npm test
ssai vibe snapshot "WebSocket server setup"

# Tuesday: Continue development
vim src/notifications/client.js
ssai vibe snapshot "Client connection logic"
vim tests/notifications.test.js
ssai vibe snapshot "Added integration tests"

# Wednesday: Review and formalize
ssai vibe end      # Review 3 days of work
ssai vibe promote  # Generate contract

# Thursday: Polish with structure
vim contracts/F-M5N9-B2C3.contract.md  # Refine criteria
npm test         # Run tests (BLOCK mode now active)

# Friday: Ship it
git commit -m "feat: Real-time notifications

Contract-Id: F-M5N9-B2C3
Contract-Hash: def45678"
git push origin main
```

## Troubleshooting

### "Active vibe session already exists"
```bash
ssai vibe end  # Close it first
ssai vibe start "new session"
```

### "No vibe session found"
```bash
# Check if you're on a vibe branch
git branch --show-current
# If not, start a new session
ssai vibe start "session name"
```

### "Changes exceed contract scope" (after promotion)
```bash
# You're in BLOCK mode now
# Either:
echo "WARN" > .softsensor/mode  # Temporary
# Or:
vim .softsensor/active-task.json  # Adjust scope
```

## Summary

Vibe Lane enables:
- **Exploration without barriers**
- **Automatic contract generation**
- **Smooth transition to structure**
- **Full development lifecycle support**

Start vibing today: `ssai vibe start "your next idea"`!