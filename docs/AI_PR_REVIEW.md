# AI PR Review Setup Guide

## Overview

DevPilot includes a **CLI-first, zero-secrets** AI PR review workflow that automatically reviews
pull requests using installed AI CLIs (Claude, Codex, Gemini, or Grok).

## Key Features

- **Zero Secrets Required**: No API keys stored in GitHub
- **CLI-First**: Uses locally installed CLIs only
- **Non-Blocking**: Reviews are advisory, won't fail PRs
- **Multi-Provider**: Supports Claude, Codex, Gemini, and Grok
- **Neutral Fallback**: Exits cleanly if no CLI is available

## How to Enable

### Method 1: Repository Variable (Recommended)

1. Go to **Settings** → **Secrets and variables** → **Actions** → **Variables**
2. Click **New repository variable**
3. Name: `AI_REVIEW_ENABLED`
4. Value: `true`
5. Click **Add variable**

Now all PRs will get AI reviews automatically.

### Method 2: PR Label

Add the `ai-review` label to any PR to trigger a review for that specific PR only.

```bash
# Via GitHub CLI
gh pr edit 123 --add-label ai-review

# Via GitHub UI
# Go to PR → Labels → Add "ai-review"
```

## CLI Installation

The workflow tries CLIs in this order: Claude → Codex → Gemini → Grok

For detailed installation instructions, see the [AI CLI Installation Guide](./AI_CLI_INSTALL.md).

### Quick Setup

```bash
# Install Anthropic CLI (recommended)
pip install anthropic

# Set API key
export ANTHROPIC_API_KEY="sk-ant-..."

# Verify
command -v anthropic && echo "✓ Ready for AI reviews"
```

## How It Works

1. **Trigger**: Opens/updates PR with `AI_REVIEW_ENABLED=true` or `ai-review` label
2. **Diff Generation**: Gets full PR diff from base branch
3. **CLI Detection**: Checks for installed CLIs in order
4. **Review**: Runs first available CLI with system prompt
5. **Comment**: Posts review as PR comment (updates if exists)
6. **Neutral Exit**: Exits 0 if no CLI found (non-blocking)

## Workflow Configuration

The workflow is defined in `.github/workflows/ai-review.yml`:

```yaml
name: AI PR Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    continue-on-error: true # Non-blocking
    if: >-
      ${{
        vars.AI_REVIEW_ENABLED == 'true' ||
        contains(join(github.event.pull_request.labels.*.name, ','), 'ai-review')
      }}
```

## Review Focus Areas

The AI reviewer checks for:

- **Security Issues**

  - Hardcoded credentials
  - SQL injection vulnerabilities
  - XSS vulnerabilities
  - Insecure configurations

- **Performance Problems**

  - N+1 queries
  - Memory leaks
  - Inefficient algorithms
  - Missing indexes

- **Bugs**

  - Null/undefined checks
  - Race conditions
  - Logic errors
  - Off-by-one errors

- **Best Practices**
  - Code style violations
  - Missing error handling
  - Poor naming conventions
  - Missing tests

## Customizing the Review

### System Prompt

The default system prompt is minimal. To customize:

1. Create `system/ai-review.md` in your repo:

```markdown
You are an expert code reviewer for our team.

Focus on:

- Our specific coding standards
- Domain-specific concerns
- Performance requirements
- Security policies

Be constructive and suggest specific fixes.
```

2. Update the workflow to use your custom prompt:

```yaml
- name: Setup system prompt
  run: |
    # Use custom prompt if exists, otherwise default
    if [ -f system/ai-review.md ]; then
      cp system/ai-review.md system/active.md
    else
      # ... default prompt ...
    fi
```

## Example Output

When a PR is reviewed, you'll see a comment like:

> ## 🤖 AI Review (Claude)
>
> **Security Concerns:**
>
> - Line 42: Potential SQL injection in user input handling
> - Line 156: API key appears to be hardcoded
>
> **Performance Issues:**
>
> - Line 89: This loop could be optimized using map/filter
> - Line 234: Consider caching this database query
>
> **Suggestions:**
>
> - Add input validation for user-provided data
> - Move credentials to environment variables
> - Add error handling for async operations
>
> ---
>
> _This is an automated review. Please verify suggestions before implementing._

## Troubleshooting

### No Review Posted

Check if:

1. `AI_REVIEW_ENABLED` is set to `true` in repo variables
2. PR has `ai-review` label (if using label method)
3. At least one CLI is installed on the runner

### Review Not Updating

The workflow checks for existing comments and updates them. If you want a fresh review:

1. Delete the existing bot comment
2. Push a new commit or re-run the workflow

### CLI Not Found

If you see "No AI CLI available" in the workflow logs:

1. Install one of the supported CLIs on your runner
2. Or use a custom runner with CLIs pre-installed
3. Or add a setup step to install CLIs in the workflow

## Benefits

- **Fast Feedback**: Reviews in ~1-2 minutes
- **Consistent**: Same review criteria every time
- **Educational**: Helps juniors learn best practices
- **Non-Intrusive**: Advisory only, doesn't block merges
- **Zero Maintenance**: No API keys to rotate
- **Multi-Provider**: Not locked to one AI provider

## Security Considerations

- **No Secrets**: The workflow never uses API keys
- **Read-Only**: Only reads PR diffs, no write access
- **Sandboxed**: Runs in GitHub Actions container
- **Auditable**: All reviews are public PR comments
- **Rate Limited**: Subject to GitHub Actions limits

## Cost

- **GitHub Actions**: Standard Actions minutes apply
- **AI CLI Usage**: Depends on your CLI provider's pricing
- **Typical Cost**: < $0.01 per PR review

## Comparison with Alternatives

| Feature           | DevPilot AI Review | GitHub Copilot | CodeRabbit | Traditional Review |
| ----------------- | ------------------ | -------------- | ---------- | ------------------ |
| Setup Time        | 2 minutes          | 5 minutes      | 15 minutes | N/A                |
| API Keys Required | ❌ No              | ✅ Yes         | ✅ Yes     | ❌ No              |
| Multi-Provider    | ✅ Yes             | ❌ No          | ❌ No      | N/A                |
| Customizable      | ✅ Yes             | ⚠️ Limited     | ✅ Yes     | ✅ Yes             |
| Non-Blocking      | ✅ Yes             | ✅ Yes         | ✅ Yes     | ❌ No              |
| Response Time     | 1-2 min            | 1-2 min        | 2-5 min    | Hours/Days         |
| Cost              | ~$0.01             | $10/month      | $15/month  | Developer time     |

## Next Steps

1. Enable AI reviews: Set `AI_REVIEW_ENABLED=true`
2. Install a CLI on your runner (or use GitHub-hosted runners with setup)
3. Open a test PR to verify it works
4. Customize the system prompt for your team's needs
5. Track metrics on review usefulness

## Support

- **Issues**: [GitHub Issues](https://github.com/Softsensor-org/DevPilot/issues)
- **Workflow**: `.github/workflows/ai-review.yml`
- **Customization**: See "Customizing the Review" section above
