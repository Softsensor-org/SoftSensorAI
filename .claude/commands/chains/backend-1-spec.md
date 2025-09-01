# Chain: Backend Feature - Step 1/5 - SPEC

You are executing step 1 of 5 for implementing a backend feature.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
Feature request: {PASTE_FEATURE_REQUEST_HERE}
JIRA Key: {PASTE_JIRA_KEY_HERE}
</input>

<goal>
Produce a complete technical specification that defines interfaces, acceptance criteria, and migration requirements.
</goal>

<plan>
- Analyze existing codebase for patterns and conventions
- Define clear interfaces (function signatures/routes)
- List objective acceptance checks
- Identify database/state migration needs
- Document rollback strategy
</plan>

<work>
1. Search for similar features in codebase:
   ```bash
   rg -t js -t ts "router\.|app\." --max-count 5
   rg -t py "def.*route|@app" --max-count 5
   ```

2. Identify conventions:
   - Routing patterns
   - Error handling approach
   - Validation strategy
   - Test structure

3. Define specification
</work>

<review>
- [ ] Problem clearly framed in ≤5 bullets
- [ ] All interfaces have types/signatures
- [ ] Acceptance checks are objective and testable
- [ ] Migration path is safe and reversible
- [ ] Rollback strategy documented
</review>

<handoff>
<spec>
## Problem
- {BULLET_1}
- {BULLET_2}
- {BULLET_3}

## Interfaces
```typescript
// or Python signatures
```

## Acceptance Checks
1. Given X, when Y, then Z
2. ...

## Migration Notes
- Database changes: {NONE_OR_DETAILS}
- Breaking changes: {NONE_OR_LIST}
- Rollback: {STRATEGY}

## Non-goals
- {WHAT_THIS_DOES_NOT_SOLVE}
</spec>
</handoff>
