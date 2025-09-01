#!/usr/bin/env bash
# DevPilot core configuration (scaffold)

export DEVPILOT_HOME="${DEVPILOT_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export DEVPILOT_STATE_DIR="$DEVPILOT_HOME/../.devpilot/state"
export DEVPILOT_CACHE_DIR="$DEVPILOT_HOME/../.devpilot/cache"
export DEVPILOT_LOG_DIR="$DEVPILOT_HOME/../.devpilot/logs"
mkdir -p "$DEVPILOT_STATE_DIR" "$DEVPILOT_CACHE_DIR" "$DEVPILOT_LOG_DIR" 2>/dev/null || true

