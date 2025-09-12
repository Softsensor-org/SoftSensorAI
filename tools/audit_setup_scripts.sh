#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Lints shell scripts, validates JSON/YAML, checks shebangs/CRLF/exec bits, and basic idempotency hints.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

echo "== finding shell scripts =="
mapfile -t SH < <(git ls-files 2>/dev/null | grep -E '\\.sh$|/bin/|/scripts/' || true)
if [ ${#SH[@]} -eq 0 ]; then
  mapfile -t SH < <(find . -type f \( -name "*.sh" -o -path "*/bin/*" -o -path "*/scripts/*" \) -not -path "./.venv/*" -not -path "./node_modules/*" -not -path "./.git/*" -print | sort)
fi
printf "%s\n" "${SH[@]}" | sed 's/^/ - /' || true

echo "== check executables have shebang =="
rc=0
for f in "${SH[@]}"; do
  if [ -x "$f" ] && ! head -n1 "$f" | grep -qE '^#!'; then
    echo "[shebang] missing: $f"; rc=1
  fi
done

echo "== normalize CRLF (dry run) =="
for f in "${SH[@]}"; do
  if file "$f" | grep -qi 'CRLF'; then
    echo "[crlf] $f has CRLF line endings"
  fi
done

echo "== shell syntax check =="
fail=0
for f in "${SH[@]}"; do
  bash -n "$f" || { echo "[syntax] $f"; fail=1; }
done
[ $fail -eq 0 ] && echo "  ✓ bash -n clean" || true

echo "== shellcheck =="
if command -v shellcheck >/dev/null; then
  # Filter out legacy files from shellcheck
  NON_LEGACY_SH=()
  for f in "${SH[@]}"; do
    if [[ "$f" != legacy/* ]]; then
      NON_LEGACY_SH+=("$f")
    fi
  done
  if [ ${#NON_LEGACY_SH[@]} -gt 0 ]; then
    # Only fail on errors (severity 3), not warnings or info
    shellcheck -S error -f tty "${NON_LEGACY_SH[@]}" || rc=1
  fi
else
  echo "  (install shellcheck to get full lint)"
fi

echo "== JSON validity =="
mapfile -t JSONS < <(git ls-files 2>/dev/null | grep -E '\\.json$|(^|/)\\.mcp\\.json$|(^|/)\\.claude/settings\\.json$' || true)
if [ ${#JSONS[@]} -eq 0 ]; then
  mapfile -t JSONS < <(find . -type f -name "*.json" -print)
fi
for f in "${JSONS[@]}"; do
  jq -e type "$f" >/dev/null || { echo "[json] invalid: $f"; rc=1; }
done

echo "== YAML validity =="
if command -v yamllint >/dev/null; then
  mapfile -t YMLS < <(git ls-files | grep -E '\\.ya?ml$' || true)
  [ ${#YMLS[@]} -gt 0 ] && yamllint -s "${YMLS[@]}" || true
else
  echo "  (install yamllint for full YAML checks)"
fi

echo "== check required files exist =="
req=( "setup/agents_global.sh" "setup/agents_repo.sh" "setup/repo_wizard.sh" )
missing=0; for f in "${req[@]}"; do [ -f "$f" ] || { echo "[missing] $f"; missing=1; }; done

echo "== quick grep for strict mode and idempotency =="
grep -RIn --color=never -E 'set -euo pipefail' "${SH[@]}" || echo "add 'set -euo pipefail' to all scripts"

echo "== executable bits for required scripts =="
for f in "${req[@]}"; do
  [ -x "$f" ] || echo "[chmod] make executable: $f"
done

echo "== summary =="
[ $missing -eq 0 ] || rc=1
[ $rc -eq 0 ] && echo "OK" || echo "Issues found (see above)"; exit $rc
