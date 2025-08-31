#!/usr/bin/env bats

setup() {
  set -euo pipefail
  TMPDIR=$(mktemp -d)
  REPO="$TMPDIR/repo"
  mkdir -p "$REPO"
  pushd "$REPO" >/dev/null
  git init -q
}

teardown() {
  popd >/dev/null
  rm -rf "$TMPDIR"
}

@test "seeder creates core files idempotently" {
  run bash -lc "'$(pwd)/../../setup_agents_repo.sh' --force"
  [ "$status" -eq 0 ]
  [ -f CLAUDE.md ]
  [ -f AGENTS.md ]
  [ -f .claude/settings.json ]
  [ -d .claude/commands ]

  # run again (idempotent)
  run bash -lc "'$(pwd)/../../setup_agents_repo.sh'"
  [ "$status" -eq 0 ]
}

