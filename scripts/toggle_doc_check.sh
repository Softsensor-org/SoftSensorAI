#!/usr/bin/env bash
# Toggle documentation check pre-commit hook

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOK_SOURCE="$PROJECT_ROOT/.githooks/pre-commit-docs"
HOOK_DEST="$PROJECT_ROOT/.git/hooks/pre-commit-docs"
PRE_COMMIT_HOOK="$PROJECT_ROOT/.git/hooks/pre-commit"

# Check if in git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Function to enable documentation check
enable_doc_check() {
    echo -e "${BLUE}Enabling documentation check hook...${NC}"

    # Create hooks directory if it doesn't exist
    mkdir -p "$PROJECT_ROOT/.git/hooks"

    # Link the documentation check hook
    ln -sf "../../.githooks/pre-commit-docs" "$HOOK_DEST"

    # Check if pre-commit hook exists
    if [ ! -f "$PRE_COMMIT_HOOK" ]; then
        # Create a new pre-commit hook
        cat > "$PRE_COMMIT_HOOK" << 'EOF'
#!/usr/bin/env bash
# Main pre-commit hook

# Run documentation check if available
if [ -x .git/hooks/pre-commit-docs ]; then
    .git/hooks/pre-commit-docs || exit $?
fi

# Add other pre-commit checks here
exit 0
EOF
        chmod +x "$PRE_COMMIT_HOOK"
    else
        # Check if documentation check is already in pre-commit
        if ! grep -q "pre-commit-docs" "$PRE_COMMIT_HOOK"; then
            # Add documentation check to existing pre-commit
            echo "" >> "$PRE_COMMIT_HOOK"
            echo "# Run documentation check if available" >> "$PRE_COMMIT_HOOK"
            echo 'if [ -x .git/hooks/pre-commit-docs ]; then' >> "$PRE_COMMIT_HOOK"
            echo '    .git/hooks/pre-commit-docs || exit $?' >> "$PRE_COMMIT_HOOK"
            echo 'fi' >> "$PRE_COMMIT_HOOK"
        fi
    fi

    echo -e "${GREEN}✓ Documentation check hook enabled${NC}"
    echo ""
    echo "The hook will check if code changes have corresponding documentation."
    echo "To bypass the check for a single commit: git commit --no-verify"
}

# Function to disable documentation check
disable_doc_check() {
    echo -e "${BLUE}Disabling documentation check hook...${NC}"

    # Remove the hook link
    if [ -L "$HOOK_DEST" ] || [ -f "$HOOK_DEST" ]; then
        rm -f "$HOOK_DEST"
    fi

    # Remove from pre-commit if present
    if [ -f "$PRE_COMMIT_HOOK" ] && grep -q "pre-commit-docs" "$PRE_COMMIT_HOOK"; then
        # Remove the documentation check lines
        sed -i '/# Run documentation check if available/,+3d' "$PRE_COMMIT_HOOK" 2>/dev/null || \
        sed -i '' '/# Run documentation check if available/,+3d' "$PRE_COMMIT_HOOK" 2>/dev/null || true
    fi

    echo -e "${GREEN}✓ Documentation check hook disabled${NC}"
}

# Function to check status
check_status() {
    if [ -L "$HOOK_DEST" ] || [ -f "$HOOK_DEST" ]; then
        echo -e "${GREEN}Documentation check hook is ENABLED${NC}"
        echo "Location: $HOOK_DEST"
    else
        echo -e "${YELLOW}Documentation check hook is DISABLED${NC}"
    fi
}

# Main logic
case "${1:-status}" in
    enable|on)
        enable_doc_check
        ;;
    disable|off)
        disable_doc_check
        ;;
    status)
        check_status
        ;;
    *)
        echo "Usage: $0 {enable|disable|status}"
        echo ""
        echo "Commands:"
        echo "  enable  - Enable documentation check pre-commit hook"
        echo "  disable - Disable documentation check pre-commit hook"
        echo "  status  - Show current hook status"
        echo ""
        echo "Aliases:"
        echo "  on  = enable"
        echo "  off = disable"
        exit 1
        ;;
esac
