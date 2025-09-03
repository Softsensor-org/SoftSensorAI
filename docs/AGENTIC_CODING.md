# Agentic Coding with DevPilot

DevPilot's agent capability enables autonomous task execution with built-in safety and quality
controls.

## Overview

The `dp agent` command provides a structured workflow for AI-assisted development:

1. **Specification** → Define what needs to be done
2. **Planning** → AI creates detailed execution plan
3. **Execution** → Run plan in isolated sandbox
4. **Verification** → Automated quality checks
5. **Pull Request** → Clean PR from verified changes

## Quick Start

```bash
# Write a task specification
echo "Add rate limiting to the API endpoints" > task.md

# Generate execution plan
dp agent new task.md

# Review plan at .agent-work/plan.md, then execute
dp agent run .agent-work/plan.md

# Create pull request
dp agent pr "feat: Add API rate limiting"
```

## Commands

### `dp agent new <spec-file>`

Analyzes a task specification and generates an execution plan.

**Input**: Plain text or markdown file describing the task **Output**: Structured plan in
`.agent-work/plan.md`

Example specification:

```markdown
# Add User Avatar Upload

## Requirements

- Allow users to upload profile pictures
- Support JPEG and PNG formats
- Resize to 200x200 for storage
- Generate thumbnail (50x50)
- Store in S3 with CDN delivery

## Constraints

- Max file size: 5MB
- Must validate image content
- Preserve existing profile data
```

### `dp agent run <plan-file>`

Executes a plan in an isolated git worktree sandbox.

**Features**:

- Safe execution in separate worktree
- No impact on main working directory
- Full git history preserved
- Automatic verification after execution

### `dp agent pr [title]`

Creates a pull request from sandbox changes.

**Process**:

1. Commits all sandbox changes
2. Pushes to new branch
3. Opens PR (if `gh` CLI available)
4. Cleans up sandbox

## Sandbox Architecture

The agent uses git worktrees for isolation:

```
your-repo/              # Main working directory
├── .git/
└── ...

your-repo-agent-sandbox/  # Isolated agent workspace
├── .git/              # Linked to main repo
└── ...                # Complete copy for agent work
```

Benefits:

- Complete isolation from your work
- Full git functionality
- Easy rollback if needed
- No conflicts with local changes

## Verification

After execution, the agent runs comprehensive checks:

- **Build**: Ensures code compiles/builds
- **Tests**: Runs test suite
- **Lint**: Checks code style
- **Security**: Scans for vulnerabilities

Results are saved to `.agent-work/verify.json`:

```json
{
  "overall": "success",
  "checks": {
    "build": { "status": "success" },
    "tests": { "status": "success" },
    "lint": { "status": "warning" },
    "security": { "status": "success" }
  }
}
```

## Best Practices

### Writing Specifications

1. **Be Specific**: Include acceptance criteria
2. **Set Boundaries**: Define what NOT to change
3. **Include Context**: Reference existing code/patterns
4. **Define Success**: How to verify completion

### Reviewing Plans

Before executing, check that the plan:

- [ ] Has clear, atomic steps
- [ ] Includes verification at each step
- [ ] Handles error cases
- [ ] Has a rollback strategy

### Safety Guidelines

- Always review plans before execution
- Run in sandbox only (enforced by tool)
- Verify changes before creating PR
- Keep specifications in version control

## Troubleshooting

### Sandbox Issues

```bash
# Check sandbox status
scripts/agent_sandbox.sh status

# Clean up stuck sandbox
scripts/agent_sandbox.sh cleanup

# Manually remove worktree
git worktree remove ../agent-sandbox --force
```

### Execution Failures

1. Check execution log: `.agent-work/execution.log`
2. Review verification: `.agent-work/verify.json`
3. Inspect sandbox: `cd ../agent-sandbox && git status`

### PR Creation Issues

If automatic PR creation fails:

```bash
# Manual PR creation
cd ../agent-sandbox
git push -u origin <branch-name>
# Create PR via GitHub UI
```

## Configuration

### AI Model Selection

```bash
# Use specific model for planning
export AI_MODEL_CLAUDE="claude-3-opus-20240229"
dp agent new task.md

# Use different model for execution
export AI_MODEL_CLAUDE="claude-3-sonnet-20240229"
dp agent run plan.md
```

### Timeout Settings

```bash
# Increase timeout for complex tasks
export TIMEOUT_SECS=600
dp agent run complex-plan.md
```

## Examples

### Example 1: Add Authentication

```bash
cat > auth-task.md <<'EOF'
Add JWT authentication to REST API
- Use RS256 algorithm
- Include refresh token flow
- Add /auth/login and /auth/refresh endpoints
- Update existing endpoints to require auth
- Include tests
EOF

dp agent new auth-task.md
dp agent run .agent-work/plan.md
dp agent pr "feat: Add JWT authentication"
```

### Example 2: Refactor Module

```bash
cat > refactor.md <<'EOF'
Refactor user service for better testability
- Extract database queries to repository layer
- Add dependency injection
- Create interfaces for external services
- Maintain backward compatibility
- Improve test coverage to 80%
EOF

dp agent new refactor.md
# Review plan carefully for breaking changes
dp agent run .agent-work/plan.md
dp agent pr "refactor: Extract user repository layer"
```

### Example 3: Fix Bug

```bash
cat > bugfix.md <<'EOF'
Fix: Users seeing others' private posts in feed

Context: Private posts are appearing in public feeds
Root cause: Missing privacy check in feed query
Solution: Add privacy filter to post query
Tests: Include test cases for public/private/friend visibility
EOF

dp agent new bugfix.md
dp agent run .agent-work/plan.md
dp agent pr "fix: Add privacy filter to feed query"
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

## See Also

- [Command Registry](commands/README.md) - All DevPilot commands
- [AI CLI Guide](AI_CLI.md) - Using AI tools directly
- [Sandbox Documentation](SANDBOX.md) - Sandbox architecture details
