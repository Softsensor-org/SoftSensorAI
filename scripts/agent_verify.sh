#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Agent verification - wrapper around dp-agent verify_repo
# Maintains backward compatibility while using unified JSON schema
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Multi-user mode detection (same as dp)
if [[ -f "/opt/softsensorai/etc/softsensorai.conf" ]]; then
    source /opt/softsensorai/etc/softsensorai.conf
    ROOT="${SOFTSENSORAI_ROOT:-/opt/softsensorai}"
    ART="${SOFTSENSORAI_USER_DIR:-$HOME/.softsensorai}/artifacts"
else
    ART="$ROOT/artifacts"
fi

# Usage message
usage() {
    cat >&2 <<EOF
Usage: agent_verify.sh [--task-id TASK_ID] [--output FILE]

Wrapper around dp-agent verification engine. Uses the unified JSON schema
from bin/dp-agent verify_repo() for consistency across dashboards.

Options:
  --task-id ID    Task ID to verify (default: latest task)
  --output FILE   Output JSON file (default: stdout)
  --help          Show this help message

Environment:
  SANDBOX_DIR     Override sandbox directory (default: from task)

Deprecated: This script now wraps dp-agent for consistency.
Use 'dp agent verify --id TASK_ID' directly for new integrations.
EOF
    exit 0
}

# Parse arguments
TASK_ID=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --task-id)
            TASK_ID="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

# Find task ID if not specified
if [[ -z "$TASK_ID" ]]; then
    # Get the most recent task
    if [[ -d "$ART/agent" ]]; then
        # shellcheck disable=SC2010
        TASK_ID=$(ls -t "$ART/agent" 2>/dev/null | grep '^task-' | head -1)
    fi

    if [[ -z "$TASK_ID" ]]; then
        echo "Error: No task ID specified and no tasks found" >&2
        echo "Run 'dp agent new --goal \"<goal>\"' to create a task" >&2
        exit 1
    fi
fi

# Check if task exists
if [[ ! -d "$ART/agent/$TASK_ID" ]]; then
    echo "Error: Task $TASK_ID not found in $ART/agent/" >&2
    exit 1
fi

# Check if verification already exists
VERIFY_JSON="$ART/agent/$TASK_ID/verify.json"

# If verify.json doesn't exist, run verification
if [[ ! -f "$VERIFY_JSON" ]]; then
    echo "Running verification for task $TASK_ID..." >&2

    # Get the worktree path from task
    WORKTREE="$ART/agent/$TASK_ID/worktree"
    if [[ ! -d "$WORKTREE" ]]; then
        # Try alternate location
        WORKTREE="$HOME/.softsensorai/worktrees/$TASK_ID"
        if [[ ! -d "$WORKTREE" ]]; then
            echo "Error: Worktree not found for task $TASK_ID" >&2
            echo "Run 'dp agent run --id $TASK_ID' first" >&2
            exit 1
        fi
    fi

    # Call dp-agent's verify_repo function
    # This writes to $ART/agent/$TASK_ID/verify.json
    if command -v dp-agent >/dev/null 2>&1; then
        dp-agent verify --id "$TASK_ID" >/dev/null 2>&1 || true
    elif [[ -x "$ROOT/bin/dp-agent" ]]; then
        "$ROOT/bin/dp-agent" verify --id "$TASK_ID" >/dev/null 2>&1 || true
    else
        # Fallback: inline verification (simplified from dp-agent)
        cat > "$VERIFY_JSON" <<EOF
{
  "build": {"ok": false},
  "tests": {"ok": false, "coverage_pct": 0, "coverage_base_pct": 0, "coverage_delta_pct": 0},
  "lint": {"ok": false},
  "security": {"ok": false, "semgrep_high": 0, "trivy_high": 0, "gitleaks": 0},
  "time_s": 0,
  "error": "dp-agent not found, verification skipped"
}
EOF
    fi
fi

# Output the verification result
if [[ -f "$VERIFY_JSON" ]]; then
    if [[ -n "$OUTPUT_FILE" ]]; then
        cp "$VERIFY_JSON" "$OUTPUT_FILE"
        echo "Verification results written to: $OUTPUT_FILE" >&2
    else
        cat "$VERIFY_JSON"
    fi
else
    echo "Error: Verification failed - no verify.json generated" >&2
    exit 1
fi
