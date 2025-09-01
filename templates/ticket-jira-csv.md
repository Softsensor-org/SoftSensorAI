# Jira CSV Import Template

## Header (exact order required)
```csv
Title,Epic,Area,Severity,Priority,Effort,Evidence,Why,Suggested fix,Acceptance Criteria,Test plan,Dependencies,Labels,Milestone,Owner,Links
```

## Field Guidelines

### Title
- Imperative verb, ≤70 chars
- Examples: "Fix SQL injection in user search", "Add rate limiting to API endpoints"

### Epic
One of: Security, Reliability, Performance, Code Quality, DevEx, Docs, ML/Privacy

### Area
Paths or service names, comma-separated if multiple

### Severity
- P0: Critical/exploitable/prod risk
- P1: High impact
- P2: Moderate
- P3: Nice-to-have

### Priority
High/Medium/Low with brief reason in parentheses

### Effort
- S: ≤4 hours
- M: ≤2 days
- L: >2 days

### Evidence
file:line with snippet (use quotes if contains commas)

### Why
1-3 sentences on risk/cost/benefit (quote if contains commas)

### Suggested fix
Specific steps or patch (quote if multiline)

### Acceptance Criteria
Bullet list with testable outcomes (quote entire field)

### Test plan
Commands and cases (quote entire field)

### Dependencies
Ticket IDs or files that must change first

### Labels
Comma-separated: area/security, type/refactor, etc.

### Milestone
Sprint or release name

### Owner
Team name or TBD

### Links
Repo-relative paths, comma-separated

## Example Row
```csv
"Fix SQL injection in user search",Security,api/search,P0,"High (exploitable)",S,"api/search.js:42","Direct string concatenation allows SQL injection","Use parameterized queries","• No raw SQL in codebase
• Security scan passes
• Input validation added","Unit: npm test api/search.spec.js
Integration: npm run test:e2e
Security: npm audit","","area/security,type/bug,critical","Security Sprint 1",backend-platform,"api/search.js,tests/security.spec.js"
```

## Import Notes
- Quote fields containing commas, newlines, or quotes
- Use double quotes, escape internal quotes by doubling them
- Keep CSV under 10MB for Jira import
- Test with 5 tickets first before bulk import
