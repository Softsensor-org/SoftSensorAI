#!/usr/bin/env bats

setup() {
  set -euo pipefail
  TMPDIR=$(mktemp -d)
  REPO="$TMPDIR/repo"
  mkdir -p "$REPO/.claude"
  pushd "$REPO" >/dev/null
  git init -q
}

teardown() {
  popd >/dev/null
  rm -rf "$TMPDIR"
}

@test "config validation fails on bad settings.json" {
  echo '{"not_permissions":{}}' > .claude/settings.json
  run bash -lc "bash ../tools/config_validate.sh"
  [ "$status" -ne 0 ]
}

