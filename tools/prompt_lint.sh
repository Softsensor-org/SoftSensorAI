#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Lint a prompt file for required sections
set -euo pipefail
f="${1:-CLAUDE.md}"
[ -f "$f" ] || { echo "[miss] $f not found"; exit 2; }
need=("Role & Scope" "Tools" "Environment" "Loop" "Domain" "Safety" "Tone")
miss=0
for h in "${need[@]}"; do
  grep -qE "^[#]{1,3}\s*${h}\b" "$f" || { echo "[MISS] $h in $f"; miss=1; }
done
[ $miss -eq 0 ] && echo "[ok] $f sections present"
exit $miss
