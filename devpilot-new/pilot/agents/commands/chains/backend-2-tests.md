# Chain: Backend Feature - Step 2/5 - TESTS

You are executing step 2 of 5 for implementing a backend feature.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_SPEC_FROM_STEP_1}
</input>

<goal>
Create comprehensive failing tests that encode all acceptance checks from the spec.
</goal>

<plan>
- Identify test file locations following project conventions
- Write test cases for each acceptance check
- Include edge cases and error conditions
- Run tests to confirm they fail as expected
- Document why each test currently fails
</plan>

<work>
1. Find test patterns:
   ```bash
   find . -name "*.test.*" -o -name "*_test.*" -o -name "test_*" | head -5
   ```

2. Create test file(s) following conventions

3. Write tests covering:
   - Happy path for each interface
   - Each acceptance check
   - Error cases
   - Edge conditions
   - Integration points
</work>

<review>
- [ ] Every acceptance check has a corresponding test
- [ ] Tests are independent and isolated
- [ ] Test names clearly describe what they verify
- [ ] All tests fail with meaningful error messages
- [ ] No implementation code written yet
</review>

<handoff>
<test_results>
## Test Files Created
- `{PATH_TO_TEST_FILE_1}`
- `{PATH_TO_TEST_FILE_2}`

## Test Execution Output
```bash
$ pnpm test {SCOPE}
# or: pytest {PATH}

FAILED: test_should_validate_input - Not Implemented
FAILED: test_should_handle_empty_case - Not Implemented
FAILED: test_should_return_expected_format - Not Implemented
...
```

## Coverage Mapping
| Acceptance Check | Test Name | Status |
|-----------------|-----------|---------|
| AC1 | test_X | ❌ Failing |
| AC2 | test_Y | ❌ Failing |
</test_results>
</handoff>