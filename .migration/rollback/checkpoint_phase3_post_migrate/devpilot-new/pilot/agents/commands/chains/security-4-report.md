# Chain: Security Audit - Step 4/4 - REPORT

You are executing step 4 of 4 for security audit.

<context>
- OS: Linux (WSL/devcontainer). Security tools: trivy, semgrep, gitleaks, hadolint.
- Conventions: minimal fixes, document all findings, prioritize by severity.
</context>

<input>
{PASTE_SCAN_RESULTS_AND_FIXES}
</input>

<goal>
Generate executive summary and detailed security report with recommendations.
</goal>

<plan>
- Executive summary (1 page)
- Detailed findings with evidence
- Fixes applied and verification
- Remaining risks and recommendations
- Compliance/audit trail
</plan>

<work>
1. Generate summary statistics:
   ```bash
   echo "## Security Audit Report - $(date -u +%Y-%m-%d)" > security-report.md
   echo "Issues found: $(jq '.results | length' /tmp/semgrep.json)" >> security-report.md
   ```

2. Create visualizations if possible:
   - Severity distribution
   - Issues by category
   - Fix timeline

3. Document for different audiences:
   - Executive: Risk level, business impact
   - Technical: Specific vulnerabilities and fixes
   - Compliance: Audit trail and evidence
</work>

<review>
- [ ] Report is factual and objective
- [ ] All fixes properly documented
- [ ] Remaining risks clearly stated
- [ ] Recommendations actionable
- [ ] Evidence preserved
</review>

<handoff>
<report>
# Security Audit Report

**Date**: {DATE}  
**Repository**: {REPO}  
**Auditor**: Automated + Manual Review

## Executive Summary

**Overall Risk**: **{HIGH/MEDIUM/LOW}**

- **Critical Issues**: {X} found, {Y} fixed
- **High Issues**: {X} found, {Y} fixed  
- **Medium Issues**: {X} found, {Y} deferred
- **Estimated Risk Reduction**: {Z}%

### Key Findings
1. {Most critical finding and its resolution}
2. {Second critical finding}
3. {Systemic issue if any}

## Detailed Findings

### Critical Issues ✅ FIXED
| Issue | Location | Impact | Fix Applied | Verified |
|-------|----------|---------|------------|----------|
| Exposed API Key | config.js:42 | Full system compromise | Moved to env var | ✅ |
| SQL Injection | user.js:127 | Data breach | Parameterized | ✅ |

### High Priority ⚠️ PARTIAL
| Issue | Location | Status | Next Steps |
|-------|----------|---------|------------|
| Outdated deps | package.json | In Progress | Test in staging |

### Medium Priority 📋 PLANNED
| Issue | Timeline | Owner |
|-------|----------|-------|
| Input validation | Q1 2025 | Backend team |

## Verification Results
```
Before: 47 vulnerabilities (8 critical, 12 high, 27 medium)
After:  23 vulnerabilities (0 critical, 3 high, 20 medium)
```

## Recommendations

### Immediate Actions
1. Rotate all exposed credentials
2. Deploy fixes to production
3. Enable secret scanning in CI

### Short Term (1 month)
1. Implement SAST in CI pipeline
2. Dependency update policy
3. Security training for developers

### Long Term (3 months)
1. Zero-trust architecture review
2. Penetration testing
3. Bug bounty program

## Compliance Notes
- Fixes address: SOC2 Type II requirements
- GDPR: No PII exposure found
- Audit logs: Preserved in `/tmp/audit-{DATE}/`

## Appendix
- [A] Scanner outputs: `/tmp/security-scan-{DATE}.tar.gz`
- [B] Fix commits: {COMMIT_HASHES}
- [C] Rollback procedures: See section 3.4

---
*Next audit scheduled: {DATE + 30 days}*
</report>
</handoff>