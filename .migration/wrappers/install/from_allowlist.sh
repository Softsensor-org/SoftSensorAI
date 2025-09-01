#!/usr/bin/env bash
# Compatibility wrapper for from_allowlist.sh
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "⚠️  DEPRECATION NOTICE" >&2
echo "This command has been moved to: devpilot install --component from_allowlist" >&2
echo "Please update your scripts and workflows." >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
exec ./devpilot-new/devpilot install --component from_allowlist ""
