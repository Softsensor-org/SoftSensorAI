#!/usr/bin/env bash
# Extract and format preview logs for AI review context
# Usage: preview_logs.sh [lines] [format]
set -euo pipefail

LINES="${1:-200}"
FORMAT="${2:-context}"  # context, errors, or full
PREVIEW_ID="${PREVIEW_ID:-local}"

# Find compose file
COMPOSE_FILE=""
for cf in compose.preview.yml docker-compose.preview.yml docker-compose.yml; do
  if [[ -f "$cf" ]]; then
    COMPOSE_FILE="$cf"
    break
  fi
done

# Helper to get logs from various sources
get_logs() {
  local service="${1:-app}"
  local lines="${2:-$LINES}"

  # Try compose first
  if [[ -n "$COMPOSE_FILE" ]]; then
    docker-compose -f "$COMPOSE_FILE" logs --tail="$lines" "$service" 2>/dev/null || true
  fi

  # Try direct docker
  if docker ps -q -f "name=preview-${service}-${PREVIEW_ID}" > /dev/null 2>&1; then
    docker logs "preview-${service}-${PREVIEW_ID}" --tail="$lines" 2>&1 || true
  elif docker ps -q -f "name=${service}" > /dev/null 2>&1; then
    docker logs "$service" --tail="$lines" 2>&1 || true
  fi
}

# Extract based on format
case "$FORMAT" in
  context)
    # Focused context for AI review
    echo "=== Preview Environment Logs (Last $LINES lines) ==="
    echo ""

    # Application logs
    echo "--- Application ---"
    get_logs "app" "$LINES" | grep -E "(ERROR|WARN|Exception|Failed|Error:|Warning:)" | tail -20 || echo "No errors/warnings"
    echo ""

    # Recent activity
    echo "--- Recent Activity ---"
    get_logs "app" 50 | grep -E "(GET|POST|PUT|DELETE|PATCH) /" | tail -10 || echo "No HTTP activity"
    echo ""

    # Database queries (if any)
    echo "--- Database ---"
    get_logs "db" 30 | grep -E "(ERROR|FATAL|WARNING|slow query)" | tail -10 || echo "No DB issues"
    echo ""

    # Performance metrics
    echo "--- Performance ---"
    get_logs "app" 100 | grep -E "(ms|seconds|latency|duration|took)" | tail -5 || echo "No timing data"
    ;;

  errors)
    # Only errors and warnings
    echo "=== Errors and Warnings ==="

    # Collect all error-like patterns
    {
      get_logs "app" "$LINES"
      get_logs "db" "$LINES"
      get_logs "cache" "$LINES"
    } 2>/dev/null | grep -E "(ERROR|FATAL|CRITICAL|Exception|Traceback|panic|segfault|core dumped|Failed|Failure|Error:|WARN|Warning:)" | \
    sort | uniq | tail -50

    if [[ ${PIPESTATUS[1]} -ne 0 ]]; then
      echo "No errors or warnings found"
    fi
    ;;

  full)
    # Full logs for debugging
    echo "=== Full Preview Logs (Last $LINES lines) ==="

    for service in app db cache mock-api; do
      echo ""
      echo "--- Service: $service ---"
      get_logs "$service" "$LINES"
    done
    ;;

  health)
    # Health check summary
    echo "=== Preview Health Status ==="
    echo ""

    # Check running containers
    if [[ -n "$COMPOSE_FILE" ]]; then
      docker-compose -f "$COMPOSE_FILE" ps 2>/dev/null || docker ps -f "name=preview-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
      docker ps -f "name=preview-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    fi

    echo ""
    echo "=== Recent Issues ==="
    get_logs "app" 100 | grep -E "(ERROR|Exception|Failed)" | tail -5 || echo "✅ No recent errors"
    ;;

  *)
    echo "Unknown format: $FORMAT" >&2
    echo "Available formats: context, errors, full, health" >&2
    exit 1
    ;;
esac

# Add summary if errors found
if [[ "$FORMAT" == "context" ]] || [[ "$FORMAT" == "errors" ]]; then
  ERROR_COUNT=$(get_logs "app" "$LINES" 2>/dev/null | grep -cE "(ERROR|Exception|Failed)" || echo 0)
  WARN_COUNT=$(get_logs "app" "$LINES" 2>/dev/null | grep -cE "(WARN|Warning)" || echo 0)

  echo ""
  echo "=== Summary ==="
  echo "Errors: $ERROR_COUNT"
  echo "Warnings: $WARN_COUNT"

  if [[ "$ERROR_COUNT" -gt 0 ]]; then
    echo "⚠️  Preview environment has errors - review logs above"
  elif [[ "$WARN_COUNT" -gt 0 ]]; then
    echo "⚡ Preview has warnings but is functional"
  else
    echo "✅ Preview environment appears healthy"
  fi
fi
