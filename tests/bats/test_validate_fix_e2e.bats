#!/usr/bin/env bats

setup() {
  set -euo pipefail
  TMPROOT=$(mktemp -d)
  export HOME="$TMPROOT/home"
  mkdir -p "$HOME/projects/acme/app"
  pushd "$HOME/projects/acme/app" >/dev/null
  git init -q
}

teardown() {
  popd >/dev/null
  rm -rf "$TMPROOT"
}

@test "validate_agents --fix seeds missing files and passes afterwards" {
  # First run should fail with missing files
  run bash -lc "cd setup-scripts && ./validate_agents.sh '$HOME/projects'"
  [ "$status" -ne 0 ]

  # Now run with --fix to seed files
  run bash -lc "cd setup-scripts && ./validate_agents.sh --fix '$HOME/projects'"
  # May still be nonzero if JSON invalid, but required files should exist now
  [ -f "$HOME/projects/acme/app/CLAUDE.md" ]
  [ -f "$HOME/projects/acme/app/AGENTS.md" ]
  [ -f "$HOME/projects/acme/app/.claude/settings.json" ]

  # Re-run plain validation should pass
  run bash -lc "cd setup-scripts && ./validate_agents.sh '$HOME/projects'"
  [ "$status" -eq 0 ]
}

