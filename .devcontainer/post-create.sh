#!/usr/bin/env bash
set -euo pipefail

echo "==> Post-create: ensuring tools"
if command -v direnv >/dev/null 2>&1; then
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc || true
fi
echo "✓ Done"
