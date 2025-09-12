#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: dp init prints initialization summary

set -e

echo "Testing: dp init output contains required sections"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Run dp init and capture output
OUTPUT=$(dp init 2>&1 || true)

# Check for required sections
ERRORS=0

if ! echo "$OUTPUT" | grep -q "INITIALIZATION COMPLETE"; then
    echo "❌ Missing 'INITIALIZATION COMPLETE' banner"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found initialization banner"
fi

if ! echo "$OUTPUT" | grep -q "Environment"; then
    echo "❌ Missing 'Environment' section"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found environment section"
fi

if ! echo "$OUTPUT" | grep -q "Next Steps"; then
    echo "❌ Missing 'Next Steps' section"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found next steps section"
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All output checks passed"
    exit 0
else
    echo "❌ $ERRORS output checks failed"
    exit 1
fi