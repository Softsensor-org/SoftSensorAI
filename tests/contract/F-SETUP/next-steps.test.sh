#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: ssai setup prints next-steps block

set -e

echo "Testing: ssai setup next-steps output"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Initialize as git repo
git init > /dev/null 2>&1

# Run ssai setup and capture output
OUTPUT=$(ssai setup 2>&1 || true)

ERRORS=0

# Check for next steps section
if ! echo "$OUTPUT" | grep -q "Next Steps"; then
    echo "❌ Missing 'Next Steps' section"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found 'Next Steps' section"
fi

# Check for SETUP COMPLETE banner
if ! echo "$OUTPUT" | grep -q "SETUP COMPLETE\|SETUP"; then
    echo "❌ Missing setup completion banner"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found setup banner"
fi

# Check for structured guidance (numbered steps or command examples)
if echo "$OUTPUT" | grep -E "(1\.|2\.|3\.)|ssai init|ssai palette" > /dev/null 2>&1; then
    echo "✅ Found structured guidance"
else
    echo "❌ Missing structured guidance"
    ERRORS=$((ERRORS + 1))
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All next-steps checks passed"
    exit 0
else
    echo "❌ $ERRORS next-steps checks failed"
    exit 1
fi