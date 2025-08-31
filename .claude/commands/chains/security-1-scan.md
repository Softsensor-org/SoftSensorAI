# Chain: Security Audit - Step 1/4 - SCAN

You are executing step 1 of 4 for security audit.

<context>
- OS: Linux (WSL/devcontainer). Security tools: trivy, semgrep, gitleaks, hadolint.
- Conventions: minimal fixes, document all findings, prioritize by severity.
</context>

<input>
Repository path: {CURRENT_DIRECTORY}
Focus areas: {SPECIFY_OR_ALL}
</input>

<goal>
Run all available security scanners and collect findings.
</goal>

<plan>
- Dependency vulnerabilities (npm/pnpm audit)
- Static analysis (semgrep)
- Secret detection (gitleaks)
- Container scanning (trivy, hadolint)
- Permission audit
- Collect and categorize all findings
</plan>

<work>
1. Dependency scan:
   ```bash
   pnpm audit --json > /tmp/pnpm-audit.json 2>/dev/null || npm audit --json > /tmp/npm-audit.json 2>/dev/null
   ```

2. SAST scan:
   ```bash
   semgrep --config=auto --json -o /tmp/semgrep.json . 2>/dev/null || echo '{"results":[]}' > /tmp/semgrep.json
   ```

3. Secret scan:
   ```bash
   gitleaks detect --no-banner -v --report-format json --report-path /tmp/gitleaks.json || true
   ```

4. Container scan:
   ```bash
   find . -name "Dockerfile*" -exec hadolint {} \; > /tmp/hadolint.txt 2>&1 || true
   trivy fs --security-checks vuln,config --format json -o /tmp/trivy.json . 2>/dev/null || true
   ```

5. Permission audit:
   ```bash
   find . -type f -name "*.sh" -perm /111 -ls > /tmp/permissions.txt
   find . -name ".env*" -o -name "*secret*" -o -name "*token*" -o -name "*.key" > /tmp/sensitive.txt
   ```
</work>

<review>
- [ ] All scanners attempted
- [ ] Results saved to temp files
- [ ] No scanners crashed
- [ ] Findings categorized by severity
</review>

<handoff>
<scan_results>
## Scanner Summary
| Scanner | Issues Found | Critical | High | Medium | Low |
|---------|-------------|----------|------|--------|-----|
| Dependencies | X | Y | Z | A | B |
| Semgrep | X | Y | Z | A | B |
| Gitleaks | X | Y | Z | A | B |
| Trivy | X | Y | Z | A | B |

## Critical Findings
1. **[CRITICAL]** {FINDING_1}
   - Tool: {SCANNER}
   - File: {PATH}
   - Impact: {DESCRIPTION}

## High Priority
1. **[HIGH]** {FINDING}
   - Tool: {SCANNER}
   - File: {PATH}

## Raw Results Location
- Dependencies: /tmp/pnpm-audit.json
- SAST: /tmp/semgrep.json
- Secrets: /tmp/gitleaks.json
- Container: /tmp/trivy.json
</scan_results>
</handoff>