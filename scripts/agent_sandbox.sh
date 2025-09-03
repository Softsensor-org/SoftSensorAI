#!/usr/bin/env bash
# Agent sandbox management using git worktrees
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX_DIR="$ROOT/../agent-sandbox"

say() { printf "%s\n" "$*"; }

cmd_create() {
  # Create sandbox worktree
  if [[ -d "$SANDBOX_DIR" ]]; then
    say "Sandbox already exists at $SANDBOX_DIR"
    return 0
  fi

  # Get current branch
  local current_branch
  current_branch=$(git branch --show-current)

  # Create worktree
  say "Creating sandbox worktree..."
  git worktree add "$SANDBOX_DIR" -b "agent-sandbox-$(date +%s)" "$current_branch"

  say "✅ Sandbox created at: $SANDBOX_DIR"
}

cmd_cleanup() {
  # Remove sandbox worktree
  if [[ ! -d "$SANDBOX_DIR" ]]; then
    say "No sandbox to cleanup"
    return 0
  fi

  say "Cleaning up sandbox..."

  # Remove worktree
  git worktree remove "$SANDBOX_DIR" --force 2>/dev/null || true

  # Clean up any orphaned branches
  git branch -D "agent-sandbox-"* 2>/dev/null || true

  say "✅ Sandbox cleaned up"
}

cmd_status() {
  # Show sandbox status
  if [[ ! -d "$SANDBOX_DIR" ]]; then
    say "No sandbox exists"
    return 1
  fi

  say "Sandbox status:"
  say "  Location: $SANDBOX_DIR"

  cd "$SANDBOX_DIR"
  say "  Branch: $(git branch --show-current)"
  say "  Changes:"
  git status --short | head -10

  local count
  count=$(git status --short | wc -l)
  if [[ $count -gt 10 ]]; then
    say "  ... and $((count - 10)) more files"
  fi
}

# Main routing
case "${1:-status}" in
  create)
    cmd_create
    ;;
  cleanup|clean)
    cmd_cleanup
    ;;
  status)
    cmd_status
    ;;
  *)
    say "Usage: $0 {create|cleanup|status}"
    exit 1
    ;;
esac
