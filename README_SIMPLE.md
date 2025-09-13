# SoftSensorAI - Simple AI Development Setup

AI-powered tools for your coding projects. No complicated directory structures, no assumptions - just simple setup.

## Quick Start

```bash
# 1. Clone and install tools
git clone https://github.com/Softsensor-org/SoftSensorAI.git
cd SoftSensorAI
chmod +x setup_simple.sh && ./setup_simple.sh

# 2. Add to PATH
export PATH="$(pwd)/bin:$PATH"

# 3. Set up any project
ssai setup
```

That's it!

## What This Does

### Step 1: Install Tools
- Installs development tools: `git`, `ripgrep`, `jq`, `gh` CLI
- Optionally installs AI CLIs: `claude`, `codex`, `gemini`, `grok`
- Creates basic AI configurations

### Step 2: Set Up Projects
- `ssai setup` - asks you where to clone/configure projects
- No hardcoded directory structures
- Works with existing repos or clones new ones

## Usage

```bash
ssai setup                           # Interactive project setup
ssai setup https://github.com/you/repo  # Clone specific repo
ssai review                          # AI code review (needs AI CLI)
ssai tickets                         # Generate tickets from code (needs AI CLI)
```

## Requirements

- `bash` 4.0+
- `git` 2.0+
- Internet connection

AI features work if you have AI CLIs installed, otherwise they're skipped.

## What Gets Created

When you run `ssai setup` on a project:

```
your-project/
├── CLAUDE.md              # Simple AI guidelines
└── .claude/
    └── settings.json      # Basic AI permissions
```

No complex directory structures. No assumptions about where you work.

## AI CLIs (Optional)

If you want AI features, install these separately:
- [Claude CLI](https://claude.ai) - Anthropic's Claude
- [Codex CLI](https://openai.com) - OpenAI's Codex
- [Gemini CLI](https://gemini.google.com) - Google's Gemini
- [Grok CLI](https://grok.com) - xAI's Grok

## That's All

Simple setup, simple usage, no surprises.