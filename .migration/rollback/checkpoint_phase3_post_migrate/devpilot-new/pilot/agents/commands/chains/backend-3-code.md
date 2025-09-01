# Chain: Backend Feature - Step 3/5 - CODE

You are executing step 3 of 5 for implementing a backend feature.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_SPEC_AND_TEST_RESULTS}
</input>

<goal>
Produce the minimal code changes required to make all tests pass.
</goal>

<plan>
- Implement only what's needed to pass tests
- Follow existing code patterns and conventions
- Keep changes atomic and focused
- Verify type safety
- Run tests after each component implementation
</plan>

<work>
1. Implement in order of dependency:
   - Data models/types
   - Core business logic
   - API endpoints/handlers
   - Integration points

2. After each component:
   ```bash
   pnpm typecheck
   pnpm test {SCOPE}
   ```

3. Keep diff minimal - no refactoring unrelated code
</work>

<self_check>
- List 3 likely bugs in this implementation
- Check if any test is passing for wrong reasons
- Verify no hardcoded values that should be configurable
</self_check>

<review>
- [ ] All tests now pass
- [ ] No unrelated changes in diff
- [ ] Code follows project conventions
- [ ] Type checking passes
- [ ] No console.logs or debug code
</review>

<handoff>
<patch>
## Files Modified
- `{FILE_1}`: {DESCRIPTION}
- `{FILE_2}`: {DESCRIPTION}

## Diff Summary
```diff
{UNIFIED_DIFF_OUTPUT}
```

## Test Status
```bash
$ pnpm test {SCOPE}
✓ test_should_validate_input (12ms)
✓ test_should_handle_empty_case (8ms)
✓ test_should_return_expected_format (15ms)

All tests passing (X total, Yms)
```

## Implementation Notes
- {KEY_DECISION_1}
- {KEY_DECISION_2}
</patch>
</handoff>