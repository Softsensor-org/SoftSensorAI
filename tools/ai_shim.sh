#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Portable AI CLI shim: runs Claude/Codex/Gemini/Grok via installed CLIs.
# No raw API usage. Exits with the underlying CLI exit code, or 127 if not found.
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }
die() { echo "error: $*" >&2; exit 2; }

usage() {
  cat >&2 <<'USAGE'
Usage: tools/ai_shim.sh --provider <codex|claude|gemini|grok> --model <name> --prompt-file <file>
Env:
  TIMEOUT_SECS   Optional timeout (default 180)
Providers searched if selected CLI missing:
  claude: anthropic, claude
  gemini: gemini, vertex
  grok:   grok, openrouter (model will be prefixed with xai/)
USAGE
  exit 2
}

PROVIDER="" ; MODEL="" ; PROMPT_FILE=""
TIMEOUT_SECS="${TIMEOUT_SECS:-180}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --provider) PROVIDER="${2:?}"; shift 2;;
    --model) MODEL="${2:?}"; shift 2;;
    --prompt-file) PROMPT_FILE="${2:?}"; shift 2;;
    -h|--help) usage;;
    *) die "unknown arg: $1";;
  esac
done
[[ -n "$PROVIDER" && -n "$MODEL" && -f "$PROMPT_FILE" ]] || usage

# Portable timeout: gtimeout on macOS, timeout elsewhere; fall back to no timeout.
TIMEOUT_BIN="timeout"
if ! have timeout && have gtimeout; then TIMEOUT_BIN="gtimeout"; fi
run() { if have "$TIMEOUT_BIN"; then "$TIMEOUT_BIN" "$TIMEOUT_SECS" "$@"; else "$@"; fi; }

case "$PROVIDER" in
  codex)
    if have codex; then run codex exec --model "$MODEL" --input-file "$PROMPT_FILE"; exit $?; fi
    echo "codex CLI not found" >&2; exit 127
    ;;
  claude)
    if have anthropic; then run anthropic messages create --model "$MODEL" --input-file "$PROMPT_FILE"; exit $?; fi
    if have claude;    then run claude --model "$MODEL" < "$PROMPT_FILE"; exit $?; fi
    echo "Claude CLI not found (anthropic/claude)" >&2; exit 127
    ;;
  gemini)
    if have gemini; then run gemini generate --model "$MODEL" --prompt-file "$PROMPT_FILE"; exit $?; fi
    if have vertex; then run vertex ai generative-content --model "$MODEL" --content-file "$PROMPT_FILE"; exit $?; fi
    echo "Gemini CLI not found (gemini/vertex)" >&2; exit 127
    ;;
  grok)
    if have grok;       then run grok chat --model "$MODEL" --input-file "$PROMPT_FILE"; exit $?; fi
    if have openrouter; then run openrouter chat --model "xai/$MODEL" --input-file "$PROMPT_FILE"; exit $?; fi
    echo "Grok CLI not found (grok/openrouter)" >&2; exit 127
    ;;
  *) die "unknown provider: $PROVIDER";;
esac
