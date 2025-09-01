# Chain: Backend Feature - Step 4/5 - VERIFY

You are executing step 4 of 5 for implementing a backend feature.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_PATCH_FROM_STEP_3}
</input>

<goal>
Run comprehensive verification checks and document all results.
</goal>

<plan>
- Run full test suite
- Check linting and formatting
- Verify type safety
- Test edge cases manually
- Check for security issues
- Measure performance impact
</plan>

<work>
1. Run comprehensive checks:
   ```bash
   # Full test suite
   pnpm test
   
   # Type checking
   pnpm typecheck
   
   # Linting
   pnpm lint
   
   # Security audit
   pnpm audit || npm audit
   
   # If available
   make audit
   make security-json
   ```

2. Manual verification:
   - Test with invalid inputs
   - Test with extreme values
   - Test concurrent requests
   - Check error messages

3. Performance check:
   ```bash
   # If applicable, benchmark key operations
   hyperfine "command before" "command after" || time command
   ```
</work>

<review>
- [ ] All automated checks pass
- [ ] No security vulnerabilities introduced
- [ ] Performance acceptable (no major regression)
- [ ] Error handling verified
- [ ] Documentation updated if needed
</review>

<handoff>
<verification>
## Automated Checks
✅ Tests: X/X passing (Yms)
✅ Type Check: No errors
✅ Lint: Clean
✅ Security: No new vulnerabilities

## Manual Testing
| Scenario | Result | Notes |
|----------|---------|-------|
| Invalid input | ✅ Handled | Returns 400 with message |
| Concurrent requests | ✅ Safe | No race conditions |
| Large payload | ✅ Handled | Respects limits |

## Performance
- Baseline: Xms
- After changes: Yms
- Impact: Negligible

## Coverage
- Lines: X%
- Branches: Y%
- Functions: Z%

## Risks
- {RISK_IF_ANY}
- Mitigation: {HOW_ADDRESSED}
</verification>
</handoff>
