#!/usr/bin/env bash
# Agent verification - aggregates build, test, lint results
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX_DIR="${SANDBOX_DIR:-$ROOT/../agent-sandbox}"

# Output JSON result
output_json() {
  local build_status="$1"
  local test_status="$2"
  local lint_status="$3"
  local security_status="$4"
  local overall_status="$5"

  cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "overall": "$overall_status",
  "checks": {
    "build": {
      "status": "$build_status",
      "command": "npm run build || make build"
    },
    "tests": {
      "status": "$test_status",
      "command": "npm test || pytest"
    },
    "lint": {
      "status": "$lint_status",
      "command": "npm run lint || ruff check"
    },
    "security": {
      "status": "$security_status",
      "command": "npm audit || safety check"
    }
  }
}
EOF
}

# Navigate to sandbox
if [[ ! -d "$SANDBOX_DIR" ]]; then
  output_json "skipped" "skipped" "skipped" "skipped" "error"
  exit 1
fi

cd "$SANDBOX_DIR"

# Initialize results
build_status="skipped"
test_status="skipped"
lint_status="skipped"
security_status="skipped"
overall_status="success"

# Check for Node.js project
if [[ -f package.json ]]; then
  # Build
  if npm run build >/dev/null 2>&1; then
    build_status="success"
  else
    build_status="failed"
    overall_status="failed"
  fi

  # Tests
  if npm test >/dev/null 2>&1; then
    test_status="success"
  else
    test_status="failed"
    overall_status="failed"
  fi

  # Lint
  if npm run lint >/dev/null 2>&1; then
    lint_status="success"
  elif npm run typecheck >/dev/null 2>&1; then
    lint_status="success"
  else
    lint_status="warning"
    [[ "$overall_status" == "success" ]] && overall_status="warning"
  fi

  # Security
  if npm audit --audit-level=high >/dev/null 2>&1; then
    security_status="success"
  else
    security_status="warning"
    [[ "$overall_status" == "success" ]] && overall_status="warning"
  fi
fi

# Check for Python project
if [[ -f requirements.txt ]] || [[ -f pyproject.toml ]]; then
  # Tests
  if pytest >/dev/null 2>&1; then
    test_status="success"
  elif python -m pytest >/dev/null 2>&1; then
    test_status="success"
  else
    test_status="failed"
    overall_status="failed"
  fi

  # Lint
  if ruff check . >/dev/null 2>&1; then
    lint_status="success"
  elif flake8 . >/dev/null 2>&1; then
    lint_status="success"
  else
    lint_status="warning"
    [[ "$overall_status" == "success" ]] && overall_status="warning"
  fi

  # Security
  if safety check >/dev/null 2>&1; then
    security_status="success"
  else
    security_status="warning"
    [[ "$overall_status" == "success" ]] && overall_status="warning"
  fi
fi

# Output results
output_json "$build_status" "$test_status" "$lint_status" "$security_status" "$overall_status"
