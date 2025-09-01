#!/usr/bin/env bash
# DevPilot Release Automation Script
# Usage: ./release.sh [--type major|minor|patch] [--dry-run]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default values
RELEASE_TYPE="patch"
DRY_RUN=false
AUTO_CONFIRM=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            RELEASE_TYPE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --yes|-y)
            AUTO_CONFIRM=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--type major|minor|patch] [--dry-run] [--yes]"
            echo "  --type: Version bump type (default: patch)"
            echo "  --dry-run: Preview changes without executing"
            echo "  --yes: Skip confirmation prompts"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Functions
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

run_command() {
    local cmd="$1"
    if [[ "$DRY_RUN" == true ]]; then
        print_color "$BLUE" "[DRY RUN] Would execute: $cmd"
    else
        print_color "$YELLOW" "Executing: $cmd"
        eval "$cmd"
    fi
}

confirm() {
    if [[ "$AUTO_CONFIRM" == true ]]; then
        return 0
    fi
    
    local prompt="$1"
    read -p "$prompt [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Change to root directory
cd "$ROOT_DIR"

# Header
print_color "$GREEN" ""
print_color "$GREEN" "========================================"
print_color "$GREEN" "   DevPilot Release Automation"
print_color "$GREEN" "========================================"
print_color "$GREEN" ""

if [[ "$DRY_RUN" == true ]]; then
    print_color "$YELLOW" "🔬 DRY RUN MODE - No changes will be made"
    echo ""
fi

# Pre-flight checks
print_color "$YELLOW" "🔍 Running pre-flight checks..."

# Check for clean working directory
if [[ -n $(git status --porcelain) ]]; then
    print_color "$RED" "✗ Working directory is not clean"
    git status --short
    if ! confirm "Continue anyway?"; then
        exit 1
    fi
else
    print_color "$GREEN" "✓ Working directory is clean"
fi

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    print_color "$YELLOW" "⚠ Not on main branch (current: $CURRENT_BRANCH)"
    if ! confirm "Continue anyway?"; then
        exit 1
    fi
else
    print_color "$GREEN" "✓ On main branch"
fi

# Run tests
print_color "$YELLOW" "\n🧪 Running tests..."
if [[ -f "$ROOT_DIR/Makefile" ]] && grep -q "^test:" "$ROOT_DIR/Makefile"; then
    if [[ "$DRY_RUN" == false ]]; then
        if make test; then
            print_color "$GREEN" "✓ Tests passed"
        else
            print_color "$RED" "✗ Tests failed"
            if ! confirm "Continue anyway?"; then
                exit 1
            fi
        fi
    else
        print_color "$BLUE" "[DRY RUN] Would run: make test"
    fi
else
    print_color "$YELLOW" "⚠ No test target found"
fi

# Get current version
if [[ ! -f "$ROOT_DIR/VERSION" ]]; then
    print_color "$RED" "✗ VERSION file not found"
    exit 1
fi

CURRENT_VERSION=$(cat "$ROOT_DIR/VERSION")
print_color "$YELLOW" "\n📦 Current version: $CURRENT_VERSION"

# Bump version
print_color "$YELLOW" "\n🔼 Bumping version ($RELEASE_TYPE)..."
if [[ "$DRY_RUN" == false ]]; then
    "$SCRIPT_DIR/bump-version.sh" "$RELEASE_TYPE"
    NEW_VERSION=$(cat "$ROOT_DIR/VERSION")
else
    # Calculate new version for dry run
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
    case "$RELEASE_TYPE" in
        major) NEW_VERSION="$((MAJOR + 1)).0.0" ;;
        minor) NEW_VERSION="$MAJOR.$((MINOR + 1)).0" ;;
        patch) NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))" ;;
    esac
    print_color "$BLUE" "[DRY RUN] Would bump to: $NEW_VERSION"
fi

# Generate changelog
print_color "$YELLOW" "\n📝 Generating changelog..."
CHANGELOG_ENTRY=$($SCRIPT_DIR/generate-changelog.sh)

if [[ "$DRY_RUN" == false ]]; then
    # Prepend to CHANGELOG.md
    {
        head -n 6 CHANGELOG.md
        echo ""
        echo "$CHANGELOG_ENTRY"
        echo ""
        tail -n +7 CHANGELOG.md
    } > CHANGELOG.tmp
    mv CHANGELOG.tmp CHANGELOG.md
    print_color "$GREEN" "✓ Updated CHANGELOG.md"
else
    print_color "$BLUE" "[DRY RUN] Would add to CHANGELOG.md:"
    echo "$CHANGELOG_ENTRY" | head -20
    echo "..."
fi

# Create release commit
print_color "$YELLOW" "\n💾 Creating release commit..."
run_command "git add -A"
run_command "git commit -m \"chore: release v$NEW_VERSION\""

# Create tag
print_color "$YELLOW" "\n🏷️ Creating tag..."
TAG_MESSAGE="Release v$NEW_VERSION\n\n$(echo "$CHANGELOG_ENTRY" | head -50)"
run_command "git tag -a v$NEW_VERSION -m \"$TAG_MESSAGE\""

# Push to remote
print_color "$YELLOW" "\n🚀 Pushing to remote..."
if ! confirm "Push to remote repository?"; then
    print_color "$YELLOW" "⚠ Skipping push to remote"
    print_color "$YELLOW" "To push manually, run:"
    echo "  git push origin $CURRENT_BRANCH"
    echo "  git push origin v$NEW_VERSION"
else
    run_command "git push origin $CURRENT_BRANCH"
    run_command "git push origin v$NEW_VERSION"
fi

# Create GitHub release
print_color "$YELLOW" "\n🎉 Creating GitHub release..."
if command -v gh &> /dev/null; then
    if ! confirm "Create GitHub release?"; then
        print_color "$YELLOW" "⚠ Skipping GitHub release"
        print_color "$YELLOW" "To create manually, run:"
        echo "  gh release create v$NEW_VERSION --title \"DevPilot v$NEW_VERSION\" --notes \"$CHANGELOG_ENTRY\""
    else
        RELEASE_NOTES_FILE="/tmp/release-notes-$NEW_VERSION.md"
        echo "$CHANGELOG_ENTRY" > "$RELEASE_NOTES_FILE"
        run_command "gh release create v$NEW_VERSION --title \"DevPilot v$NEW_VERSION\" --notes-file \"$RELEASE_NOTES_FILE\""
        rm -f "$RELEASE_NOTES_FILE"
    fi
else
    print_color "$YELLOW" "⚠ GitHub CLI not found. Install with: brew install gh"
fi

# Summary
print_color "$GREEN" ""
print_color "$GREEN" "========================================"
print_color "$GREEN" "✅ Release v$NEW_VERSION completed!"
print_color "$GREEN" "========================================"
print_color "$GREEN" ""

print_color "$YELLOW" "Next steps:"
echo "  1. Verify the release on GitHub: https://github.com/Softsensor-org/DevPilot/releases/tag/v$NEW_VERSION"
echo "  2. Update documentation if needed"
echo "  3. Announce the release to the team"
echo "  4. Monitor for any issues"

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    print_color "$YELLOW" "🔬 This was a dry run. To perform the actual release, run:"
    echo "  $0 --type $RELEASE_TYPE"
fi