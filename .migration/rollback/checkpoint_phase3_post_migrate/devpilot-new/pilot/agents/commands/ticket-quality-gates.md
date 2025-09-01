# Ticket Quality Gates Checklist

Ensure every generated ticket meets these standards before delivery.

## Mandatory Requirements

### 1. Evidence Quality
- [ ] **File:line citation** - Every ticket has at least one `file:line` reference
- [ ] **Code snippet** - 3-8 lines of actual code/config showing the issue
- [ ] **Syntax highlighting** - Code blocks use appropriate language tags
- [ ] **Context preserved** - Snippet includes enough context to understand the issue

### 2. Acceptance Criteria Standards
- [ ] **Testable outcomes** - Each AC item can be verified objectively
- [ ] **Thresholds defined** - Performance/security gates have numeric thresholds
- [ ] **Config flags** - Feature flags or config changes are specified
- [ ] **Observability** - Logs/metrics/alerts defined where applicable

### 3. Test Plan Completeness
- [ ] **Unit tests** - Exact command with file paths
- [ ] **Integration tests** - E2E scenarios with commands
- [ ] **Negative tests** - Error cases and edge conditions covered
- [ ] **Performance tests** - Load/stress tests for P0/P1 perf issues
- [ ] **Security scans** - Security test commands for P0/P1 security issues

### 4. Priority & Severity Alignment
- [ ] **P0 justified** - Critical/exploitable issues only
- [ ] **Effort realistic** - S/M/L estimates match complexity
- [ ] **Priority formula** - Priority = severity × impact ÷ effort
- [ ] **Quick wins first** - Low-effort, high-impact tickets prioritized

### 5. Special Case Handling

#### Security Issues
- [ ] **Secret rotation** - P0 secrets include rotation steps
- [ ] **Scanner integration** - CI scanner configuration in AC
- [ ] **Audit trail** - Logging requirements specified

#### Performance Issues  
- [ ] **Baseline metrics** - Current performance documented
- [ ] **Target metrics** - Specific p50/p95/p99 targets
- [ ] **Load profile** - Expected traffic/load specified

#### Async/Concurrency Issues
- [ ] **Blocking I/O flagged** - Async endpoints checked for blocking calls
- [ ] **Concurrency verified** - Race conditions have specific test cases
- [ ] **Deadlock prevention** - Timeout and circuit breaker requirements

#### ML/LLM Issues
- [ ] **Schema validation** - Input/output schemas defined
- [ ] **Determinism tests** - Tests prove deterministic > LLM
- [ ] **Output validation** - LLM outputs validated before use
- [ ] **Fallback strategy** - Graceful degradation defined

## Duplicate Management
- [ ] **Similar issues merged** - One ticket with checklist for multiple instances
- [ ] **Root cause identified** - Systemic issues have parent epic
- [ ] **Guardrails added** - Fix + prevent pattern applied

## Output Format Validation

### GitHub Markdown
- [ ] All required fields present
- [ ] Markdown formatting valid
- [ ] Links use repo-relative paths
- [ ] Labels follow convention

### Jira CSV
- [ ] Header row exact match
- [ ] Fields with commas quoted
- [ ] Multiline fields quoted
- [ ] CSV validates in parser

## Final Review
- [ ] **25 tickets target** - 20-40 acceptable range
- [ ] **Epic distribution** - All epics have representation
- [ ] **Severity distribution** - Appropriate P0/P1/P2/P3 mix
- [ ] **Quick wins identified** - 10-15 S-sized tickets
- [ ] **PR plan provided** - Top 5 branches with commit messages
- [ ] **Guardrails defined** - Linter/CI rules to prevent regression

## Common Failures to Avoid
- ❌ Missing file:line references
- ❌ Vague acceptance criteria ("works correctly")
- ❌ No test commands ("write tests")
- ❌ P0 without immediate action plan
- ❌ Large tickets without decomposition
- ❌ Security issues without rotation/scanning
- ❌ Performance issues without metrics
- ❌ CSV with unquoted commas

## Usage
Run this checklist after generating tickets:
```bash
# Generate tickets
/tickets-from-code MODE=GITHUB_MARKDOWN

# Review with quality gates
/ticket-quality-gates

# If issues found, regenerate with fixes
/tickets-from-code MODE=BOTH
```