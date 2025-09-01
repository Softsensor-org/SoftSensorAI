# Command: tickets-from-diff (CLI‑first)

> **Save as:** `.claude/commands/tickets-from-diff.md`
> **Purpose:** Generate a structured backlog **only** from changes in a PR or local working tree.
> **Output:** **JSON only** (strict schema). No markdown fences, no prose.

---

## ROLE

You are a senior reviewer generating implementation tasks and review fixes **from a unified diff**.

## CONTEXT (filled by caller)

* **PHASE:** `<poc|mvp|beta|scale>`
* **DIFF:** `<required: unified diff content>`
* **RISK\_AREAS:** `<optional: e.g., auth, db migrations, concurrency>`

## OUTPUT JSON SCHEMA

Same as **tickets-from-code**, but restrict tickets to the scope of the `DIFF`:

```json
{
  "repo": "<name>",
  "phase": "poc|mvp|beta|scale",
  "generated_at": "YYYY-MM-DD",
  "diff_summary": "brief description of changes",
  "tickets": [
    {
      "id": "T-001",
      "title": "short imperative",
      "type": "feat|fix|refactor|docs|test|security|chore",
      "priority": "P0|P1|P2|P3",
      "effort": "XS|S|M|L|XL",
      "labels": ["diff-review","blocker"],
      "assignee": "",
      "dependencies": ["T-00N"],
      "notes": "concise rationale and scope",
      "acceptance_criteria": [
        "observable, testable outcomes",
        "merge requirements"
      ]
    }
  ]
}
```

## RULES

* Cover: broken tests, missing tests for new logic, error paths, logging/metrics, schema migrations, rollbacks, and security risks.
* Include a **rollback plan** ticket if the diff has migrations/infra changes.
* P0 tickets should be blockers to merge; P1 should be merge‑soon; others planned next.
* Focus **only** on the changed code - don't do repo-wide analysis.

## CONSTRAINTS

* Output **only JSON**; max **15 tickets**.
* **DO NOT** output analysis, explanation, markdown fences, or any text outside the JSON.

## VALIDATION (self‑check before emitting)

1. JSON parses.
2. All tickets relate to code in the provided `DIFF`.
3. P0/P1 tickets are merge-blocking or merge-soon items.
4. IDs are unique and sequential from T‑001.

---

## CLI EXAMPLE

```bash
# Generate diff from your working tree or PR
git diff --unified=3 --no-color origin/main...HEAD > artifacts/diff.patch

# Create input prompt
cat > artifacts/tickets_diff_prompt.txt <<EOF
PHASE: beta
RISK_AREAS: auth, database migrations
DIFF:
$(cat artifacts/diff.patch)
EOF

# Generate tickets with Claude
claude --system-prompt system/active.md \
  --input-file artifacts/tickets_diff_prompt.txt \
  --max-tokens 3000 > artifacts/tickets.json

# Or with other CLIs
codex --system-file system/active.md \
  --input-file artifacts/tickets_diff_prompt.txt > artifacts/tickets.json

gemini --system-file system/active.md \
  --prompt-file artifacts/tickets_diff_prompt.txt > artifacts/tickets.json

grok --system "$(cat system/active.md)" \
  --input-file artifacts/tickets_diff_prompt.txt > artifacts/tickets.json
```

## EXAMPLE INPUT

```
PHASE: beta
RISK_AREAS: auth, database
DIFF:
--- a/src/auth.js
+++ b/src/auth.js
@@ -15,7 +15,7 @@ function validateToken(token) {
-  return jwt.verify(token, SECRET_KEY);
+  return jwt.verify(token, process.env.JWT_SECRET);
 }

+function revokeToken(token) {
+  // TODO: implement token revocation
+  return Promise.resolve();
+}
```

## EXAMPLE OUTPUT

```json
{
  "repo": "auth-service",
  "phase": "beta",
  "generated_at": "2024-01-15",
  "diff_summary": "JWT secret externalized, added stub for token revocation",
  "tickets": [
    {
      "id": "T-001",
      "title": "Implement token revocation logic",
      "type": "feat",
      "priority": "P0",
      "effort": "M",
      "labels": ["diff-review","blocker","auth"],
      "assignee": "",
      "dependencies": [],
      "notes": "TODO comment indicates incomplete implementation",
      "acceptance_criteria": [
        "revokeToken() actually revokes tokens in database/cache",
        "Add tests for revocation scenarios",
        "Handle revocation errors appropriately"
      ]
    },
    {
      "id": "T-002",
      "title": "Add tests for JWT_SECRET environment variable",
      "type": "test",
      "priority": "P1",
      "effort": "S",
      "labels": ["diff-review","test"],
      "assignee": "",
      "dependencies": [],
      "notes": "Environment variable change needs test coverage",
      "acceptance_criteria": [
        "Test validateToken with missing JWT_SECRET",
        "Test validateToken with invalid JWT_SECRET",
        "Verify error handling for environment issues"
      ]
    }
  ]
}
```
