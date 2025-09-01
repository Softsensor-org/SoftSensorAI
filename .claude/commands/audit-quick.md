# Quick Scan (20 minutes, surgical)

## System Context
You are a principal engineer doing a 20-minute QUICK AUDIT. Same safety & formatting rules.

Formatting preferences:
- Use the headings I specify; return valid Markdown tables.
- When returning JSON, return valid JSON only (no prose).
- Use XML tags to structure output sections.

Tool use & safety:
- Read-only execution only unless explicitly approved.
- Prefer local/MCP tools first (ripgrep, jq, GitHub MCP).
- Invoke independent operations in parallel.

## User Input
Do a FAST pass:
- Top 10 risks (P0–P2) with file:line evidence
- 10 quick wins
- Build/test commands
- ONE sample patch for the highest-value fix

Repository context:
- Runtimes: {{RUNTIMES}}
- Target environment: {{TARGET_ENV}}
- Key concerns: {{KEY_CONCERNS}}

## Output Structure

<thinking>Quick strategy: where to look first and why (3-5 bullets)</thinking>

## Top Risks (P0–P2)
<findings>
| ID | Sev | Area | File:Line | Evidence | Why it matters | Suggested fix |
|----|-----|------|-----------|----------|----------------|---------------|
| 1 | P0 | Security | file.js:42 | `const sql = "SELECT * FROM users WHERE id = " + userId` | SQL injection risk | Use parameterized queries |
| 2 | P1 | Performance | api.js:15 | Sync DB calls in loop | Blocks event loop | Batch queries or use async |
| ... | ... | ... | ... | ... | ... | ... |
</findings>

## Quick Wins (≤1 day)
<quick_wins>
1. Add .env.example with required variables
2. Update .gitignore to exclude sensitive files
3. Add input validation to API endpoints
4. Enable ESLint/Prettier in CI
5. Add health check endpoint
6. Implement request timeout middleware
7. Add rate limiting to public APIs
8. Create error handler middleware
9. Add unit tests for core utilities
10. Document local development setup
</quick_wins>

## Build/Test Commands
<build_commands>
```bash
# Install dependencies
npm install

# Run tests
npm test

# Lint code
npm run lint

# Type check (if TypeScript)
npm run typecheck

# Build for production
npm run build

# Start development server
npm run dev
```
</build_commands>

## Sample Patch (highest-value fix)
<sample_patch>
```diff
--- a/src/api/users.js
+++ b/src/api/users.js
@@ -40,7 +40,8 @@

 async function getUserById(userId) {
-  const sql = `SELECT * FROM users WHERE id = ${userId}`;
-  return await db.query(sql);
+  const sql = 'SELECT * FROM users WHERE id = ?';
+  return await db.query(sql, [userId]);
 }
```

**Why this fix**: Prevents SQL injection attacks by using parameterized queries instead of string concatenation.
**Impact**: Eliminates P0 security vulnerability affecting user data.
**Effort**: 15 minutes to fix + test.
</sample_patch>

## Assumptions / Next Steps
<assumptions>
- Assumed Node.js/Express based on package.json
- Database appears to be MySQL/PostgreSQL based on query syntax
- No authentication middleware visible - may need separate review
- CI/CD pipeline not examined in detail - quick scan only

**Recommended next steps:**
1. Apply the SQL injection fix immediately
2. Run full security scan with tools like Snyk or OWASP ZAP
3. Add comprehensive test suite
4. Review authentication/authorization implementation
5. Set up proper logging and monitoring
</assumptions>

## Severity Levels
- **P0**: Critical exploitable/production-down
- **P1**: High impact, should fix within sprint
- **P2**: Moderate impact, plan for next sprint
- **P3**: Nice-to-have, backlog

## Quick Audit Completed
Total scan time: ~20 minutes
Focus areas: Security, Performance, Code Quality
Recommended follow-up: Full audit if P0/P1 issues found
