#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Validate that all dp commands are documented
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

say() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
die() { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

# Extract commands from bin/dp
echo "Extracting commands from bin/dp..."
COMMANDS=$(grep -E '^\s+[a-z-]+\)\s+shift;?\s+cmd_' "$ROOT/bin/dp" | sed 's/^\s*\([a-z-]*\)).*/\1/' | sort -u)

# Check if commands.md exists
if [[ ! -f "$ROOT/.claude/commands.md" ]]; then
    die ".claude/commands.md not found"
fi

# Check each command is documented
MISSING_DOCS=()
MISSING_REGISTRY=()

echo "Validating command documentation..."
for cmd in $COMMANDS; do
    # Skip internal commands
    if [[ "$cmd" == "help" ]] || [[ "$cmd" == "" ]]; then
        continue
    fi

    # Check if command is in registry
    if ! grep -q "^## dp $cmd" "$ROOT/.claude/commands.md" 2>/dev/null; then
        MISSING_REGISTRY+=("$cmd")
    fi

    # Check if command has documentation
    DOC_FILE=""
    case "$cmd" in
        agent)
            DOC_FILE="docs/AGENTIC_CODING.md"
            ;;
        review)
            DOC_FILE="docs/AI_PR_REVIEW.md"
            ;;
        team-doctor)
            DOC_FILE="docs/MULTI_USER.md"
            ;;
        *)
            # Look for command-specific doc or in quickstart
            if [[ -f "$ROOT/docs/DP_${cmd^^}.md" ]]; then
                DOC_FILE="docs/DP_${cmd^^}.md"
            elif ! grep -q "dp $cmd" "$ROOT/docs/quickstart.md" 2>/dev/null; then
                MISSING_DOCS+=("$cmd")
            fi
            ;;
    esac

    if [[ -n "$DOC_FILE" ]] && [[ ! -f "$ROOT/$DOC_FILE" ]]; then
        MISSING_DOCS+=("$cmd (expected: $DOC_FILE)")
    fi
done

# Report results
echo ""
if [[ ${#MISSING_REGISTRY[@]} -gt 0 ]]; then
    warn "Commands missing from registry (.claude/commands.md):"
    for cmd in "${MISSING_REGISTRY[@]}"; do
        echo "  - dp $cmd"
    done
    echo ""
fi

if [[ ${#MISSING_DOCS[@]} -gt 0 ]]; then
    warn "Commands missing documentation:"
    for cmd in "${MISSING_DOCS[@]}"; do
        echo "  - dp $cmd"
    done
    echo ""
fi

# Regenerate command registry if needed
if [[ ${#MISSING_REGISTRY[@]} -gt 0 ]]; then
    echo "Regenerating command registry..."
    if [[ -x "$ROOT/scripts/generate_command_registry.sh" ]]; then
        "$ROOT/scripts/generate_command_registry.sh"
        say "Command registry regenerated"
    else
        die "generate_command_registry.sh not found or not executable"
    fi
fi

# Final status
if [[ ${#MISSING_REGISTRY[@]} -eq 0 ]] && [[ ${#MISSING_DOCS[@]} -eq 0 ]]; then
    say "All commands are properly documented!"
    exit 0
else
    die "Documentation validation failed. Please update documentation."
fi
