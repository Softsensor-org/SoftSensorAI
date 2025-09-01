#!/usr/bin/env bash
# Compatibility wrapper for key_software_wsl.sh
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "⚠️  DEPRECATION NOTICE" >&2
echo "This command has been moved to: devpilot install --component key_software_wsl" >&2
echo "Please update your scripts and workflows." >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
exec ./devpilot-new/devpilot install --component key_software_wsl ""
