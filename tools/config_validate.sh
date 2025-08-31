#!/usr/bin/env bash
set -euo pipefail

fail=0
SCHEMA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/schemas"

use_ajv=0
if command -v ajv >/dev/null 2>&1; then
  use_ajv=1
fi

check_claude_settings() {
  local f="$1"
  if [ $use_ajv -eq 1 ]; then
    ajv validate -s "$SCHEMA_DIR/claude-settings.schema.json" -d "$f" >/dev/null 2>&1 || {
      echo "[schema] invalid .claude/settings.json: $f"; return 1; }
  else
    jq -e 'has("permissions") and (.permissions|has("allow") and has("ask") and has("deny") and has("defaultMode")) and (.permissions.allow|type=="array") and (.permissions.ask|type=="array") and (.permissions.deny|type=="array") and (.permissions.defaultMode|type=="string")' "$f" >/dev/null || {
      echo "[schema] invalid .claude/settings.json: $f"; return 1; }
  fi
}

check_mcp() {
  local f="$1"
  if [ $use_ajv -eq 1 ]; then
    ajv validate -s "$SCHEMA_DIR/mcp.schema.json" -d "$f" >/dev/null 2>&1 || {
      echo "[schema] invalid .mcp.json: $f"; return 1; }
  else
    jq -e 'has("mcpServers") and (.mcpServers|type=="object")' "$f" >/dev/null || {
      echo "[schema] invalid .mcp.json: $f"; return 1; }
  fi
}

# Repo-root relative checks
if [ -f .claude/settings.json ]; then
  check_claude_settings .claude/settings.json || fail=1
fi
if [ -f .mcp.json ]; then
  check_mcp .mcp.json || fail=1
fi

exit $fail
