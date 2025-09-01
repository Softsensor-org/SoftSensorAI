#!/usr/bin/env bash
# DevPilot Version Bumping Script
# Usage: ./bump-version.sh [major|minor|patch]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Check if VERSION file exists
if [[ ! -f "$VERSION_FILE" ]]; then
    print_color "$RED" "Error: VERSION file not found at $VERSION_FILE"
    exit 1
fi

# Get bump type
TYPE="${1:-patch}"

# Validate bump type
if [[ ! "$TYPE" =~ ^(major|minor|patch)$ ]]; then
    print_color "$RED" "Error: Invalid version bump type: $TYPE"
    echo "Usage: $0 [major|minor|patch]"
    exit 1
fi

# Read current version
CURRENT=$(cat "$VERSION_FILE")

# Validate current version format
if [[ ! "$CURRENT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_color "$RED" "Error: Invalid version format in VERSION file: $CURRENT"
    exit 1
fi

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# Calculate new version
case "$TYPE" in
    major)
        NEW="$((MAJOR + 1)).0.0"
        ;;
    minor)
        NEW="$MAJOR.$((MINOR + 1)).0"
        ;;
    patch)
        NEW="$MAJOR.$MINOR.$((PATCH + 1))"
        ;;
esac

# Update VERSION file
echo "$NEW" > "$VERSION_FILE"

# Update other files if they exist
if [[ -f "$ROOT_DIR/package.json" ]]; then
    # Update package.json version
    if command -v jq &> /dev/null; then
        jq ".version = \"$NEW\"" "$ROOT_DIR/package.json" > /tmp/package.json
        mv /tmp/package.json "$ROOT_DIR/package.json"
        print_color "$GREEN" "✓ Updated package.json"
    fi
fi

# Print summary
print_color "$GREEN" "\n✅ Version bumped successfully!"
print_color "$YELLOW" "  Old version: $CURRENT"
print_color "$GREEN" "  New version: $NEW"
print_color "$YELLOW" "  Bump type: $TYPE"

# Suggest next steps
echo ""
print_color "$YELLOW" "Next steps:"
echo "  1. Update CHANGELOG.md with release notes"
echo "  2. Commit changes: git add -A && git commit -m \"chore: bump version to $NEW\""
echo "  3. Create tag: git tag -a v$NEW -m \"Release v$NEW\""
echo "  4. Push changes: git push origin main && git push origin v$NEW"
echo "  5. Create GitHub release: gh release create v$NEW"