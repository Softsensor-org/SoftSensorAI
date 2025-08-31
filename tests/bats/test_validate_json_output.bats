#!/usr/bin/env bats

setup() {
  set -euo pipefail
  TMPROOT=$(mktemp -d)
  export HOME="$TMPROOT/home"
  mkdir -p "$HOME/projects"
}

teardown() {
  rm -rf "$TMPROOT"
}

@test "validate_agents --json returns machine-readable JSON" {
  run bash -lc "cd setup-scripts && ./validation/validate_agents.sh --json '$HOME/projects' | jq -e type"
  [ "$status" -eq 0 ]
}

