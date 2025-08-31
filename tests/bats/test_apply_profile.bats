#!/usr/bin/env bats

setup() {
  set -euo pipefail
  TMPDIR=$(mktemp -d)
  REPO="$TMPDIR/repo"
  mkdir -p "$REPO"
  pushd "$REPO" >/dev/null
  git init -q
  # seed minimal repo files
  bash -lc "'$(pwd)/../../setup/agents_repo.sh' --force" || true
}

teardown() {
  popd >/dev/null
  rm -rf "$TMPDIR"
}

@test "apply_profile creates PROFILE.md and CI for beta" {
  run bash -lc "'$(pwd)/../../scripts/apply_profile.sh' --skill beginner --phase beta --teach-mode on"
  [ "$status" -eq 0 ]
  [ -f PROFILE.md ]
  [ -f .github/workflows/ci.yml ]
}

