#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: dp palette checks for fzf availability

set -e

echo "Testing: dp palette fzf detection"

# Temporarily hide fzf if it exists
FZF_PATH=$(which fzf 2>/dev/null || echo "")
if [ -n "$FZF_PATH" ]; then
    # Save original PATH
    ORIG_PATH="$PATH"
    # Remove fzf from PATH
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$(dirname $FZF_PATH)" | tr '\n' ':')
fi

# Run dp palette and capture output
OUTPUT=$(dp palette 2>&1 || true)

# Check for fzf detection message
if echo "$OUTPUT" | grep -q "fzf not found"; then
    echo "✅ Correctly detected missing fzf"
else
    echo "❌ Did not detect missing fzf"
    # Restore PATH if needed
    [ -n "$FZF_PATH" ] && export PATH="$ORIG_PATH"
    exit 1
fi

# Restore PATH if needed
[ -n "$FZF_PATH" ] && export PATH="$ORIG_PATH"

echo "✅ fzf detection test passed"
exit 0