# Chain: Security Audit - Step 2/4 - PRIORITIZE

You are executing step 2 of 4 for security audit.

<context>
- OS: Linux (WSL/devcontainer). Security tools: trivy, semgrep, gitleaks, hadolint.
- Conventions: minimal fixes, document all findings, prioritize by severity.
</context>

<input>
{PASTE_SCAN_RESULTS_FROM_STEP_1}
</input>

<goal>
Analyze findings and create prioritized fix list based on risk and effort.
</goal>

<plan>
- Group similar issues
- Assess exploitability
- Estimate fix effort
- Calculate risk score (severity × exploitability ÷ effort)
- Create ranked action list
</plan>

<work>
1. Parse and deduplicate findings:
   ```bash
   jq -r '.results[] | select(.severity=="CRITICAL" or .severity=="HIGH")' /tmp/semgrep.json | head -20
   jq -r '.vulnerabilities[] | select(.severity=="CRITICAL" or .severity=="HIGH")' /tmp/npm-audit.json | head -20
   ```

2. Risk scoring matrix:
   - Exposed secrets: Critical, Easy fix → Priority 1
   - Auth bypass: Critical, Medium fix → Priority 1
   - SQL injection: High, Easy fix → Priority 2
   - Outdated deps with CVE: High, Easy fix → Priority 2
   - Verbose errors: Medium, Easy fix → Priority 3

3. Group by fix type:
   - Config changes (immediate)
   - Dependency updates (test required)
   - Code changes (review required)
   - Architecture changes (planning required)
</work>

<self_check>
- Are we fixing symptoms or root causes?
- Will fixes break existing functionality?
- Are there quick wins we're missing?
</self_check>

<review>
- [ ] All critical issues addressed
- [ ] Fix order minimizes risk exposure time
- [ ] Effort estimates realistic
- [ ] Dependencies between fixes identified
</review>

<handoff>
<priorities>
## Fix Priority Queue

### Priority 1 - Immediate (< 1 hour)
1. **Exposed Secret in {FILE}**
   - Risk: Critical
   - Fix: Rotate secret, update .gitignore
   - Command: `git rm --cached {FILE}; echo {FILE} >> .gitignore`

2. **SQL Injection in {FILE}**
   - Risk: High
   - Fix: Use parameterized queries
   - Effort: 15 minutes

### Priority 2 - Today (< 4 hours)
1. **Dependency CVE: {PACKAGE}**
   - Current: v1.2.3, Fixed: v1.2.4
   - Risk: High (RCE possible)
   - Command: `pnpm update {PACKAGE}`

### Priority 3 - This Week
1. **Missing Input Validation**
   - Files: {LIST}
   - Risk: Medium
   - Fix: Add validation middleware

## Do Not Fix (False Positives)
- {FINDING}: Test file only
- {FINDING}: Already mitigated by {CONTROL}

## Tracking
Total: X issues
Will fix: Y issues (Z critical, A high)
Won't fix: B issues (reasons documented)
</priorities>
</handoff>