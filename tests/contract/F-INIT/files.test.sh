#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: dp init creates or updates system/active.md

set -e

echo "Testing: dp init creates system/active.md"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Run dp init
dp init > /dev/null 2>&1 || true

# Check if system/active.md was created
if [ -f "system/active.md" ]; then
    echo "✅ system/active.md created"
    
    # Check if file has content
    if [ -s "system/active.md" ]; then
        echo "✅ system/active.md has content"
    else
        echo "❌ system/active.md is empty"
        cd - > /dev/null
        rm -rf "$TEST_DIR"
        exit 1
    fi
else
    echo "❌ system/active.md not created"
    cd - > /dev/null
    rm -rf "$TEST_DIR"
    exit 1
fi

# Check if artifacts directory was created
if [ -d "artifacts" ]; then
    echo "✅ artifacts/ directory created"
else
    echo "❌ artifacts/ directory not created"
    cd - > /dev/null
    rm -rf "$TEST_DIR"
    exit 1
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

echo "✅ All file checks passed"
exit 0