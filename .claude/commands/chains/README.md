# Chain Commands - Structured Multi-Step Workflows

## Overview
Chain commands implement structured, multi-step workflows with clear handoffs between steps. Each step has exactly one goal, explicit acceptance criteria, and produces typed outputs for the next step.

## Available Chains

### 🔧 Backend Feature (5 steps)
Implement a complete backend feature from spec to PR.

**Steps:**
1. **SPEC** - Define interfaces and acceptance criteria
2. **TESTS** - Write failing tests encoding requirements  
3. **CODE** - Minimal implementation to pass tests
4. **VERIFY** - Run comprehensive checks
5. **PR** - Create pull request with documentation

**Usage:**
```bash
# Start the chain
scripts/chain_runner.sh backend feature-name

# Or use commands directly:
/chains/backend-1-spec
/chains/backend-2-tests
# ... etc
```

### 🔒 Security Audit (4 steps)
Comprehensive security review with prioritized fixes.

**Steps:**
1. **SCAN** - Run all security scanners
2. **PRIORITIZE** - Rank issues by risk/effort
3. **FIX** - Apply minimal fixes for top issues
4. **REPORT** - Generate audit report

**Usage:**
```bash
scripts/chain_runner.sh security audit-2024
```

### ♻️ Refactor (3 steps)
Improve code quality while preserving functionality.

**Steps:**
1. **ANALYZE** - Measure complexity and find issues
2. **REFACTOR** - Apply improvements atomically
3. **VALIDATE** - Verify no regressions

**Usage:**
```bash
scripts/chain_runner.sh refactor cleanup-utils
```

## Core Principles

### 1. One Goal Per Step
Each step must have exactly one deliverable. This prevents scope creep and ensures clear success criteria.

### 2. Typed Handoffs
Pass outputs between steps using XML tags:
```xml
<handoff>
<spec>
  <!-- Structured data for next step -->
</spec>
</handoff>
```

### 3. Step Contract
Every step must end with:
- ✅ Acceptance checks (objective criteria)
- 🔧 Exact commands to run
- 📦 Artifacts produced (files/outputs)

### 4. Self-Check
Include review blocks to catch issues early:
```xml
<self_check>
- List 3 likely failure modes
- Re-read acceptance checks
- Repair if needed
</self_check>
```

### 5. Parallelization
Run independent steps concurrently:
```bash
# Analyze multiple files in parallel
/chains/analyze doc1.md &
/chains/analyze doc2.md &
wait
/chains/merge-results
```

## Chain Skeleton Template

Use this template to create new chains:

```markdown
# Chain: [TYPE] - Step N/M - [NAME]

You are executing step <N> of <M> for <TASK>.

<context>
- OS: Linux (WSL/devcontainer)
- Tools: [list allowed tools]
- Conventions: [project rules]
</context>

<input>
{PASTE_FROM_PREVIOUS_STEP}
</input>

<goal>
Single, clear outcome this step produces.
</goal>

<plan>
- List acceptance checks
- List exact commands
- List artifacts to create
</plan>

<work>
Do the work here.
</work>

<review>
- [ ] Acceptance check 1
- [ ] Acceptance check 2
- [ ] No regressions
</review>

<handoff>
<output_tag>
Structured data for next step
</output_tag>
</handoff>
```

## Creating Custom Chains

1. **Define Steps**: Break your workflow into atomic steps
2. **Create Commands**: Add to `.claude/commands/chains/`
3. **Name Convention**: `{type}-{step}-{name}.md`
4. **Update Runner**: Add to `CHAIN_STEPS` in `chain_runner.sh`

Example for a deployment chain:
```bash
CHAIN_STEPS[deploy]="validate build test stage promote"
```

## Tips for Success

### When Steps Underperform
- **Multiple goals?** → Split the step
- **Missing acceptance checks?** → Add them
- **Wrong handoff data?** → Verify tags
- **Still failing?** → Add self-check block

### Debugging Chains
1. Check step isolation (can it run alone?)
2. Verify handoff completeness
3. Ensure acceptance checks are objective
4. Add verbose logging if needed

### Best Practices
- Keep steps under 30 minutes each
- Commit after each successful step
- Use version control for chain outputs
- Archive successful chains as templates

## Integration with Other Tools

### With Codex CLI
```bash
# Use Codex for automated fixes within a chain
codex exec "make tests pass" --approval-mode auto-edit
```

### With Claude
```bash
# Use Claude commands in sequence
claude /chains/backend-1-spec
claude /chains/backend-2-tests
```

### With Make
```makefile
chain-backend:
	@scripts/chain_runner.sh backend $(FEATURE)

chain-security:
	@scripts/chain_runner.sh security audit-$(shell date +%Y%m)
```

## Examples

### Quick Backend Feature
```bash
# Implement a new API endpoint
AUTO_PROCEED=yes scripts/chain_runner.sh backend user-settings

# Review outputs
ls chains/user-settings/
cat chains/user-settings/step5_pr.md
```

### Security Audit
```bash
# Run security audit
scripts/chain_runner.sh security q4-audit

# Get report
cat chains/q4-audit/step4_report.md
```

### Code Refactoring
```bash
# Refactor complex module
scripts/chain_runner.sh refactor simplify-auth

# Check improvements
cat chains/simplify-auth/step3_validate.md
```

## Troubleshooting

**Q: How do I resume from a failed step?**
```bash
scripts/chain_runner.sh backend feature-name 3  # Start from step 3
```

**Q: Can I edit outputs between steps?**
Yes, outputs are just markdown files in `chains/<task>/`. Edit before proceeding.

**Q: How do I customize for my project?**
1. Fork the templates in `.claude/commands/chains/`
2. Update paths, commands, and conventions
3. Add project-specific acceptance criteria

## Contributing

To add new chain types:
1. Create command templates in `.claude/commands/chains/`
2. Update `chain_runner.sh` with new type
3. Document in this README
4. Submit PR with example usage