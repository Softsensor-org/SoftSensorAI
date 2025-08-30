# Security Review

Perform a comprehensive security review of the codebase with focus on finding and fixing the highest-impact issues.

## Phase 1: Discovery
Run available security scanners to identify issues:
```bash
# Dependencies
npm audit || pnpm audit || yarn audit 2>/dev/null

# SAST
semgrep --config=auto . 2>/dev/null || echo "Semgrep not available"

# Secrets
gitleaks detect --no-banner -v 2>/dev/null || echo "Gitleaks not available"

# Container/IaC
trivy fs . 2>/dev/null || echo "Trivy not available"
hadolint Dockerfile* 2>/dev/null || echo "No Dockerfiles or hadolint not available"

# Permissions
find . -type f -name "*.sh" -exec ls -la {} \; | grep -E "rwxrwxrwx|777"
```

## Phase 2: Prioritization
Rank issues by:
1. **Critical**: Exposed secrets, auth bypass, RCE vulnerabilities
2. **High**: Outdated dependencies with known CVEs, SQL injection risks
3. **Medium**: Missing input validation, weak crypto, verbose error messages
4. **Low**: Code style, missing best practices

## Phase 3: Remediation
For the top 3 issues:
1. Create minimal fix with explanation
2. Show unified diff
3. Verify fix doesn't break existing functionality
4. Re-run relevant scanner to confirm resolution

## Output Format
```markdown
### Security Review Summary
- **Issues Found**: X critical, Y high, Z medium
- **Issues Fixed**: [list]
- **Remaining Work**: [prioritized list]

### Fixes Applied
[For each fix]
#### Issue: [Name]
- **Severity**: Critical/High/Medium
- **Tool**: [scanner that found it]
- **Fix**: [one-line description]

<details>
<summary>Diff</summary>

```diff
[actual diff]
```
</details>

### Verification
[Scanner outputs showing issue resolved]

### Next Steps
1. [Most important remaining issue]
2. [Second priority]
3. [Third priority]
```