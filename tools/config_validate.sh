#!/usr/bin/env bash
set -euo pipefail

fail=0

check_claude_settings() {
  local f="$1"
  jq -e 'has("permissions") and (.permissions|has("allow") and has("ask") and has("deny") and has("defaultMode")) and (.permissions.allow|type=="array") and (.permissions.ask|type=="array") and (.permissions.deny|type=="array") and (.permissions.defaultMode|type=="string")' "$f" >/dev/null || {
    echo "[schema] invalid .claude/settings.json: $f"; return 1; }
}

check_mcp() {
  local f="$1"
  jq -e 'has("mcpServers") and (.mcpServers|type=="object")' "$f" >/dev/null || {
    echo "[schema] invalid .mcp.json: $f"; return 1; }
}

# Repo-root relative checks
if [ -f .claude/settings.json ]; then
  check_claude_settings .claude/settings.json || fail=1
fi
if [ -f .mcp.json ]; then
  check_mcp .mcp.json || fail=1
fi

exit $fail

