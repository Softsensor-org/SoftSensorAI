# Chain Debugging Guide

When a chain step underperforms, use this systematic approach to diagnose and fix issues.

## Quick Debugging Checklist

### 1. Goal Clarity
**Problem**: Step trying to do too much  
**Symptom**: Partial completion, unfocused output  
**Fix**: Split into multiple steps, each with ONE clear goal

### 2. Acceptance Criteria
**Problem**: Vague success criteria  
**Symptom**: Can't tell if step succeeded  
**Fix**: Add objective, measurable checks

### 3. Command Specification
**Problem**: Missing or vague commands  
**Symptom**: "I would run tests" instead of "pnpm test -i user.spec.ts"  
**Fix**: List exact commands with full arguments

### 4. Handoff Completeness
**Problem**: Next step missing required data  
**Symptom**: Step 2 asks for info from Step 1  
**Fix**: Verify handoff tags contain all needed data

### 5. Self-Check Integration
**Problem**: Errors propagating through chain  
**Symptom**: Late-stage failures from early mistakes  
**Fix**: Add `<self_check>` blocks to critical steps

## Debugging Patterns

### Pattern 1: Step Produces Wrong Output Type
```markdown
# WRONG - Vague handoff
<handoff>
The tests are ready
</handoff>

# RIGHT - Structured handoff
<handoff>
<test_results>
Files created: tests/user.spec.ts, tests/auth.spec.ts
Tests run: 12
Failures: 12 (expected - no implementation yet)
Coverage: 0% (expected - tests only)
</test_results>
</handoff>
```

### Pattern 2: Commands Not Actually Executed
```markdown
# WRONG - Hypothetical
I would run: pnpm test

# RIGHT - Actual execution
<work>
Running tests:
```bash
$ pnpm test -i user
FAIL: test_user_creation - Not implemented
FAIL: test_user_validation - Not implemented
```
All 5 tests failing as expected (no implementation yet)
</work>
```

### Pattern 3: Missing Context Between Steps
```markdown
# WRONG - Assumes knowledge
Goal: Fix the validation issue

# RIGHT - Self-contained
<input>
<previous_step>
Validation fails for emails without @ symbol
Test: tests/validation.spec.ts:42
</previous_step>
</input>
Goal: Fix email validation to require @ symbol
```

### Pattern 4: Parallel Steps Creating Conflicts
```markdown
# WRONG - Both steps modify same file
<parallel>
  <task id="1">Update user.js</task>
  <task id="2">Refactor user.js</task>
</parallel>

# RIGHT - Independent operations
<parallel>
  <task id="1">Analyze user.js</task>
  <task id="2">Analyze auth.js</task>
</parallel>
<merge>Combine analyses then apply changes</merge>
```

## Advanced Debugging Techniques

### 1. Add Instrumentation
```markdown
<work>
echo "CHAIN_DEBUG: Starting feature extraction" >&2
echo "CHAIN_DEBUG: Input size: $(wc -l < input.txt)" >&2
[actual work]
echo "CHAIN_DEBUG: Output size: $(wc -l < output.txt)" >&2
</work>
```

### 2. Checkpoint Validation
```markdown
<checkpoint>
Before proceeding, verify:
- [ ] File exists: test/user.spec.ts
- [ ] Contains at least 5 test cases  
- [ ] All tests currently fail
- [ ] No syntax errors: pnpm test --listTests
</checkpoint>
```

### 3. Error Recovery
```markdown
<error_handling>
if [[ ! -f "$expected_output" ]]; then
  echo "ERROR: Expected output not created"
  echo "Attempting recovery..."
  # Fallback approach
fi
</error_handling>
```

### 4. Type Guards for Handoffs
```markdown
<handoff_validation>
Required fields for next step:
- spec.interfaces: array of function signatures
- spec.acceptance_checks: array of test descriptions
- spec.migration_required: boolean

Validating...
[✓] interfaces present: 5 signatures
[✓] acceptance_checks present: 8 checks
[✓] migration_required: false
</handoff_validation>
```

## Common Failure Modes

### 1. Cascading Failures
**Symptom**: Step 3 fails because Step 1 had wrong output format  
**Fix**: Add validation at handoff points
```markdown
<review>
- [ ] Output matches expected schema
- [ ] All required fields present
- [ ] No placeholder values remain
</review>
```

### 2. Silent Failures
**Symptom**: Step reports success but didn't actually complete work  
**Fix**: Add explicit verification
```markdown
<verify>
# Don't just say "tests created", prove it:
$ ls -la tests/*.spec.ts
-rw-r--r-- 1 user user 2453 Jan 10 10:30 tests/user.spec.ts
-rw-r--r-- 1 user user 1832 Jan 10 10:31 tests/auth.spec.ts
</verify>
```

### 3. Environment Assumptions
**Symptom**: Works locally, fails in CI  
**Fix**: Explicit environment checks
```markdown
<environment_check>
Required tools:
- pnpm: $(pnpm --version) ✓
- python: $(python --version) ✓
- docker: $(docker --version) ✓
</environment_check>
```

### 4. Partial Completion
**Symptom**: Step does 80% of work then stops  
**Fix**: Break into smaller steps or add progress tracking
```markdown
<progress>
[✓] Step 1/5: Load data
[✓] Step 2/5: Validate schema
[✓] Step 3/5: Apply transformations
[ ] Step 4/5: Save output
[ ] Step 5/5: Generate report
Stopped at step 3 - investigating...
</progress>
```

## Debug Mode Execution

Enable debug mode for verbose output:
```bash
# Set debug flag
export CHAIN_DEBUG=1

# Run with extra logging
scripts/chain_runner.sh backend feature-auth 2>&1 | tee chain-debug.log

# Analyze debug output
grep "ERROR\|FAIL\|WARNING" chain-debug.log
```

## Recovery Strategies

### Resume from Failure
```bash
# Find last successful step
ls -la chains/task-name/step*.md

# Resume from step 3
scripts/chain_runner.sh backend task-name 3
```

### Manual Step Repair
```bash
# Edit the failed step output
vim chains/task-name/step3_code.md

# Add missing handoff section
<handoff>
<patch>
[Add the missing diff here]
</patch>
</handoff>

# Continue with step 4
scripts/chain_runner.sh backend task-name 4
```

### Parallel Failure Recovery
```bash
# If one parallel task failed
scripts/chain_runner.sh analyze task-doc3  # Retry just the failed one

# Then run merge step
scripts/chain_runner.sh merge task-combined
```

## Prevention Best Practices

1. **Test chains on small examples first**
2. **Add self-checks to critical steps**
3. **Version control chain outputs**
4. **Keep audit logs of chain executions**
5. **Regular chain template updates**
6. **Document chain-specific requirements**

## Getting Help

If debugging doesn't resolve the issue:
1. Check if chain template needs updating
2. Verify all dependencies installed
3. Compare against successful chain execution
4. Consider splitting complex chains
5. Add more granular error handling