# Agentic Coding with DevPilot

DevPilot's agent capability enables autonomous task execution with built-in safety and quality
controls.

## Overview

The `dp agent` command provides a structured workflow for AI-assisted development:

1. **Specification** → Define what needs to be done
2. **Planning** → AI creates detailed execution plan
3. **Execution** → Run plan with codemod-first edits
4. **Verification** → Automated quality checks
5. **Pull Request** → Clean PR from verified changes

## Quick Start

```bash
# Create a new task with a goal
dp agent new --goal "Add rate limiting to the API endpoints"

# This creates a task with ID like: rate-limiting-api-20241203-123456
# View the generated spec at: artifacts/agent/<task_id>/spec.md

# Run the agent to create and execute a plan
dp agent run --id <task_id> --auto

# Create a pull request from the changes
dp agent pr --id <task_id> --title "feat: Add API rate limiting"
```

## Commands

### `dp agent new --goal "<text>" [--base main]`

Creates a new agent task with a specification.

**Parameters**:

- `--goal`: Natural language description of what to accomplish
- `--base`: Base branch to work from (default: main)

**Output**:

- Task ID (e.g., `rate-limiting-api-20241203-123456`)
- Specification saved to `artifacts/agent/<task_id>/spec.md`

Example:

```bash
dp agent new --goal "Add JWT authentication with refresh tokens to the REST API"
# Output: Created task: jwt-auth-20241203-145632
# Spec written to: artifacts/agent/jwt-auth-20241203-145632/spec.md
```

### `dp agent run --id <task_id> [--auto] [--loops N]`

Executes a task by generating a plan and applying changes.

**Parameters**:

- `--id`: Task ID from `dp agent new`
- `--auto`: Run without manual approval prompts
- `--loops`: Number of refinement loops (default: 1)

**Features**:

- Codemod-first edits using comby
- Targeted test execution for changed files
- Coverage tracking with delta reporting
- Context packing for better prompts

**Artifacts Created**:

- `artifacts/agent/<task_id>/plan.json` - Execution plan
- `artifacts/agent/<task_id>/run.json` - Execution results
- `artifacts/agent/<task_id>/verify.json` - Verification results
- `artifacts/agent/<task_id>/work/` - Working directory with changes

Example:

```bash
# Run with manual review at each step
dp agent run --id jwt-auth-20241203-145632

# Run automatically with 2 refinement loops
dp agent run --id jwt-auth-20241203-145632 --auto --loops 2
```

### `dp agent pr --id <task_id> [--title ...]`

Creates a pull request from verified changes.

**Parameters**:

- `--id`: Task ID with completed changes
- `--title`: PR title (optional, uses task goal if not provided)

**Process**:

1. Creates a feature branch from the work
2. Commits all verified changes
3. Pushes to remote
4. Opens PR using `gh` CLI if available

Example:

```bash
dp agent pr --id jwt-auth-20241203-145632 --title "feat: Add JWT authentication"
```

### `dp agent eval <suite.yaml>`

Runs an evaluation suite to test agent capabilities.

**Input**: YAML file defining test scenarios

Example suite (`.agent/suites/local/sample.yaml`):

```yaml
suite: local
base: main
goals:
  - "Refactor: extract helper into utils for duplicate code in src/"
  - "Add basic unit test for an uncovered module in src/"
  - "Fix: resolve the TODO comment in database connection"
```

## Artifact Structure

All agent artifacts are stored under `artifacts/agent/<task_id>/`:

```
artifacts/agent/jwt-auth-20241203-145632/
├── spec.md          # Task specification
├── plan.json        # Generated execution plan
├── run.json         # Execution metadata and results
├── verify.json      # Verification results
├── coverage.json    # Test coverage data
└── work/            # Git worktree with actual changes
    └── ...          # Modified files
```

## Verification

After execution, the agent runs comprehensive checks:

- **Build**: Ensures code compiles/builds
- **Tests**: Runs test suite and tracks coverage
- **Lint**: Checks code style
- **Security**: Scans for vulnerabilities
- **Risk Analysis**: Tags changes (auth, db, infra, ml, security)

Results in `artifacts/agent/<task_id>/verify.json`:

```json
{
  "task_id": "jwt-auth-20241203-145632",
  "status": "success",
  "checks": {
    "build": { "status": "success", "time": 2.3 },
    "tests": {
      "status": "success",
      "passed": 47,
      "failed": 0,
      "coverage": 82.5,
      "coverage_delta": "+3.2"
    },
    "lint": { "status": "warning", "issues": 2 },
    "security": { "status": "success" }
  },
  "risk_tags": ["auth", "security"],
  "files_changed": 12,
  "lines_added": 234,
  "lines_removed": 45
}
```

## Best Practices

### Writing Goals

1. **Be Specific**: Include acceptance criteria

   ```bash
   # Good
   dp agent new --goal "Add rate limiting: 100 req/min per user, return 429 status, include retry-after header"

   # Too vague
   dp agent new --goal "Add rate limiting"
   ```

2. **Set Boundaries**: Specify what NOT to change

   ```bash
   dp agent new --goal "Refactor user service to repository pattern. Don't modify API contracts or database schema"
   ```

3. **Include Context**: Reference existing patterns
   ```bash
   dp agent new --goal "Add image upload like we did for documents: S3 storage, CDN delivery, 5MB limit"
   ```

### Reviewing Plans

Before approving execution, verify the plan:

- [ ] Steps are atomic and reversible
- [ ] Includes appropriate tests
- [ ] Handles error cases
- [ ] No unintended scope creep
- [ ] Uses codemods for systematic changes

### Safety Guidelines

- Agent works in isolated git worktree
- Changes are verified before PR
- Coverage must not decrease
- Risk tags highlight sensitive changes
- All artifacts preserved for audit

## Troubleshooting

### Finding Task Information

```bash
# List recent tasks
ls -la artifacts/agent/

# View task specification
cat artifacts/agent/<task_id>/spec.md

# Check execution results
jq '.status' artifacts/agent/<task_id>/verify.json
```

### Execution Issues

1. **Check logs**:

   ```bash
   cat artifacts/agent/<task_id>/run.json | jq '.logs'
   ```

2. **Inspect worktree**:

   ```bash
   cd artifacts/agent/<task_id>/work
   git status
   git diff
   ```

3. **Review verification failures**:
   ```bash
   jq '.checks | to_entries | map(select(.value.status != "success"))' \
     artifacts/agent/<task_id>/verify.json
   ```

### Recovery

If execution fails:

```bash
# Retry with more loops
dp agent run --id <task_id> --loops 3

# Or create new task with refined goal
dp agent new --goal "Previous goal but with specific constraint..."
```

## Configuration

### Model Selection

```bash
# Use specific model for planning
export AI_MODEL_ANTHROPIC="claude-3-opus-20240229"
dp agent new --goal "Complex refactoring task"

# Use different model for execution
export AI_MODEL_ANTHROPIC="claude-3-sonnet-20240229"
dp agent run --id <task_id>
```

### Resource Limits

```bash
# Increase timeout for complex tasks
export AGENT_TIMEOUT_SECS=600

# Limit concurrent test execution
export AGENT_MAX_PARALLEL_TESTS=4
```

## Examples

### Example 1: Add Authentication

```bash
# Create task
dp agent new --goal "Add JWT authentication to REST API: RS256, refresh tokens, /auth/login and /auth/refresh endpoints, protect existing endpoints, include tests"

# Review spec (optional)
cat artifacts/agent/*/spec.md

# Execute with auto-approval
dp agent run --id jwt-auth-* --auto

# Create PR
dp agent pr --id jwt-auth-* --title "feat: Add JWT authentication"
```

### Example 2: Refactor for Testability

```bash
# Create task with constraints
dp agent new --goal "Refactor user service for testability: extract repository layer, add dependency injection, create interfaces, maintain backward compatibility, achieve 80% coverage"

# Run with manual review
dp agent run --id refactor-user-*

# Review changes before PR
cd artifacts/agent/refactor-user-*/work
git diff --stat

# Create PR
dp agent pr --id refactor-user-*
```

### Example 3: Fix Bug

```bash
# Quick bug fix
dp agent new --goal "Fix: Users seeing others' private posts in feed. Add privacy filter to post query, include tests for public/private/friend visibility"

# Auto-execute small fix
dp agent run --id fix-privacy-* --auto

# Fast PR creation
dp agent pr --id fix-privacy-*
```

## Advanced Features

### Codemods

The agent prefers systematic changes using comby patterns:

```json
{
  "step": "Replace console.log with logger",
  "method": "codemod",
  "language": "typescript",
  "match": "console.log(:[args])",
  "rewrite": "logger.info(:[args])"
}
```

### Coverage Tracking

Coverage is tracked per execution:

- Baseline coverage before changes
- Coverage after changes
- Delta reporting (+/- percentage)
- Per-file coverage details

### Risk Analysis

Changes are automatically tagged:

- `auth`: Authentication/authorization changes
- `db`: Database schema or query changes
- `infra`: Infrastructure/deployment changes
- `ml`: Machine learning model/pipeline changes
- `security`: Security-sensitive modifications

### Evaluation Suites

Create comprehensive test suites:

```yaml
suite: refactoring
base: main
timeout: 300
goals:
  - "Extract duplicate validation logic into shared utility"
  - "Add missing error handling in API endpoints"
  - "Improve test coverage for user module to 90%"
success_criteria:
  - tests_pass: true
  - coverage_increased: true
  - no_breaking_changes: true
```

## Future Enhancements

Planned improvements:

- [ ] Multi-step workflows with checkpoints
- [ ] Parallel task execution
- [ ] Integration with issue trackers
- [ ] Custom verification rules
- [ ] Plan templates library
- [ ] Automatic rollback on failure
- [ ] Progress visualization
- [ ] Cost estimation before execution
- [ ] Incremental re-planning

## See Also

- [Command Registry](commands/README.md) - All DevPilot commands
- [AI CLI Guide](AI_CLI.md) - Using AI tools directly
- [Multi-User Setup](MULTI_USER_SETUP.md) - Shared server installations
