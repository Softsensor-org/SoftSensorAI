#!/usr/bin/env bats

setup() {
  set -euo pipefail
  TMPROOT=$(mktemp -d)
  export HOME="$TMPROOT/home"
  mkdir -p "$HOME" "$TMPROOT/bin"
  export PATH="$TMPROOT/bin:$PATH"
  # stub gh and jq if missing
  cat > "$TMPROOT/bin/gh" <<'SH'
#!/usr/bin/env bash
exit 0
SH
  chmod +x "$TMPROOT/bin/gh"
  if ! command -v jq >/dev/null 2>&1; then
    cat > "$TMPROOT/bin/jq" <<'SH'
#!/usr/bin/env bash
cat  # naive stub
SH
    chmod +x "$TMPROOT/bin/jq"
  fi

  # create local origin with one commit
  SRC="$TMPROOT/src"; ORIGIN="$TMPROOT/origin.git"
  mkdir -p "$SRC"
  pushd "$SRC" >/dev/null
  git init -q
  echo "hello" > README.md
  git add README.md
  git -c user.email=t@t -c user.name=t commit -q -m init
  git init --bare "$ORIGIN" >/dev/null
  git remote add origin "$ORIGIN"
  git push -q origin HEAD:main
  popd >/dev/null
}

teardown() {
  rm -rf "$TMPROOT"
}

@test "wizard clones local repo and applies profile non-interactively" {
  run bash -lc "./repo_setup_wizard.sh --non-interactive --org acme --category backend --url '$ORIGIN' --branch main --name app --lite --no-bootstrap --no-hooks --skill beginner --phase mvp --teach-mode on"
  [ "$status" -eq 0 ]
  TARGET="$HOME/projects/acme/backend/app"
  [ -d "$TARGET/.claude/commands" ]
  [ -f "$TARGET/CLAUDE.md" ]
  [ -f "$TARGET/PROFILE.md" ]
}

