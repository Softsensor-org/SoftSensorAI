# Chain: Backend Feature - Step 5/5 - PR

You are executing step 5 of 5 for implementing a backend feature.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_SPEC_AND_VERIFICATION}
</input>

<goal>
Create a comprehensive pull request with clear documentation and rollout plan.
</goal>

<plan>
- Craft clear PR title with JIRA key
- Write comprehensive description
- Include test results and verification
- Document rollout and rollback plans
- Add review checklist
</plan>

<work>
1. Commit with descriptive message:
   ```bash
   git add -A
   git commit -m "{JIRA_KEY}: {feature_description}

   - {change_1}
   - {change_2}
   - {change_3}"
   ```

2. Push and create PR:
   ```bash
   git push origin {branch_name}
   gh pr create --title "{JIRA_KEY}: {title}" --body "..."
   ```
</work>

<review>
- [ ] PR title includes JIRA key
- [ ] Description explains why, not just what
- [ ] Test results included
- [ ] Breaking changes documented
- [ ] Rollback plan clear
</review>

<handoff>
<pr>
## Title
`{JIRA_KEY}: {Clear, concise description}`

## Description

### Summary
{1-2 sentences explaining the change}

### Problem
{Link to JIRA ticket}
{Brief problem description}

### Solution
- {Key change 1}
- {Key change 2}
- {Key change 3}

### Testing
✅ Unit tests: X added, all passing
✅ Integration tests: Verified
✅ Manual testing: See checklist below

### Rollout Plan
1. {Step 1}
2. {Step 2}
3. Monitor: {What to watch}

### Rollback Plan
```bash
git revert {this_commit}
# OR: feature flag disable
```

### Review Checklist
- [ ] Tests pass locally
- [ ] No console.logs or debug code
- [ ] Documentation updated
- [ ] Security considerations addressed
- [ ] Performance impact acceptable
- [ ] Breaking changes communicated

### Screenshots/Logs
{If applicable}

---
Related: {JIRA_KEY}
</pr>
</handoff>
