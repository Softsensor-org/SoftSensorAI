#!/usr/bin/env bash
# Heuristic diff risk tagging: prints comma-separated tags (auth,db,infra,ml,security)
set -euo pipefail
BASE="${1:-origin/main}"
tmp="$(mktemp)"; git diff --name-only "$BASE"...HEAD > "$tmp" 2>/dev/null || true
tags=()
grep -Eq 'auth|jwt|oauth|session' "$tmp" && tags+=("auth")
grep -Eq 'schema|migration|sql|database|db/' "$tmp" && tags+=("db")
grep -Eq 'terraform|helm|k8s|docker|infra/' "$tmp" && tags+=("infra")
grep -Eq 'model|vision|ocr|ml/' "$tmp" && tags+=("ml")
grep -Eq 'encrypt|secret|policy|iam' "$tmp" && tags+=("security")
printf "%s\n" "$(IFS=,; echo "${tags[*]-}")"
rm -f "$tmp"
