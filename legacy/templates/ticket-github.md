### {Title}
**Epic:** {Security|Reliability|Performance|Code Quality|DevEx|Docs|ML/Privacy}  
**Area:** {paths/services}  
**Severity:** P{0|1|2|3}  ·  **Priority:** {High|Medium|Low — why}  ·  **Effort:** {S|M|L}

**Evidence (file:line):** `{path}:{line}`
```{language}
{3–8 lines of code/config excerpt}
```

**Why it matters**
{1–3 sentences on risk/cost/benefit}

**Suggested fix**
{specific steps OR short safe diff}

**Acceptance Criteria**
* [ ] {observable outcome with threshold/flag/log/metric}
* [ ] {security gate or performance threshold}
* [ ] {test coverage or documentation requirement}

**Test plan**
* Unit: `{command}` with fixtures in `{path}`
* Integration/E2E: `{command}` (include negative tests)
* Perf/Security scans: `{command}` with expected bounds

**Dependencies/Blocks:** {IDs or files}
**Labels:** {area/…, type/…, good-first-issue?}
**Milestone/Sprint:** {e.g., Hardening Sprint 1}
**Owner hint:** {team or TBD}
**Links:** [{description}]({repo-relative-path})