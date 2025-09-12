#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Build a compact context pack for prompts (tree, largest files, config snippets)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/artifacts/context_pack.txt}"
(
  cd "$ROOT" || exit 0
  echo "== tree (top 200) =="; git ls-files | head -n 200
  echo; echo "== largest files =="; (du -ah . | sort -hr | head -n 25) 2>/dev/null || true
  echo; echo "== json/yaml (top 40) =="; (find . -type f \( -name "*.json" -o -name "*.yml" -o -name "*.yaml" \) | head -n 40) 2>/dev/null || true
) > "$OUT"
echo "Wrote $OUT"
