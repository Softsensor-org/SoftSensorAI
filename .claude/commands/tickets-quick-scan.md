# Quick Scan → Tickets (20 minutes)

Fast backlog extraction for rapid assessment.

## System Context
You are a principal engineer doing a 20-minute QUICK backlog extraction. Same safety/formatting rules.

## User Input
MODE: {{MODE}}   # GITHUB_MARKDOWN | JIRA_CSV | BOTH

## Deliverables
1) Header + Epics overview (brief)
2) ~15 tickets (P0/P1/P2 mix) with file:line evidence + snippets; keep each concise
3) Quick Wins (≤1 day): 10 items
4) Top 3 PRs to open first (branch + commit message)
5) Guardrails checklist

Use the same ticket fields and CSV header if applicable.

## Process
<thinking>
- Quick repo scan priorities
- Focus areas based on typical risk patterns
</thinking>

<header>
Repo: {{REPO_NAME}}  |  Branch: {{BRANCH}}  |  Date: {{TODAY}}
Quick scan summary: P0=?, P1=?, P2=?
</header>

<epics>
Brief 1-line description per epic (5-7 total)
</epics>

<tickets>
~15 tickets following the standard template but more concise
</tickets>

<quick-wins>
10 items that can be fixed in ≤1 day
</quick-wins>

<top-prs>
1. branch-name: "commit message"
2. branch-name: "commit message"
3. branch-name: "commit message"
</top-prs>

<guardrails>
Checklist of linters/CI rules to add
</guardrails>

## Ticket Template (Concise Version)
```md
### {Title}
**Epic:** {Category}  ·  **Severity:** P{0|1|2}  ·  **Effort:** {S|M}

**Evidence:** `{file}:{line}`
```lang
{3-5 line snippet}
```

**Why:** {1 sentence}
**Fix:** {1-2 bullets}
**AC:** {2-3 testable outcomes}
**Test:** {main command}
```

## Quality Checks
- Each ticket has file:line + snippet
- AC is testable
- Duplicates merged
- P0s clearly marked
