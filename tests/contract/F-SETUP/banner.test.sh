#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: ssai setup shows correct CLI name in banner

set -e

echo "Testing: ssai setup banner uses correct CLI name"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Initialize as git repo to enable setup
git init > /dev/null 2>&1

# Run ssai setup and capture output
OUTPUT=$(ssai setup 2>&1 || true)

ERRORS=0

# Check for correct CLI usage (should use 'ssai' not 'softsensorai')
if echo "$OUTPUT" | grep -q "ssai init\|ssai palette\|ssai review"; then
    echo "✅ Banner uses 'ssai' command"
else
    echo "❌ Banner not using 'ssai' command"
    ERRORS=$((ERRORS + 1))
fi

# Check that legacy names are not present
if echo "$OUTPUT" | grep -q "softsensorai init\|softsensorai setup\|softsensorai review"; then
    echo "❌ Banner contains legacy 'softsensorai' commands"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No legacy command names found"
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All banner checks passed"
    exit 0
else
    echo "❌ $ERRORS banner checks failed"
    exit 1
fi