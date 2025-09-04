# AI CLI Installation Guide

This guide provides standardized installation instructions for AI provider CLIs used by
SoftSensorAI.

## Required CLIs by Provider

SoftSensorAI's AI integration (`dp review`, `dp agent`) requires one of these CLI tools installed:

### Claude (Anthropic)

**Option 1: Anthropic CLI (Recommended)**

```bash
pip install anthropic
# or
pipx install anthropic
```

**Option 2: Claude CLI**

```bash
# Not officially available via npm/pip
# Check Anthropic's documentation for latest installation method
```

### OpenAI Codex

```bash
# Note: Codex is deprecated, use OpenAI API instead
pip install openai
# or
pipx install openai
```

### Google Gemini

**Option 1: Gemini CLI**

```bash
pip install google-generativeai
# or
pipx install google-generativeai
```

**Option 2: Vertex AI (GCP)**

```bash
gcloud components install vertex-ai
```

### xAI Grok

```bash
# Via pip (if available)
pip install grok-cli
# or
pipx install grok-cli

# Alternative: OpenRouter CLI for Grok models
pip install openrouter
```

## Verifying Installation

After installation, verify the CLI is available:

```bash
# Check which providers are available
command -v anthropic && echo "✓ Anthropic CLI installed"
command -v openai && echo "✓ OpenAI CLI installed"
command -v gemini && echo "✓ Gemini CLI installed"
command -v grok && echo "✓ Grok CLI installed"
```

## API Key Configuration

Each provider requires API key configuration:

```bash
# Anthropic
export ANTHROPIC_API_KEY="sk-ant-..."

# OpenAI
export OPENAI_API_KEY="sk-..."

# Google Gemini
export GOOGLE_API_KEY="..."

# xAI Grok
export GROK_API_KEY="..."
```

For persistent configuration, add to your shell profile or use SoftSensorAI's secure key storage:

```bash
# Store keys securely with SoftSensorAI
./utils/secure_keys.sh store
```

## Testing Your Setup

Test the AI integration:

```bash
# Test with a simple review
echo "def add(a, b): return a + b" > test.py
dp review test.py

# Test agent functionality
dp agent new --goal "Add type hints to test.py"
```

## Troubleshooting

### Command Not Found

If CLIs aren't found after installation:

1. **Check PATH**: Ensure pip/pipx bin directory is in PATH

   ```bash
   echo $PATH | grep -E "\.local/bin|/usr/local/bin"
   ```

2. **Restart Shell**: Source your profile or start a new terminal

   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

3. **Use Full Path**: Find and use the full path
   ```bash
   find ~/.local/bin /usr/local/bin -name "anthropic" 2>/dev/null
   ```

### API Key Issues

1. **Verify Key Set**: Check environment variable

   ```bash
   echo ${ANTHROPIC_API_KEY:0:10}...  # Shows first 10 chars
   ```

2. **Test Direct CLI**: Bypass SoftSensorAI to test CLI directly
   ```bash
   echo "Hello" | anthropic messages create --model claude-3-sonnet-20240229
   ```

### Model Access

Some models require specific access levels:

- Claude Opus: Requires Anthropic Pro API access
- GPT-4: Requires OpenAI paid tier
- Gemini Ultra: Requires Google AI Studio access

## See Also

- [AI Frameworks](./AI_FRAMEWORKS.md) - Detailed provider comparison
- [Multi-User Setup](./MULTI_USER_SETUP.md) - Shared server installations
- [Troubleshooting](./TROUBLESHOOTING.md) - General troubleshooting guide
