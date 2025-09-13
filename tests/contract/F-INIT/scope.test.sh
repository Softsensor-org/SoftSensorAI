#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Test: ssai init does not write outside system/ and artifacts/

set -e

echo "Testing: ssai init scope constraints"

# Create temp directory for test
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Create marker files to detect unwanted writes
touch .marker_root
mkdir -p src && touch src/.marker_src
mkdir -p bin && touch bin/.marker_bin

# Run ssai init
ssai init > /dev/null 2>&1 || true

# Check that markers are untouched
ERRORS=0

if [ ! -f ".marker_root" ]; then
    echo "❌ Root marker file was modified"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Root directory untouched"
fi

if [ ! -f "src/.marker_src" ]; then
    echo "❌ src/ marker file was modified"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ src/ directory untouched"
fi

if [ ! -f "bin/.marker_bin" ]; then
    echo "❌ bin/ marker file was modified"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ bin/ directory untouched"
fi

# Verify only expected directories were created
CREATED_DIRS=$(find . -type d -name ".marker_*" -prune -o -type d -print | grep -v "^\.$" | sort)
ALLOWED_DIRS="./artifacts
./system"

for dir in $CREATED_DIRS; do
    if ! echo "$ALLOWED_DIRS" | grep -q "$dir"; then
        echo "❌ Unexpected directory created: $dir"
        ERRORS=$((ERRORS + 1))
    fi
done

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All scope checks passed"
    exit 0
else
    echo "❌ $ERRORS scope violations found"
    exit 1
fi