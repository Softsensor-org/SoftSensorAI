# Long-Context Map→Reduce

<input>
{{BIG_CONTEXT_OR_PATH_LIST}}
</input>

Plan
- Split input into logical chunks (modules/files/sections). Emit an ID + title for each.
- MAP: For each chunk, produce a <note id="..."> with key facts, risks, and citations (file:line).
- REDUCE: Merge notes: dedupe, rank by severity/impact, produce a <summary> with:
  - Top risks/opportunities (bullets with citations)
  - Open questions (what info would materially change the answer)
  - Next actions (commands/PRs)

Output order
<notes> ...multiple <note id="X">…</note> … </notes>
<summary> …merged view… </summary>

