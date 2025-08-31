#!/usr/bin/env bats

setup() {
  set -euo pipefail
  TMPROOT=$(mktemp -d)
  export HOME="$TMPROOT/home"
  mkdir -p "$HOME/projects/acme/app"
}

teardown() {
  rm -rf "$TMPROOT"
}

@test "validate_agents flags missing files" {
  run bash -lc "cd setup-scripts && ./validate_agents.sh '$HOME/projects'"
  [ "$status" -ne 0 ]
}

