# Audit Output Template

This template shows the expected structure for audit outputs.

## Executive Summary
- 5–10 bullets covering top risks and opportunities
- Prioritized by impact and effort required
- Clear actionable recommendations

## Repo Map
<inventory>
```
project-root/
├── src/
│   ├── api/          # REST API endpoints
│   ├── services/     # Business logic 
│   ├── models/       # Data models
│   └── utils/        # Helper utilities
├── tests/           # Test suites
├── docs/            # Documentation
├── scripts/         # Build/deploy scripts
└── config/          # Configuration files
```

**Language Breakdown:**
- JavaScript: 60% (24 files, ~3.2k SLOC)
- TypeScript: 25% (10 files, ~1.8k SLOC) 
- Shell: 10% (5 files, ~500 SLOC)
- YAML: 5% (config files)

**Key Dependencies:**
- express@4.18.2 (web framework)
- mongoose@7.0.3 (MongoDB ODM)
- jsonwebtoken@9.0.0 (JWT handling)
- lodash@4.17.21 (utilities)
</inventory>

## Architecture Overview
<arch>
**High-level Architecture:**
Request → Express Router → Controller → Service → Model → Database

**Data Flow:**
1. Client requests hit Express middleware stack
2. Routes dispatch to controllers  
3. Controllers call business logic services
4. Services interact with MongoDB via Mongoose
5. Responses formatted and returned via JSON API

**Cross-cutting Concerns:**
- Authentication: JWT middleware on protected routes
- Error Handling: Custom error middleware catches and formats errors
- Logging: Winston logger with console + file transports
- Config: Environment variables via dotenv
- Validation: Joi schemas on request bodies
</arch>

## Findings (prioritized)
<findings>
| ID | Severity | Area | File:Line | Evidence | Why it matters | Suggested fix | Est. Effort |
|----|----------|------|-----------|----------|----------------|---------------|-------------|
| 1 | P0 | Security | auth.js:42 | `jwt.verify(token, 'hardcoded-secret')` | Hardcoded JWT secret enables token forgery | Use environment variable | 1h |
| 2 | P0 | Security | users.js:15 | `"SELECT * FROM users WHERE id=" + req.params.id` | SQL injection vulnerability | Use parameterized queries | 2h |
| 3 | P1 | Performance | api.js:28 | Synchronous file operations in request handler | Blocks event loop under load | Use async file operations | 4h |
| 4 | P1 | Reliability | db.js:10 | No connection retry logic | DB disconnects cause crashes | Add reconnection logic | 6h |
| 5 | P2 | Code Quality | utils.js:55 | 150-line function with nested conditionals | Hard to test and maintain | Extract smaller functions | 1d |
</findings>

## Remediation Plan
<plan>
### Quick Wins (≤1 day)
- Fix hardcoded JWT secret (P0, 1h)
- Fix SQL injection in users endpoint (P0, 2h)  
- Add .env.example file (15min)
- Enable ESLint in CI pipeline (30min)
- Add input validation middleware (4h)

### Medium (1–3 days)
- Implement async file operations (P1, 4h)
- Add database reconnection logic (P1, 6h)
- Refactor large utility functions (P2, 1d)
- Add comprehensive error handling (1d)
- Implement request rate limiting (6h)

### Big Rocks (>3 days)
- Add comprehensive test suite (2w)
- Implement proper logging strategy (1w)
- Add API documentation with OpenAPI (1w)
- Performance optimization for hot paths (1w)
- Security audit and hardening (1w)
</plan>

## Suggested Commands / PR Plan
<build_model>
### Build/Test Commands
```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Run tests
npm test

# Run linter
npm run lint

# Type checking (if TypeScript)
npm run typecheck

# Build for production
npm run build

# Run security audit
npm audit

# Run test coverage
npm run test:coverage
```
</build_model>

### Top 3 PRs
1. Branch: `fix/jwt-secret-env-var` - "Use environment variable for JWT secret"
2. Branch: `fix/sql-injection-users` - "Fix SQL injection in users endpoint"  
3. Branch: `feat/async-file-operations` - "Replace sync file ops with async"

### Sample Patches
```diff
--- a/src/auth/jwt.js
+++ b/src/auth/jwt.js
@@ -39,7 +39,7 @@ function verifyToken(token) {
   try {
-    const decoded = jwt.verify(token, 'hardcoded-secret');
+    const decoded = jwt.verify(token, process.env.JWT_SECRET);
     return { success: true, data: decoded };
   } catch (error) {
     return { success: false, error: 'Invalid token' };
```

## Open Questions
<open_q>
- Database schema not reviewed - may need separate data audit
- Authentication/authorization rules unclear from code scan
- Deployment process and infrastructure not examined
- Third-party service integrations need security review
- Performance requirements and SLA targets unknown
</open_q>

## Quality Gates
- All P0 issues fixed before production deployment
- Test coverage above 80% for core business logic  
- Security scan passes with no HIGH/CRITICAL findings
- Performance tests validate response times < 200ms p95
- Code review approval from senior engineer required