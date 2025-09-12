#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Documentation Requirements Checker
# This script checks if code changes have corresponding documentation updates

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
WARNINGS=0
ERRORS=0
SUGGESTIONS=0

# Functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}
error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}
suggest() {
    echo -e "${BLUE}💡${NC} $1"
    ((SUGGESTIONS++))
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "Documentation Requirements Check"
echo "========================================="
echo ""

# Get changed files (passed as argument or from git)
if [ $# -gt 0 ]; then
    # If argument is "-" or "/dev/stdin", read from stdin
    if [ "$1" = "-" ] || [ "$1" = "/dev/stdin" ]; then
        CHANGED_FILES=$(cat)
    else
        CHANGED_FILES="$1"
    fi
else
    # Get files changed in last commit or working directory
    if git diff --cached --name-only &>/dev/null && [ -n "$(git diff --cached --name-only)" ]; then
        CHANGED_FILES=$(git diff --cached --name-only)
        info "Checking staged files..."
    elif git diff --name-only &>/dev/null && [ -n "$(git diff --name-only)" ]; then
        CHANGED_FILES=$(git diff --name-only)
        info "Checking modified files..."
    else
        CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")
        info "Checking last commit..."
    fi
fi

if [ -z "$CHANGED_FILES" ]; then
    info "No changed files detected"
    exit 0
fi

# Categorize changed files
CODE_FILES=""
DOC_FILES=""
CONFIG_FILES=""
SCRIPT_FILES=""
WORKFLOW_FILES=""
INSTALL_FILES=""

while IFS= read -r file; do
    if [ -z "$file" ]; then continue; fi

    if [[ "$file" =~ \.sh$ ]]; then
        SCRIPT_FILES="${SCRIPT_FILES}${file}\n"
    elif [[ "$file" =~ \.(js|ts|py)$ ]]; then
        CODE_FILES="${CODE_FILES}${file}\n"
    elif [[ "$file" =~ \.(md|txt|rst)$ ]]; then
        DOC_FILES="${DOC_FILES}${file}\n"
    elif [[ "$file" =~ \.(json|yml|yaml|toml|ini|conf)$ ]]; then
        CONFIG_FILES="${CONFIG_FILES}${file}\n"
    elif [[ "$file" =~ ^\.github/workflows/ ]]; then
        WORKFLOW_FILES="${WORKFLOW_FILES}${file}\n"
    elif [[ "$file" =~ ^install/ ]]; then
        INSTALL_FILES="${INSTALL_FILES}${file}\n"
    fi
done <<< "$CHANGED_FILES"

# Check documentation requirements
echo "Analyzing changed files..."
echo ""

# Function to check if documentation exists
check_doc_exists() {
    local doc_file="$1"
    if [ -f "$PROJECT_ROOT/$doc_file" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if documentation was updated
doc_was_updated() {
    local doc_pattern="$1"
    echo "$CHANGED_FILES" | grep -q "$doc_pattern"
}

# Check for README updates when main scripts change
if echo "$CHANGED_FILES" | grep -q "^scripts/\|^setup/\|^install/"; then
    if ! doc_was_updated "README.md"; then
        warning "Scripts changed but README.md not updated"
        suggest "Consider updating README.md if functionality changed"
    else
        success "README.md was updated"
    fi
fi

# Check for CHANGELOG updates
if echo "$CHANGED_FILES" | grep -E "\.(sh|js|ts|py)$" > /dev/null; then
    if ! doc_was_updated "CHANGELOG.md"; then
        info "Code changed but CHANGELOG.md not updated"
        suggest "Remember to update CHANGELOG.md before release"
    else
        success "CHANGELOG.md was updated"
    fi
fi

# Check for CI documentation when workflows change
if echo "$CHANGED_FILES" | grep -q "^\.github/workflows/"; then
    if ! doc_was_updated "docs/ci.md\|docs/CI.md"; then
        warning "GitHub workflows changed but CI documentation not updated"
        suggest "Update docs/ci.md to reflect workflow changes"
    else
        success "CI documentation was updated"
    fi
fi

# Check for installation guide updates
if echo "$CHANGED_FILES" | grep -q "^install/"; then
    if ! doc_was_updated "docs/.*install\|docs/quickstart\|README.md"; then
        warning "Installation scripts changed but installation docs not updated"
        suggest "Update installation guides or quickstart.md"
    else
        success "Installation documentation was updated"
    fi
fi

# Check for migration guide updates on breaking changes
if git log -1 --pretty=%B 2>/dev/null | grep -iE "breaking|major" > /dev/null; then
    if ! doc_was_updated "docs/MIGRATION.md\|MIGRATION.md"; then
        error "Commit message indicates breaking changes but MIGRATION.md not updated"
        suggest "Document migration steps for users"
    else
        success "Migration guide was updated"
    fi
fi

# Check for API documentation
if echo "$CHANGED_FILES" | grep -q "^api/\|^lib/\|^src/"; then
    if ! doc_was_updated "docs/API\|docs/api"; then
        info "API/library code changed"
        suggest "Consider updating API documentation"
    fi
fi

# Check specific file documentation requirements
echo ""
echo "File-specific checks:"

# Check each changed script file for documentation
while IFS= read -r script; do
    if [ -z "$script" ]; then continue; fi

    # Check if script has header documentation
    if [ -f "$PROJECT_ROOT/$script" ]; then
        if ! head -10 "$PROJECT_ROOT/$script" | grep -q "^#.*Description\|^#.*Purpose\|^#.*Usage"; then
            warning "$script lacks header documentation"
            suggest "Add usage documentation at the top of $script"
        else
            success "$script has header documentation"
        fi
    fi
done < <(echo "$CHANGED_FILES" | grep "\.sh$" 2>/dev/null || true)

# Check for corresponding docs for new features
if echo "$CHANGED_FILES" | grep -q "^features/\|^plugins/\|^extensions/"; then
    feature_name=$(echo "$CHANGED_FILES" | grep "^features/\|^plugins/\|^extensions/" | head -1 | cut -d'/' -f2)
    if ! check_doc_exists "docs/*$feature_name*"; then
        warning "New feature '$feature_name' added without documentation"
        suggest "Create documentation for the new feature"
    fi
fi

# Check for test documentation
if echo "$CHANGED_FILES" | grep -q "^tests/\|^test/"; then
    if ! doc_was_updated "docs/.*test\|TEST\|test"; then
        info "Tests changed"
        suggest "Consider documenting test changes or test requirements"
    fi
fi

# Generate documentation coverage report
echo ""
echo "========================================="
echo "Documentation Coverage Report"
echo "========================================="
echo ""

# Count file types
NUM_CODE_FILES=$(echo "$CHANGED_FILES" | grep -E "\.(sh|js|ts|py)$" | wc -l | tr -d ' ' || echo 0)
NUM_DOC_FILES=$(echo "$CHANGED_FILES" | grep -E "\.(md|txt|rst)$" | wc -l | tr -d ' ' || echo 0)
NUM_CONFIG_FILES=$(echo "$CHANGED_FILES" | grep -E "\.(json|yml|yaml|toml)$" | wc -l | tr -d ' ' || echo 0)

echo "Changed files summary:"
echo "  Code files:          $NUM_CODE_FILES"
echo "  Documentation files: $NUM_DOC_FILES"
echo "  Config files:        $NUM_CONFIG_FILES"
echo ""

# Calculate documentation ratio
if [ "$NUM_CODE_FILES" -gt 0 ]; then
    if [ "$NUM_DOC_FILES" -gt 0 ]; then
        DOC_RATIO=$(echo "scale=2; $NUM_DOC_FILES / $NUM_CODE_FILES * 100" | bc)
        echo "Documentation ratio: ${DOC_RATIO}%"

        if (( $(echo "$DOC_RATIO >= 50" | bc -l) )); then
            success "Good documentation coverage"
        elif (( $(echo "$DOC_RATIO >= 25" | bc -l) )); then
            info "Moderate documentation coverage"
        else
            warning "Low documentation coverage"
        fi
    else
        warning "No documentation files updated alongside code changes"
    fi
else
    if [ "$NUM_DOC_FILES" -gt 0 ]; then
        success "Documentation-only changes"
    fi
fi

# Check critical documentation files exist
echo ""
echo "Critical documentation status:"
[ -f "$PROJECT_ROOT/README.md" ] && success "README.md exists" || error "README.md missing"
[ -f "$PROJECT_ROOT/CHANGELOG.md" ] && success "CHANGELOG.md exists" || warning "CHANGELOG.md missing"
[ -f "$PROJECT_ROOT/CONTRIBUTING.md" ] && success "CONTRIBUTING.md exists" || info "CONTRIBUTING.md missing"
[ -d "$PROJECT_ROOT/docs" ] && success "docs/ directory exists" || warning "docs/ directory missing"

# Provide recommendations
if [ $WARNINGS -gt 0 ] || [ $ERRORS -gt 0 ] || [ $SUGGESTIONS -gt 0 ]; then
    echo ""
    echo "========================================="
    echo "Recommendations"
    echo "========================================="
    echo ""

    if [ $ERRORS -gt 0 ]; then
        echo "❌ Critical documentation issues found. Please address these before merging."
    elif [ $WARNINGS -gt 0 ]; then
        echo "⚠️  Documentation could be improved. Consider addressing warnings."
    fi

    if [ $SUGGESTIONS -gt 0 ]; then
        echo "💡 See suggestions above for improving documentation."
    fi

    echo ""
    echo "Quick fixes:"
    echo "  • Update README.md: echo '- Your change' >> README.md"
    echo "  • Update CHANGELOG: echo '### Changed\n- Your change' >> CHANGELOG.md"
    echo "  • Create docs: mkdir -p docs && echo '# Documentation' > docs/your-feature.md"
fi

# Final summary
echo ""
echo "========================================="
echo "Summary"
echo "========================================="
echo "  Errors:      $ERRORS"
echo "  Warnings:    $WARNINGS"
echo "  Suggestions: $SUGGESTIONS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ Documentation check failed with errors"
    exit 1
elif [ $WARNINGS -gt 5 ]; then
    echo "⚠️  Documentation check passed with many warnings"
    exit 0
elif [ $WARNINGS -gt 0 ]; then
    echo "✅ Documentation check passed with warnings"
    exit 0
else
    echo "✅ Documentation check passed"
    exit 0
fi
