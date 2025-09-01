#!/usr/bin/env bash
# Git worktree helper for parallel Claude sessions
set -euo pipefail

cmd="${1:-list}"
name="${2:-}"
branch="${3:-}"

case "$cmd" in
  add|create)
    [ -z "$name" ] && { echo "Usage: $0 add <name> [branch]"; exit 1; }
    [ -z "$branch" ] && branch="$name"
    
    # Ensure we're in a git repo
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not in a git repo"; exit 1; }
    
    # Get repo root and parent dir
    root="$(git rev-parse --show-toplevel)"
    parent="$(dirname "$root")"
    worktree_path="$parent/$(basename "$root")-$name"
    
    # Check if branch exists
    if git show-ref --verify --quiet "refs/heads/$branch"; then
      echo "Using existing branch: $branch"
    else
      echo "Creating new branch: $branch"
      git branch "$branch" 2>/dev/null || true
    fi
    
    # Create worktree
    git worktree add "$worktree_path" "$branch"
    echo "✓ Created worktree at: $worktree_path"
    echo "✓ Branch: $branch"
    echo ""
    echo "To use in new Claude session:"
    echo "  cd $worktree_path"
    ;;
    
  remove|rm|delete)
    [ -z "$name" ] && { echo "Usage: $0 remove <name>"; exit 1; }
    
    # Find worktree by name
    worktree_path="$(git worktree list --porcelain | grep -B2 "branch.*$name" | grep "^worktree" | cut -d' ' -f2 | head -1)"
    
    if [ -z "$worktree_path" ]; then
      echo "Worktree not found: $name"
      echo "Available worktrees:"
      git worktree list
      exit 1
    fi
    
    echo "Removing worktree: $worktree_path"
    git worktree remove "$worktree_path" --force
    echo "✓ Removed worktree"
    
    # Optionally delete branch
    read -p "Delete branch '$name'? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      git branch -D "$name" 2>/dev/null && echo "✓ Deleted branch" || echo "Branch not found or is checked out"
    fi
    ;;
    
  list|ls)
    echo "Current worktrees:"
    git worktree list | while IFS= read -r line; do
      path=$(echo "$line" | awk '{print $1}')
      branch=$(echo "$line" | grep -oP '\[.*?\]' | tr -d '[]')
      commit=$(echo "$line" | awk '{print $2}')
      
      # Check if it's the main worktree
      if [ "$path" = "$(git rev-parse --show-toplevel)" ]; then
        echo "* $path [$branch] $commit (main)"
      else
        echo "  $path [$branch] $commit"
      fi
    done
    ;;
    
  clean|prune)
    echo "Pruning stale worktrees..."
    git worktree prune -v
    echo "✓ Pruned stale worktrees"
    
    # List remaining
    echo ""
    echo "Active worktrees:"
    git worktree list
    ;;
    
  switch|cd)
    [ -z "$name" ] && { echo "Usage: $0 switch <name>"; exit 1; }
    
    # Find worktree path
    worktree_path="$(git worktree list --porcelain | grep -B2 "branch.*$name" | grep "^worktree" | cut -d' ' -f2 | head -1)"
    
    if [ -z "$worktree_path" ]; then
      echo "Worktree not found: $name"
      exit 1
    fi
    
    echo "cd $worktree_path"
    echo "(Copy and run the above command to switch)"
    ;;
    
  help|--help|-h)
    cat <<EOF
Git Worktree Helper for Parallel Claude Sessions

Usage: $0 <command> [args]

Commands:
  add <name> [branch]  Create new worktree (branch defaults to name)
  remove <name>        Remove worktree and optionally delete branch
  list                 List all worktrees
  clean                Prune stale worktrees
  switch <name>        Show cd command to switch to worktree
  help                 Show this help

Examples:
  $0 add feature-auth              # Create worktree for feature-auth branch
  $0 add hotfix main               # Create hotfix worktree from main branch
  $0 remove feature-auth           # Remove feature-auth worktree
  $0 list                          # Show all worktrees
  $0 clean                         # Remove stale worktree references

Tips:
  - Each worktree is independent - perfect for parallel Claude sessions
  - Worktrees share the same .git directory (saves space)
  - You can have different branches checked out simultaneously
  - Changes in one worktree don't affect others until merged
EOF
    ;;
    
  *)
    echo "Unknown command: $cmd"
    echo "Run: $0 help"
    exit 1
    ;;
esac
