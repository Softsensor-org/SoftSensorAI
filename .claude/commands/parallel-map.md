# Parallel Map → Reduce
- Emit one assistant message with multiple <tool_use> blocks (one per item).
- After tools run, return a **single** user message containing **all** <tool_result> blocks **first**, then text.
- Merge/dedupe/summarize into <summary>…</summary>. If operations are stateful, disable parallel tool use.
