#!/usr/bin/env bash
# Install and configure OpenAI Codex CLI
set -euo pipefail

echo "=== Installing OpenAI Codex CLI ==="
echo ""

# Check for Node.js
if ! command -v node >/dev/null 2>&1; then
  echo "❌ Node.js not found. Please install Node.js LTS first:"
  echo "   curl -fsSL https://fnm.vercel.app/install | bash"
  echo "   fnm use --install-if-missing lts/latest"
  exit 1
fi

# Install Codex globally
echo "==> Installing @openai/codex globally..."
npm i -g @openai/codex

# Verify installation
if ! command -v codex >/dev/null 2>&1; then
  echo "❌ Codex installation failed"
  exit 1
fi

echo "✓ Codex CLI installed: $(codex --version)"

# Create config directory
mkdir -p ~/.codex

# Create default config if it doesn't exist
if [ ! -f ~/.codex/config.yaml ]; then
  echo ""
  echo "==> Creating default Codex config..."
  cat > ~/.codex/config.yaml <<'YAML'
# OpenAI Codex CLI Configuration
model: o4-mini
approvalMode: auto-edit       # suggest | auto-edit | full-auto
notify: true

# Provider selection (uncomment to use alternative)
# provider: xai               # Use xAI instead of OpenAI
# provider: gemini            # Use Google Gemini
# provider: groq              # Use Groq
# provider: mistral           # Use Mistral
# provider: deepseek          # Use DeepSeek

# Custom endpoints (if needed)
# baseURL: https://api.x.ai/v1

# Sandbox settings (Linux/WSL)
# sandbox: docker             # Use Docker for sandboxing on Linux
YAML
  echo "✓ Created ~/.codex/config.yaml"
fi

# Check for API keys
echo ""
echo "==> Checking API keys..."
api_configured=0

if [ -n "${OPENAI_API_KEY:-}" ]; then
  echo "✓ OPENAI_API_KEY found"
  api_configured=1
fi

if [ -n "${XAI_API_KEY:-}" ]; then
  echo "✓ XAI_API_KEY found (for --provider xai)"
  api_configured=1
fi

if [ -n "${GEMINI_API_KEY:-}" ]; then
  echo "✓ GEMINI_API_KEY found (for --provider gemini)"
  api_configured=1
fi

if [ -n "${GROQ_API_KEY:-}" ]; then
  echo "✓ GROQ_API_KEY found (for --provider groq)"
  api_configured=1
fi

if [ $api_configured -eq 0 ]; then
  echo ""
  echo "⚠️  No API keys found. Set one of:"
  echo "   export OPENAI_API_KEY=sk-..."
  echo "   export XAI_API_KEY=grk-..."
  echo "   export GEMINI_API_KEY=..."
  echo "   export GROQ_API_KEY=..."
  echo ""
  echo "Add to ~/.bashrc or ~/.zshrc to persist."
fi

# Install Docker sandbox dependencies (Linux/WSL only)
if [[ "$OSTYPE" == "linux-gnu"* ]] || ([ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null); then
  echo ""
  echo "==> Setting up Linux/WSL sandbox support..."

  if command -v docker >/dev/null 2>&1; then
    echo "✓ Docker found - sandbox available"

    # Create sandbox wrapper if it doesn't exist
    if [ ! -f ~/bin/codex-sandbox ]; then
      mkdir -p ~/bin
      cat > ~/bin/codex-sandbox <<'SCRIPT'
#!/usr/bin/env bash
# Sandboxed Codex execution
set -euo pipefail

envs=()
[ -n "${OPENAI_API_KEY:-}" ] && envs+=(-e OPENAI_API_KEY)
[ -n "${XAI_API_KEY:-}" ] && envs+=(-e XAI_API_KEY -e XAI_BASE_URL=${XAI_BASE_URL:-https://api.x.ai/v1})
[ -n "${GROQ_API_KEY:-}" ] && envs+=(-e GROQ_API_KEY)
[ -n "${GEMINI_API_KEY:-}" ] && envs+=(-e GEMINI_API_KEY)

if [ ${#envs[@]} -eq 0 ]; then
  echo "Error: No API keys found"
  exit 1
fi

docker run --rm -it \
  -v "$PWD:/workspace" -w /workspace \
  "${envs[@]}" \
  node:20-bookworm bash -lc '
    npm -g i @openai/codex >/dev/null 2>&1 || true
    codex "$@"' -- "$@"
SCRIPT
      chmod +x ~/bin/codex-sandbox
      echo "✓ Created ~/bin/codex-sandbox wrapper"
    fi
  else
    echo "⚠️  Docker not found - sandbox unavailable"
    echo "   Install Docker for sandboxed execution"
  fi
fi

# Create example justfile recipes
if command -v just >/dev/null 2>&1; then
  echo ""
  echo "==> Example justfile recipes for Codex:"
  cat <<'JUST'

# Add these to your justfile:

# Fix linting and test failures
codex-fix:
    codex exec "lint, typecheck, unit tests; fix failures" --approval-mode auto-edit

# Refactor code for clarity
codex-refactor:
    codex exec "refactor for readability and performance" --approval-mode suggest

# Generate missing tests
codex-test:
    codex exec "add comprehensive tests for uncovered code" --approval-mode suggest

# Security audit and fixes
codex-security:
    codex exec "find and fix security vulnerabilities" --approval-mode suggest
JUST
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Quick start:"
echo "  codex                    # Interactive mode"
echo "  codex --help             # Show all options"
echo "  codex exec \"fix tests\"   # One-shot command"
echo ""

if [[ "$OSTYPE" == "linux-gnu"* ]] || ([ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null); then
  echo "For sandboxed execution (Linux/WSL):"
  echo "  ~/bin/codex-sandbox exec \"fix tests\""
  echo ""
fi

echo "Configuration: ~/.codex/config.yaml"
echo "Documentation: https://github.com/openai/codex"
