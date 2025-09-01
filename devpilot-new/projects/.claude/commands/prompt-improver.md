# Prompt Improver

<input>
{{RAW_PROMPT}}
</input>

Rewrite into a production-grade prompt with:
- System/User separation
- Variables as {{LIKE_THIS}}, with a "Variables" block listing defaults
- Output spec with headings/tables/JSON as appropriate
- Guardrails (no secrets, minimal diffs, exact commands)
- A "Test run" example with sample values (one-liner each)

Emit:
<improved_prompt>…final prompt text…</improved_prompt>
<variables>
- NAME: default + notes
</variables>
<why>1–3 bullets: what changed and why</why>

