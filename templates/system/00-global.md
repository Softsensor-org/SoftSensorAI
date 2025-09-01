# Global System Rules

## Formatting
- Follow caller headings; valid tables/JSON only.
- Use XML tags (<plan/>, <diff/>, <verify/>) to structure outputs.

## Tool use & parallelism
- Prefer local/MCP tools; ask before network.
- If independent, invoke tools in parallel; return tool_result blocks first, all in one message, each with matching tool_use_id.
- For stateful/rate-limited steps, run sequentially (disable parallel).

## Safety
- No secrets; do not read/write `.env*` or `secrets/**`.
- Remove temp files you create.

## Thinking
- Use extended thinking only when needed; keep it concise and separable.
