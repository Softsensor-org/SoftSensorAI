#!/usr/bin/env bash
set -euo pipefail
source .migration/scripts/logger.sh

FLAGS_FILE=".migration/state/flags.json"

setup_feature_flags() {
  mkdir -p .migration/state
  cat > "$FLAGS_FILE" << 'JSON'
{
  "canary": {
    "enabled": false,
    "percent": 10
  }
}
JSON
  log_success "Feature flags initialized: $FLAGS_FILE"
}

create_canary_router() {
  cat > devpilot-canary << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

FLAGS_FILE=".migration/state/flags.json"
ROUTE="stable"
if command -v jq >/dev/null 2>&1 && [[ -f "$FLAGS_FILE" ]]; then
  enabled=$(jq -r '.canary.enabled' "$FLAGS_FILE" 2>/dev/null || echo false)
  percent=$(jq -r '.canary.percent' "$FLAGS_FILE" 2>/dev/null || echo 0)
  if [[ "$enabled" == "true" ]]; then
    r=$((RANDOM % 100))
    if [[ $r -lt ${percent:-0} ]]; then ROUTE="canary"; fi
  fi
fi

exec ./devpilot-new/devpilot "$@"
EOF
  chmod +x devpilot-canary
  log_success "Canary router created"
}

setup_monitoring_stub() {
  cat > .migration/scripts/monitor.sh << 'EOF'
#!/usr/bin/env bash
# Stub monitor: reads metrics.jsonl if present and prints summary
file=".migration/logs/metrics.jsonl"
[[ -f "$file" ]] || { echo "No metrics file yet"; exit 0; }
lines=$(wc -l < "$file")
echo "Metrics lines: $lines"
EOF
  chmod +x .migration/scripts/monitor.sh
  log_success "Monitoring stub created"
}

main() {
  setup_feature_flags
  create_canary_router
  setup_monitoring_stub
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

