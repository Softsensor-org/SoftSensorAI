# Command: tickets-from-code (CLI‑first)

> **Save as:** `.claude/commands/tickets-from-code.md`
> **Purpose:** Generate a *structured* engineering backlog directly from the codebase (or a supplied diff), for **Claude / Codex / Gemini / Grok** CLIs.
> **Output:** **JSON only** (strict schema below). No markdown fences, no prose.

---

## ROLE

You are a senior staff engineer, SRE, and security reviewer. Produce a *prioritized* backlog of improvements across code quality, testing, documentation, reliability, and security for the target repository.

## CONTEXT (filled by caller)

* **PHASE:** `<poc|mvp|beta|scale>` (affects security/test gates)
* **SKILL\_PROFILE:** `<l1|l2|expert>` (affects tone/assumptions)
* **TECH\_STACK:** `<short list, e.g., ts+express+postgres>`
* **NON\_GOALS:** `<optional bullets>`
* **DIFF:** `<optional unified diff or paths>`
* **SCOPE\_HINTS:** `<optional: folders/files to focus on>`
* **REPO\_MAP:** `<optional: file tree, cloc, or inventory>`

> If `DIFF` is provided, focus primarily on changed areas; otherwise, perform a repo‑wide sweep guided by `REPO_MAP`.

## GOVERNANCE DIAL (interpretation)

* **POC/MVP:** security and SAST findings are **advisory**; must include essential tests and docs.
* **BETA:** **block** HIGH/CRITICAL vulns & exposed secrets; raise coverage to ≥60%.
* **SCALE:** **block** MEDIUM+ SAST; coverage ≥80%; IaC hardening if present.

## OUTPUT — STRICT JSON SCHEMA

Output **only** a single JSON object matching this schema:

```json
{
  "repo": "<name>",
  "phase": "poc|mvp|beta|scale",
  "generated_at": "YYYY-MM-DD",
  "tickets": [
    {
      "id": "T-001",
      "title": "short imperative",
      "type": "feat|fix|refactor|docs|test|security|chore",
      "priority": "P0|P1|P2|P3",
      "effort": "XS|S|M|L|XL",
      "labels": ["ai","devx"],
      "assignee": "",
      "dependencies": ["T-00N"],
      "notes": "concise rationale and scope",
      "acceptance_criteria": [
        "observable, testable outcomes",
        "thresholds or examples"
      ]
    }
  ]
}
```

## NORMS

* IDs increment from **T‑001** in order of **descending priority** (P0→P3).
* **Effort scale:** XS(≤0.5d), S(≤1d), M(1–2d), L(3–5d), XL(>1wk). Use conservative estimates.
* **Security:**

  * MVP: include at least one secret scan + dependency audit ticket.
  * BETA+: include actionable fixes for HIGH/CRIT vulns and secret exposure; ensure CI gates are reflected in acceptance criteria.
* **Testing:** include tests where coverage is likely missing (unit + smoke + e2e where relevant).
* **Docs:** README gaps, setup scripts, runbooks, contribution guide.
* **Reliability/Obs:** logging, metrics, tracing, alerts; add SLO‑linked tasks if applicable.

## CONSTRAINTS

* **DO NOT** output analysis, explanation, markdown fences, or any text outside the JSON.
* Max **30 tickets**; prefer crisp, shippable items. Merge trivially related fixes.
* Include at least **1** ticket per relevant domain (security, tests, docs, reliability) unless `NON_GOALS` excludes it.

## VALIDATION (self‑check before emitting)

1. JSON parses.
2. `.tickets` is a non‑empty array.
3. IDs are unique and sequential from T‑001.
4. All tickets include **title, type, priority, effort, acceptance\_criteria**.
5. If `phase ∈ {beta, scale}`, include tickets that *activate or tighten* CI gates accordingly.

---

## CALLER INSTRUCTIONS (CLI examples)

> Provide `CONTEXT` and optional `DIFF/REPO_MAP` via an input file. Point the CLI's **system** to `system/active.md`.

* **Claude (anthropic):**

```bash
anthropic messages create \
  --model claude-3-7-sonnet-20250219 \
  --system "$(cat system/active.md)" \
  --input-file artifacts/tickets_prompt.txt \
  --max-tokens 4000 > artifacts/tickets.json
```

* **Codex:**

```bash
codex exec \
  --model codex-latest \
  --system-file system/active.md \
  --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json
```

* **Gemini / Vertex:**

```bash
gemini generate \
  --model gemini-1.5-pro-latest \
  --system-file system/active.md \
  --prompt-file artifacts/tickets_prompt.txt > artifacts/tickets.json
```

* **Grok / OpenRouter:**

```bash
grok chat --model grok-2-latest \
  --system "$(cat system/active.md)" \
  --input-file artifacts/tickets_prompt.txt > artifacts/tickets.json
```

### Convert to CSV (optional)

```bash
jq -r '.tickets[] | [ .id, .title, .type, .priority, .effort, (.labels // [] | join("|")), (.assignee // ""), (.dependencies // [] | join("|")), (.notes // "" | gsub("[\r\n]+";" ")), (.acceptance_criteria // [] | join("; ")) ] | @csv' \
  artifacts/tickets.json > artifacts/tickets.csv
```
