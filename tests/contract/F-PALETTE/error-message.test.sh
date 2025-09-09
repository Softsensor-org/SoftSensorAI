#!/bin/bash
# Test: dp palette prints actionable install hints

set -e

echo "Testing: dp palette error message quality"

# Temporarily hide fzf if it exists
FZF_PATH=$(which fzf 2>/dev/null || echo "")
if [ -n "$FZF_PATH" ]; then
    ORIG_PATH="$PATH"
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$(dirname $FZF_PATH)" | tr '\n' ':')
fi

# Run dp palette and capture output
OUTPUT=$(dp palette 2>&1 || true)

ERRORS=0

# Check for installation instructions
if ! echo "$OUTPUT" | grep -q "brew install fzf"; then
    echo "❌ Missing macOS installation command"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found macOS installation hint"
fi

if ! echo "$OUTPUT" | grep -q "apt install fzf"; then
    echo "❌ Missing Ubuntu/Debian installation command"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found Ubuntu/Debian installation hint"
fi

if ! echo "$OUTPUT" | grep -q "just commands"; then
    echo "❌ Missing alternative command suggestion"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found alternative suggestion"
fi

# Restore PATH if needed
[ -n "$FZF_PATH" ] && export PATH="$ORIG_PATH"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All error message checks passed"
    exit 0
else
    echo "❌ $ERRORS error message checks failed"
    exit 1
fi