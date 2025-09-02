# A Week with DevPilot: Daily Runbook

Your first week using DevPilot for real development work. Follow this day-by-day guide to master the
essential workflows.

## Prerequisites

- DevPilot globally installed (`~/devpilot/setup_all.sh` completed)
- AI CLI tools installed (claude, codex, gemini, grok)
- A project to work on

## Day 1 (Monday): Setup & First Feature

### Morning: Project Setup

```bash
# For existing repo (most common)
cd /path/to/your/project
dp setup
dp init --skill l1 --phase mvp

# Verify setup and explore commands
dp project  # Shows current configuration
dp palette  # Browse all available commands
```

### Afternoon: First Feature with AI

```bash
# Use the exploration workflow for a complete feature
claude --system-prompt system/active.md \
  "/explore-plan-code-test implement user preferences endpoint"

# The AI will:
# 1. Explore existing code patterns
# 2. Plan the implementation
# 3. Write the code
# 4. Generate tests
```

**Before/After Example:**

Before DevPilot:

```
You: "Add a user preferences endpoint"
AI: "Here's some code..." [No structure, no tests, no consistency]
```

After DevPilot:

```
You: /explore-plan-code-test implement user preferences endpoint
AI:
  EXPLORE: Found existing patterns in controllers/...
  PLAN: 1) Schema 2) Controller 3) Service 4) Tests
  CODE: [Follows your patterns exactly]
  TEST: [Comprehensive test suite]
  ✓ All checks pass
```

## Day 2 (Tuesday): Security & Quality

### Morning: Security Review

```bash
# Before committing yesterday's work
claude --system-prompt .claude/commands/security-review.md \
  "review the user preferences endpoint"

# Run automated security scans
gitleaks detect --source .
semgrep --config=auto .

# Fix any issues found
claude --system-prompt .claude/commands/patterns/secure-fix.md \
  "fix the SQL injection risk in preferences controller"
```

### Afternoon: Code Quality Audit

```bash
# Comprehensive quality check
claude --system-prompt .claude/commands/audit-quick.md \
  "check code quality for the new endpoint"

# Generate missing documentation
claude --system-prompt .claude/commands/patterns/document-code.md \
  "add JSDoc comments to the preferences module"
```

**Before/After Example:**

Before:

```sql
-- Vulnerable query
query = f"SELECT * FROM preferences WHERE user_id = {user_id}"
```

After security review:

```sql
-- Parameterized query
query = "SELECT * FROM preferences WHERE user_id = ?"
cursor.execute(query, (user_id,))
```

## Day 3 (Wednesday): API Contracts & Testing

### Morning: API Documentation

```bash
# Update OpenAPI specification
claude --system-prompt .claude/commands/patterns/api-contract.md \
  "update OpenAPI spec for preferences endpoint"

# Validate contract
npx @apidevtools/swagger-cli validate openapi.yaml
```

### Afternoon: Comprehensive Testing

```bash
# Generate edge case tests
claude --system-prompt .claude/commands/patterns/test-comprehensive.md \
  "create edge case tests for preferences endpoint"

# Run tests with coverage
npm test -- --coverage

# If coverage < 80%, add more tests
claude --system-prompt .claude/commands/patterns/test-driven.md \
  "increase test coverage for uncovered branches"
```

**Before/After Example:**

Before (60% coverage):

```javascript
test("should get preferences", async () => {
  const res = await api.get("/preferences");
  expect(res.status).toBe(200);
});
```

After comprehensive testing (95% coverage):

```javascript
describe('Preferences API', () => {
  test('should get preferences for authenticated user', ...);
  test('should return 401 for unauthenticated requests', ...);
  test('should handle missing preferences gracefully', ...);
  test('should validate preference schema on update', ...);
  test('should rate limit excessive requests', ...);
  test('should handle database connection errors', ...);
});
```

## Day 4 (Thursday): Architecture & Scale

### Morning: Architecture Review

```bash
# Analyze current architecture
claude --system-prompt .claude/commands/patterns/architecture-review.md \
  "review system architecture and identify bottlenecks"

# Performance analysis
claude --system-prompt .claude/commands/patterns/performance-pass.md \
  "analyze query performance in preferences service"
```

### Afternoon: Scalability Planning

```bash
# Design improvements
codex --system .claude/commands/patterns/architect-spike.md \
  "design caching strategy for preferences service"

# Generate implementation plan
claude --system-prompt .claude/commands/patterns/scale-analysis.md \
  "plan migration to Redis for preference caching"
```

**Before/After Example:**

Before (no caching):

```
Request → Database query (100ms) → Response
1000 req/s = 100% CPU on database
```

After architecture review:

```
Request → Redis cache (1ms) → Response (cache hit)
         ↘ Database (100ms) → Redis → Response (cache miss)
10000 req/s = 10% CPU with 90% cache hit rate
```

## Day 5 (Friday): Documentation & Planning

### Morning: Generate Tickets

```bash
# Scan codebase for TODOs and technical debt
claude --system-prompt .claude/commands/tickets-from-code.md \
  "generate backlog from TODO comments and FIXME tags"

# The output will be structured tickets with:
# - Title and description
# - Acceptance criteria
# - Effort estimates
# - Priority suggestions
```

### Afternoon: Observability & Monitoring

```bash
# Add comprehensive logging
claude --system-prompt .claude/commands/patterns/observability-pass.md \
  "add structured logging to preferences service"

# Add metrics
claude --system-prompt .claude/commands/patterns/metrics-instrumentation.md \
  "add Prometheus metrics for preference operations"
```

**Before/After Example:**

Before (no observability):

```javascript
function updatePreferences(userId, prefs) {
  return db.update("preferences", prefs, { userId });
}
```

After observability pass:

```javascript
function updatePreferences(userId, prefs) {
  const timer = metrics.startTimer('preferences_update_duration');
  logger.info('Updating preferences', { userId, prefsCount: Object.keys(prefs).length });

  try {
    const result = await db.update('preferences', prefs, { userId });
    metrics.increment('preferences_updates_total', { status: 'success' });
    logger.info('Preferences updated successfully', { userId });
    return result;
  } catch (error) {
    metrics.increment('preferences_updates_total', { status: 'error' });
    logger.error('Failed to update preferences', { userId, error: error.message });
    throw error;
  } finally {
    timer.end();
  }
}
```

## Week 1 Summary: Key Commands Used

### Top 5 Most Valuable Commands

1. **`/explore-plan-code-test`** (Monday)

   - Used 10+ times for feature development
   - Saves 2-3 hours per feature by automating the full cycle

2. **`/security-review`** (Tuesday)

   - Used before every commit
   - Caught 3 security issues before they reached code review

3. **`/tickets-from-code`** (Friday)

   - Generated 15 properly formatted tickets
   - Saved 2 hours of manual ticket writing

4. **`/api-contract`** (Wednesday)

   - Kept OpenAPI spec in sync
   - Prevented API drift and documentation lag

5. **`/observability-pass`** (Friday)
   - Added comprehensive logging/metrics
   - Made the service production-ready

## Week 2 Preview: Advanced Workflows

### Monday: Long Context Handling

```bash
# Analyze large log files
claude --system-prompt .claude/commands/automation/long-context-map-reduce.md \
  "summarize errors from the past week's logs" < app.log
```

### Tuesday: Multi-Service Refactoring

```bash
# Coordinate changes across services
claude --system-prompt .claude/commands/patterns/multi-service-refactor.md \
  "split monolith authentication into microservice"
```

### Wednesday: Database Migrations

```bash
# Safe database changes
claude --system-prompt .claude/commands/patterns/sql-migration.md \
  "create migration to add preferences versioning"
```

### Thursday: CI/CD Pipeline

```bash
# Upgrade to production phase
scripts/apply_profile.sh --phase scale

# Review what's now enforced
cat .github/workflows/ci.yml | grep -E "(gitleaks|semgrep|trivy)"
```

### Friday: Performance Optimization

```bash
# Profile and optimize
claude --system-prompt .claude/commands/patterns/performance-pass.md \
  "optimize N+1 queries in preferences loader"
```

## Tips for Success

### Daily Habits

1. **Start each day** by checking your profile and personas:

   ```bash
   scripts/profile_show.sh && ~/devpilot/scripts/persona_manager.sh show
   ```

2. **Before coding**, always use explore-plan pattern:

   ```bash
   claude --system-prompt system/active.md "/explore-plan-code-test [feature]"
   ```

3. **Before committing**, always security review:

   ```bash
   claude --system-prompt .claude/commands/security-review.md "review changes"
   ```

4. **End of day**, generate tickets for tomorrow:
   ```bash
   claude --system-prompt .claude/commands/tickets-from-code.md "scan for TODOs"
   ```

### Common Pitfalls to Avoid

❌ **Don't**: Use AI without system prompts ✅ **Do**: Always include
`--system-prompt system/active.md`

❌ **Don't**: Write ad-hoc prompts for common tasks ✅ **Do**: Use the command catalog
(`/security-review`, `/test-driven`, etc.)

❌ **Don't**: Skip the exploration phase ✅ **Do**: Let AI understand your codebase patterns first

❌ **Don't**: Commit without security review ✅ **Do**: Run `/security-review` on every change

❌ **Don't**: Stay on POC phase in production ✅ **Do**: Graduate to beta/scale phases for proper CI
gates

## Measuring Success

After one week with DevPilot, you should see:

- ✅ **50% faster** feature development (explore → plan → code → test)
- ✅ **Zero security issues** reaching code review (security-review catches them)
- ✅ **90%+ test coverage** (comprehensive test generation)
- ✅ **100% API documentation** coverage (api-contract keeps it synced)
- ✅ **Structured backlog** with estimates (tickets-from-code)

## Next Steps

1. **Explore more commands**: Browse `.claude/commands/` for specialized workflows
2. **Add custom commands**: Create project-specific commands in `.claude/commands/custom/`
3. **Graduate phases**: Move from MVP → Beta → Scale as project matures
4. **Share learnings**: Document patterns that work well for your team

---

_By the end of Week 1, DevPilot will feel like a senior developer pair programming with you._
