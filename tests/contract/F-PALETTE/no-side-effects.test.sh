#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: dp palette has no side effects when fzf missing

set -e

echo "Testing: dp palette side effects"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Create marker files
touch .marker_test
mkdir -p artifacts && touch artifacts/.marker_artifacts

# Temporarily hide fzf if it exists
FZF_PATH=$(which fzf 2>/dev/null || echo "")
if [ -n "$FZF_PATH" ]; then
    ORIG_PATH="$PATH"
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$(dirname $FZF_PATH)" | tr '\n' ':')
fi

# Get directory state before
FILES_BEFORE=$(find . -type f | sort)

# Run dp palette (should fail gracefully)
dp palette > /dev/null 2>&1 || true

# Get directory state after
FILES_AFTER=$(find . -type f | sort)

# Restore PATH if needed
[ -n "$FZF_PATH" ] && export PATH="$ORIG_PATH"

# Check for any new files
if [ "$FILES_BEFORE" != "$FILES_AFTER" ]; then
    echo "❌ Files were created/modified:"
    diff <(echo "$FILES_BEFORE") <(echo "$FILES_AFTER")
    cd - > /dev/null
    rm -rf "$TEST_DIR"
    exit 1
else
    echo "✅ No files created or modified"
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

echo "✅ No side effects detected"
exit 0