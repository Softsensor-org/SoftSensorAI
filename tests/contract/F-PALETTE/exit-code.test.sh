#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: ssai palette exits with non-zero code when fzf missing

set -e

echo "Testing: ssai palette exit code"

# Temporarily hide fzf if it exists
FZF_PATH=$(which fzf 2>/dev/null || echo "")
if [ -n "$FZF_PATH" ]; then
    ORIG_PATH="$PATH"
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$(dirname $FZF_PATH)" | tr '\n' ':')
fi

# Run ssai palette and capture exit code
ssai palette > /dev/null 2>&1
EXIT_CODE=$?

# Restore PATH if needed
[ -n "$FZF_PATH" ] && export PATH="$ORIG_PATH"

# Check exit code
if [ $EXIT_CODE -eq 1 ]; then
    echo "✅ Correct exit code (1) when fzf missing"
    exit 0
else
    echo "❌ Wrong exit code: $EXIT_CODE (expected 1)"
    exit 1
fi