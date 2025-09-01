#!/usr/bin/env bash
# DevPilot Changelog Generator
# Usage: ./generate-changelog.sh [from-tag] [to-tag]

set -euo pipefail

# Colors
BOLD='\033[1m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Arguments
FROM_TAG="${1:-}"
TO_TAG="${2:-HEAD}"

# Auto-detect last tag if not provided
if [[ -z "$FROM_TAG" ]]; then
    FROM_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    if [[ -z "$FROM_TAG" ]]; then
        echo "No previous tags found. Using first commit."
        FROM_TAG=$(git rev-list --max-parents=0 HEAD)
    fi
fi

# Get current date
DATE=$(date +%Y-%m-%d)

# Get version from VERSION file
VERSION="Unknown"
if [[ -f "$ROOT_DIR/VERSION" ]]; then
    VERSION=$(cat "$ROOT_DIR/VERSION")
fi

# Header
echo -e "${BOLD}## [$VERSION] - $DATE${NC}"
echo ""

# Initialize sections
FEATURES=""
FIXES=""
DOCS=""
CHORE=""
BREAKING=""
OTHER=""

# Process commits
while IFS= read -r line; do
    # Parse commit
    HASH=$(echo "$line" | cut -d'|' -f1)
    SUBJECT=$(echo "$line" | cut -d'|' -f2)
    AUTHOR=$(echo "$line" | cut -d'|' -f3)
    
    # Extract type and description
    if [[ "$SUBJECT" =~ ^([a-z]+)(\(.+\))?:(.+)$ ]]; then
        TYPE="${BASH_REMATCH[1]}"
        SCOPE="${BASH_REMATCH[2]}"
        DESC="${BASH_REMATCH[3]}"
        
        # Trim whitespace
        DESC="${DESC## }"
        DESC="${DESC%% }"
        
        # Check for breaking changes
        if [[ "$SUBJECT" =~ "BREAKING CHANGE" ]] || [[ "$SUBJECT" =~ "!:" ]]; then
            BREAKING="${BREAKING}- $DESC (${HASH:0:7})\n"
        fi
        
        # Categorize by type
        case "$TYPE" in
            feat|feature)
                FEATURES="${FEATURES}- $DESC (${HASH:0:7})\n"
                ;;
            fix|bugfix)
                FIXES="${FIXES}- $DESC (${HASH:0:7})\n"
                ;;
            docs|doc)
                DOCS="${DOCS}- $DESC (${HASH:0:7})\n"
                ;;
            chore|build|ci|perf|refactor|style|test)
                CHORE="${CHORE}- $DESC (${HASH:0:7})\n"
                ;;
            *)
                OTHER="${OTHER}- $SUBJECT (${HASH:0:7})\n"
                ;;
        esac
    else
        # Non-conventional commit
        OTHER="${OTHER}- $SUBJECT (${HASH:0:7})\n"
    fi
done < <(git log --format="%H|%s|%an" "${FROM_TAG}..${TO_TAG}" 2>/dev/null)

# Output sections
if [[ -n "$BREAKING" ]]; then
    echo "### ⚠️ BREAKING CHANGES"
    echo -e "$BREAKING"
fi

if [[ -n "$FEATURES" ]]; then
    echo "### ✨ Features"
    echo -e "$FEATURES"
fi

if [[ -n "$FIXES" ]]; then
    echo "### 🐛 Bug Fixes"
    echo -e "$FIXES"
fi

if [[ -n "$DOCS" ]]; then
    echo "### 📚 Documentation"
    echo -e "$DOCS"
fi

if [[ -n "$CHORE" ]]; then
    echo "### 🔧 Maintenance"
    echo -e "$CHORE"
fi

if [[ -n "$OTHER" ]]; then
    echo "### 📦 Other Changes"
    echo -e "$OTHER"
fi

# Statistics
echo "### 📊 Statistics"
COMMIT_COUNT=$(git rev-list --count "${FROM_TAG}..${TO_TAG}" 2>/dev/null || echo "0")
CONTRIBUTOR_COUNT=$(git log --format="%an" "${FROM_TAG}..${TO_TAG}" 2>/dev/null | sort -u | wc -l)
FILE_COUNT=$(git diff --stat "${FROM_TAG}..${TO_TAG}" 2>/dev/null | tail -1 | awk '{print $1}')

echo "- Commits: $COMMIT_COUNT"
echo "- Contributors: $CONTRIBUTOR_COUNT"
echo "- Files changed: ${FILE_COUNT:-0}"

# Contributors
echo ""
echo "### 🙏 Contributors"
git log --format="%an" "${FROM_TAG}..${TO_TAG}" 2>/dev/null | sort | uniq -c | sort -rn | while read count name; do
    echo "- $name ($count commits)"
done

echo ""
echo "---"
echo "*Full diff: [${FROM_TAG}...${TO_TAG}](https://github.com/Softsensor-org/DevPilot/compare/${FROM_TAG}...${TO_TAG})*"