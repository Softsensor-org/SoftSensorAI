#!/usr/bin/env bash
set -euo pipefail
source .migration/scripts/logger.sh

TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
  local name="$1"; shift
  local fn="$1"; shift || true
  ((TESTS_TOTAL++))
  if "$fn" "$@" >/dev/null 2>&1; then
    echo "✅ PASS - $name"
    ((TESTS_PASSED++))
  else
    echo "❌ FAIL - $name"
    ((TESTS_FAILED++))
    return 1
  fi
}

test_new_structure_syntax() {
  local ok=0
  while IFS= read -r -d '' f; do
    bash -n "$f" || ok=1
  done < <(find devpilot-new -type f -name '*.sh' -print0)
  return $ok
}

test_main_help() {
  ./devpilot-new/devpilot help | grep -q "DevPilot"
}

test_json_validity() {
  local ok=0
  command -v jq >/dev/null 2>&1 || return 0
  while IFS= read -r -d '' f; do
    jq empty "$f" || ok=1
  done < <(find devpilot-new -type f -name '*.json' -print0)
  return $ok
}

summary() {
  echo ""; echo "Tests: $TESTS_PASSED / $TESTS_TOTAL passed"
  [[ $TESTS_FAILED -eq 0 ]]
}

main() {
  run_test "New structure scripts parse" test_new_structure_syntax || true
  run_test "DevPilot help shows" test_main_help || true
  run_test "JSON files valid" test_json_validity || true
  summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

