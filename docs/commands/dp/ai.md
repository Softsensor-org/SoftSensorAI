# dp ai

Unified AI CLI interface for interacting with various AI providers.

## Usage

```bash
dp ai --provider <provider> --model <model> --prompt-file <file>
```

## Providers

- `claude` - Anthropic Claude
- `codex` - OpenAI Codex (deprecated, use OpenAI)
- `gemini` - Google Gemini
- `grok` - xAI Grok

## Examples

```bash
# Use Claude for a task
dp ai --provider claude --model claude-3-sonnet --prompt-file prompt.txt

# Use Gemini
dp ai --provider gemini --model gemini-pro --prompt-file prompt.txt
```

## Environment Variables

- `AI_MODEL_CLAUDE` - Default Claude model
- `AI_MODEL_GEMINI` - Default Gemini model
- `AI_MODEL_GROK` - Default Grok model
- `TIMEOUT_SECS` - Request timeout (default: 180)

## Notes

This command provides a unified interface to multiple AI providers through the `ai_shim.sh` tool.