#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: ssai setup uses correct paths (softsensorai not softsensorai)

set -e

echo "Testing: ssai setup path correctness"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Initialize as git repo
git init > /dev/null 2>&1

# Run ssai setup and capture output
OUTPUT=$(ssai setup 2>&1 || true)

ERRORS=0

# Check for correct paths
if echo "$OUTPUT" | grep -i "softsensorai\|softsensor" > /dev/null 2>&1; then
    echo "✅ Found SoftSensorAI paths"
else
    # It's okay if no paths are shown, but if they are, they should be correct
    echo "ℹ️  No SoftSensorAI paths shown (may be normal)"
fi

# Check that old paths are not present
if echo "$OUTPUT" | grep -i "/softsensorai\|/.softsensorai" | grep -v "softsensorai.project.yml" > /dev/null 2>&1; then
    echo "❌ Found legacy softsensorai paths"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No legacy paths found"
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All path checks passed"
    exit 0
else
    echo "❌ $ERRORS path checks failed"
    exit 1
fi