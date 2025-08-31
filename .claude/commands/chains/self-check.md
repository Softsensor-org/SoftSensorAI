# Self-Correction Mini-Chain

Drop this into any chain step when output quality matters.

<self_check>
- List 3 likely failure modes in this output.
- Re-read acceptance checks; point out any unmet items.
- Repair the output if needed; show the minimal changes.
</self_check>

## When to Use

Insert after the `<work>` section in any chain step where:
- The output is critical for next steps
- There's risk of subtle errors
- You're dealing with complex logic
- The acceptance criteria are strict

## Example Integration

```markdown
<work>
[Your main work here]
</work>

<self_check>
Reviewing my output:

**Likely failure modes:**
1. Missing edge case handling for empty inputs
2. Assumption that service is always available
3. No rollback mechanism if migration fails

**Acceptance check review:**
✅ All interfaces have types
✅ Idempotent operations confirmed
❌ Missing error recovery documentation

**Repair:**
Adding error recovery section to migration notes:
- If migration fails at step 2: run rollback.sql
- If service unavailable: circuit breaker activates
- Empty input returns 400 with descriptive message
</self_check>

<review>
[Continue with normal review]
</review>
```

## Self-Check Questions Library

### For Code Changes
1. Will this handle null/undefined/empty inputs?
2. Are all error paths tested?
3. Is the diff truly minimal?
4. Will this work in both dev and prod environments?
5. Are there any hardcoded values that should be configurable?

### For Specifications
1. Are success criteria measurable?
2. Is every requirement testable?
3. Are edge cases documented?
4. Is the scope clearly bounded?
5. Are dependencies identified?

### For Tests
1. Do tests actually fail without the implementation?
2. Are assertions specific enough?
3. Is test data realistic?
4. Are both happy and sad paths covered?
5. Will tests be maintainable?

### For Security/Performance
1. Have I introduced new attack vectors?
2. Will this scale with 10x load?
3. Are secrets properly handled?
4. Is input validation comprehensive?
5. Are there any denial-of-service risks?

## Quick Self-Check Template

```markdown
<self_check>
**Quick scan:**
- [ ] Output matches goal statement
- [ ] All commands actually executed
- [ ] Artifacts exist at stated paths
- [ ] Next step has all needed inputs
- [ ] No debug code or TODOs remain

**Issues found:** [none | list them]
**Corrections applied:** [none | describe]
</self_check>
```