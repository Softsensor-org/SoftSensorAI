# Developer Checklist for Claude Integration

Quick reference to avoid common errors when working with Claude APIs.

## Tool Use Requirements (Avoid 400 Errors)

### ✅ Correct Tool Response Format
After a tool call, return **ONE** user message with:
1. **All** `tool_result` blocks **FIRST**
2. Each `tool_result` must have the exact `tool_use_id`
3. Any text commentary **AFTER** all results

```xml
<!-- CORRECT -->
<tool_result tool_use_id="abc123">...</tool_result>
<tool_result tool_use_id="def456">...</tool_result>
Your text here

<!-- WRONG - will 400 -->
<tool_result tool_use_id="abc123">...</tool_result>
Some text
<tool_result tool_use_id="def456">...</tool_result>
```

### ✅ Parallel Tool Calls
```python
# GOOD - parallel execution
messages = [{
    "role": "assistant",
    "content": [
        {"type": "tool_use", "id": "1", "name": "read_file", "input": {"path": "a.txt"}},
        {"type": "tool_use", "id": "2", "name": "read_file", "input": {"path": "b.txt"}},
        {"type": "tool_use", "id": "3", "name": "grep", "input": {"pattern": "error"}}
    ]
}]

# For stateful operations, disable parallelism
"disable_parallel_tool_use": true  # DB migrations, rate-limited APIs
```

### ✅ Tool Choice Options
- `tool_choice: "auto"` - Let Claude decide (default)
- `tool_choice: "any"` - Force Claude to use a tool
- `tool_choice: {"type": "tool", "name": "specific_tool"}` - Force specific tool

**Note**: For CoT + specific tool, keep `tool_choice: "auto"` and request the tool in the prompt.

## Formatting Best Practices

### ✅ Match Prompt Style
```python
# If prompt uses bullets, respond with bullets
# If prompt uses JSON, return valid JSON only
# If prompt uses tables, format as table
```

### ✅ Use XML Tags for Structure
```xml
<thinking>Brief reasoning here</thinking>
<answer>Final response</answer>

<plan>Step-by-step plan</plan>
<diff>Code changes</diff>
<verify>Verification steps</verify>
```

## Chain of Thought (CoT) by Skill Level

| Skill Level | Default CoT | When to Use |
|------------|-------------|-------------|
| vibe/beginner | cot-structured | Always - verbose teaching |
| l1/l2 | cot-lite | Complex tasks - 5 bullets max |
| expert | none | Only when explicitly requested |

## Performance Tips

### ✅ Batch Operations
```bash
# GOOD - single MultiEdit call
multiedit file.js with 5 changes

# BAD - 5 separate Edit calls
edit file.js change1
edit file.js change2
...
```

### ✅ Search Before Read
```bash
# GOOD - narrow down first
grep -l "pattern" **/*.js
read specific_file.js

# BAD - read everything
read *.js  # Too broad
```

### ✅ Clean Up Temp Files
```bash
# Always clean up after temp file usage
rm -f /tmp/temp_* 2>/dev/null
```

## Common Gotchas

1. **Never mix text between tool_result blocks** - causes 400 error
2. **Each tool_result needs exact tool_use_id** - mismatch causes 400
3. **Clean up temp files** - Claude 4 best practice
4. **Use MultiEdit for multiple changes** - more efficient
5. **Grep/Glob before Read** - reduces context usage

## Quick Commands

```bash
# Apply a profile
scripts/apply_profile.sh --skill l1 --phase mvp

# Check graduation readiness
scripts/graduate.sh ready

# Show current profile
scripts/profile_show.sh
```

## References
- [Claude 4 Best Practices](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Tool Implementation](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use)
- [Chain of Thought](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/chain-of-thought)