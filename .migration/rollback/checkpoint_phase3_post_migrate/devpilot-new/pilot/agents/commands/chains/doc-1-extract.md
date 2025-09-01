# Chain: Document Analysis - Step 1/3 - EXTRACT RISKS

You are executing step 1 of 3 for document/contract analysis.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
<contract>{PASTE_CONTRACT_OR_DOCUMENT_TEXT}</contract>
<topics>{SPECIFIC_TOPICS_TO_ANALYZE}</topics>
</input>

<goal>
Extract and list risks ONLY for the specified topics, with section references.
</goal>

<plan>
- Scan document for topic-related clauses
- Identify potential risks and concerns
- Note specific section/page references
- Categorize by severity (Critical/High/Medium/Low)
- Propose remediation for each risk
</plan>

<work>
1. Topic-focused extraction:
   - Search for keywords related to {topics}
   - Identify relevant sections
   - Extract exact quotes where applicable

2. Risk assessment per topic:
   - Legal exposure
   - Financial impact
   - Operational constraints
   - Compliance issues

3. Structure findings with references
</work>

<self_check>
- Have I covered all specified topics?
- Is each risk backed by a specific document reference?
- Are severity ratings justified?
- Are remediations actionable?
</self_check>

<review>
- [ ] All topics from input addressed
- [ ] Each risk has section reference
- [ ] Severity levels assigned
- [ ] Remediation suggested for each risk
- [ ] No out-of-scope analysis included
</review>

<handoff>
<risks>
| Topic | Issue | Risk | Impact | Section | Severity | Remediation |
|-------|-------|------|---------|---------|----------|-------------|
| {topic1} | {description} | {risk} | {impact} | §{ref} | {HIGH} | {suggestion} |
| {topic2} | {description} | {risk} | {impact} | §{ref} | {CRITICAL} | {suggestion} |

Summary:
- Critical risks: {count}
- High risks: {count}
- Medium risks: {count}
- Low risks: {count}
</risks>
</handoff>