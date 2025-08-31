# Chain: Document Analysis - Step 2/3 - WRITE EMAIL

You are executing step 2 of 3 for document/contract analysis.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_RISKS_FROM_STEP_1}
</input>

<goal>
Write a professional vendor email using "Current / Concern / Proposed Change" format for each risk.
</goal>

<plan>
- Structure email with proper business greeting
- Present each risk in three-part format
- Maintain professional but firm tone
- Include clear call to action
- Add appropriate signature block
</plan>

<work>
Email structure:
1. Subject line: Clear and action-oriented
2. Greeting: Professional salutation
3. Opening: Context and purpose
4. Body: Each risk in structured format
5. Closing: Next steps and timeline
6. Signature: Contact information
</work>

<review>
- [ ] All risks from input included
- [ ] Each risk follows Current/Concern/Proposed format
- [ ] Tone is professional and constructive
- [ ] Call to action is clear
- [ ] No technical jargon without explanation
</review>

<handoff>
<email>
Subject: Contract Review - Required Amendments for {CONTRACT_NAME}

Dear {Vendor Contact},

Following our review of the proposed {agreement type} dated {date}, we have identified several areas requiring amendment before we can proceed to signature.

Please find below our specific concerns and proposed changes:

**1. {Risk Topic 1}**
- **Current Language**: "{quote from contract}"
- **Our Concern**: {specific business/legal concern}
- **Proposed Change**: {specific amendment text or requirement}

**2. {Risk Topic 2}**
- **Current Language**: "{quote from contract}"
- **Our Concern**: {specific business/legal concern}
- **Proposed Change**: {specific amendment text or requirement}

[Additional items as needed]

We believe these amendments are necessary to ensure a mutually beneficial partnership while protecting both parties' interests. We are confident we can reach an agreement that addresses these concerns.

Please review these items and provide your response by {date}. We are available for a discussion on {proposed meeting dates} if you would like to review these points in detail.

Thank you for your attention to these matters.

Best regards,

{Your Name}
{Title}
{Company}
{Contact Information}

cc: {Legal Team / Procurement / Other Stakeholders}
</email>
</handoff>