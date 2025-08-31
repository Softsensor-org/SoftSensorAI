# Chain: Security Audit - Step 3/4 - FIX

You are executing step 3 of 4 for security audit.

<context>
- OS: Linux (WSL/devcontainer). Security tools: trivy, semgrep, gitleaks, hadolint.
- Conventions: minimal fixes, document all findings, prioritize by severity.
</context>

<input>
{PASTE_PRIORITIES_FROM_STEP_2}
</input>

<goal>
Apply fixes for Priority 1 and Priority 2 issues with minimal, safe changes.
</goal>

<plan>
- Fix one issue at a time
- Test after each fix
- Document what changed and why
- Create rollback instructions
- Re-scan to verify fix
</plan>

<work>
For each priority issue:

1. Create backup:
   ```bash
   cp {FILE} {FILE}.security-backup
   ```

2. Apply minimal fix

3. Test the fix:
   ```bash
   # Run relevant tests
   pnpm test {affected_tests}
   
   # Re-run specific scanner
   semgrep --config=auto {FILE}
   ```

4. Document the change

Example fixes:
- Secrets: Remove file, rotate secret, use env var
- SQL injection: Replace string concatenation with parameterized query
- Path traversal: Add input validation and sanitization
- Dependency: Update to patched version after testing
</work>

<self_check>
- Does fix introduce new vulnerabilities?
- Is this the minimal change needed?
- Will fix survive code review?
</self_check>

<review>
- [ ] Each fix applied successfully
- [ ] Tests still pass
- [ ] No new issues introduced
- [ ] Rollback plan documented
- [ ] Changes are minimal
</review>

<handoff>
<fixes>
## Applied Fixes

### Critical Issues Fixed (X)
1. **Exposed Secret**
   - File: {PATH}
   - Change: Removed from git, added to .gitignore
   - Verification: `gitleaks detect` now clean
   ```diff
   - const apiKey = "sk-actual-key-here"
   + const apiKey = process.env.API_KEY
   ```

2. **SQL Injection**
   - File: {PATH}
   - Change: Parameterized query
   ```diff
   - db.query(`SELECT * FROM users WHERE id = ${userId}`)
   + db.query('SELECT * FROM users WHERE id = ?', [userId])
   ```

### High Issues Fixed (Y)
1. **CVE-2024-XXXX in {package}**
   - Updated: 1.2.3 → 1.2.4
   - Tests: ✅ Passing
   - Breaking changes: None

### Deferred Issues
- {ISSUE}: Requires architecture change
- {ISSUE}: Blocked by {DEPENDENCY}

## Rollback Instructions
```bash
# If issues arise:
git stash
cp *.security-backup .
pnpm install  # restore original deps
```

## Verification
- Re-ran scanners: X issues resolved
- Tests passing: Y/Y
- No regressions detected
</fixes>
</handoff>