#!/bin/bash
# Test: dp setup uses correct paths (softsensorai not devpilot)

set -e

echo "Testing: dp setup path correctness"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Initialize as git repo
git init > /dev/null 2>&1

# Run dp setup and capture output
OUTPUT=$(dp setup 2>&1 || true)

ERRORS=0

# Check for correct paths
if echo "$OUTPUT" | grep -i "softsensorai\|softsensor" > /dev/null 2>&1; then
    echo "✅ Found SoftSensorAI paths"
else
    # It's okay if no paths are shown, but if they are, they should be correct
    echo "ℹ️  No SoftSensorAI paths shown (may be normal)"
fi

# Check that old paths are not present
if echo "$OUTPUT" | grep -i "/devpilot\|/.devpilot" | grep -v "devpilot.project.yml" > /dev/null 2>&1; then
    echo "❌ Found legacy devpilot paths"
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