# Chain: Document Analysis - Step 3/3 - TONE REVIEW

You are executing step 3 of 3 for document/contract analysis.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_EMAIL_FROM_STEP_2}
</input>

<goal>
Critique tone, clarity, and professionalism of the email; suggest specific edits if needed.
</goal>

<plan>
- Assess overall tone (confrontational vs collaborative)
- Check clarity of each point
- Verify professionalism throughout
- Identify any potential relationship risks
- Suggest specific line-by-line improvements
</plan>

<work>
Review dimensions:

1. **Tone Analysis**:
   - Assertiveness level (1-10)
   - Collaboration indicators
   - Potential trigger phrases
   - Power dynamics

2. **Clarity Check**:
   - Ambiguous statements
   - Technical jargon
   - Action items clarity
   - Timeline specificity

3. **Professionalism Audit**:
   - Business language appropriateness
   - Emotional neutrality
   - Respect indicators
   - Cultural sensitivity

4. **Effectiveness Assessment**:
   - Will this achieve the goal?
   - Are asks reasonable?
   - Is escalation path clear?
</work>

<self_check>
- Am I being overly critical or not critical enough?
- Are my suggestions actually improvements?
- Have I considered the relationship context?
</self_check>

<review>
- [ ] Tone assessment complete
- [ ] Clarity issues identified
- [ ] Professionalism verified
- [ ] Specific edits provided where needed
- [ ] Overall recommendation given
</review>

<handoff>
<feedback>
## Tone Review Summary

**Overall Assessment**: {Appropriate/Needs Adjustment}
- Assertiveness: {X}/10 (target: 6-7)
- Collaboration: {X}/10 (target: 7-8)
- Professionalism: {X}/10 (target: 9-10)

## Strengths
- {What works well}
- {Positive aspects to keep}

## Areas for Improvement

### Critical Edits (Must Change)
1. **Line X**: 
   - Current: "{problematic text}"
   - Issue: {Too aggressive/unclear/unprofessional}
   - Suggested: "{improved text}"

### Recommended Edits (Should Change)
1. **Paragraph Y**:
   - Issue: {Lacks clarity on timeline}
   - Suggested: Add specific dates

### Optional Enhancements
1. {Minor improvements for polish}

## Relationship Risk Assessment
- Current draft risk: {Low/Medium/High}
- After edits risk: {Low}
- Rationale: {explanation}

## Final Recommendation
{SEND AS-IS | APPLY CRITICAL EDITS | SIGNIFICANT REVISION NEEDED}

Reasoning: {brief explanation}
</feedback>
</handoff>