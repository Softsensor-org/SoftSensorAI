# Extended Thinking (controlled)
Use this only if the task is complex or ambiguous. Keep it tight.

<thinking>
- List ≤ {{THINK_BUDGET_BULLETS|7}} key uncertainties, edge cases, risks.
- Compare 2–3 options; pick 1 with rationale (one-liner).
- Note success metrics / acceptance checks you'll prove.
</thinking>

<answer>
Now execute the Plan→Code→Test loop with minimal diffs. Show the unified diff and the exact commands run.
</answer>

Rules:
- If EXTENDED_THINKING=off, skip <thinking> and proceed.
- Never include secrets; remove any temp files you create.
