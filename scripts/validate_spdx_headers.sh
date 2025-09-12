#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Validate that all source files have proper SPDX license headers

set -euo pipefail

EXIT_CODE=0
EXPECTED_SPDX="GPL-3.0-only"

echo "🔍 Validating SPDX headers in source files..."

# Find all source files
while IFS= read -r -d '' file; do
    if ! grep -q "SPDX-License-Identifier: $EXPECTED_SPDX" "$file"; then
        echo "❌ Missing or incorrect SPDX header in: $file"
        EXIT_CODE=1
    fi
done < <(find . -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" | grep -v node_modules | tr '\n' '\0')

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All source files have correct SPDX headers ($EXPECTED_SPDX)"
else
    echo ""
    echo "💡 To add SPDX headers to files missing them, run:"
    echo "   find . -name '*.sh' -o -name '*.py' -o -name '*.js' -o -name '*.ts' | grep -v node_modules | while read file; do"
    echo "     if ! grep -q 'SPDX-License-Identifier' \"\$file\"; then"
    echo "       case \"\$file\" in"
    echo "         *.sh|*.py) sed -i '1a# SPDX-License-Identifier: GPL-3.0-only' \"\$file\" ;;"
    echo "         *.js|*.ts) sed -i '1a// SPDX-License-Identifier: GPL-3.0-only' \"\$file\" ;;"
    echo "       esac"
    echo "     fi"
    echo "   done"
fi

exit $EXIT_CODE