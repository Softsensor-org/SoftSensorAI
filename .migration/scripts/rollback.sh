#!/usr/bin/env bash
set -euo pipefail
source .migration/scripts/logger.sh

rollback_to_checkpoint() {
  local checkpoint="${1:-latest}"
  log_warn "Initiating rollback to checkpoint: $checkpoint"

  if [[ "$checkpoint" == "latest" ]]; then
    local last
    last=$(tail -n1 .migration/state/checkpoints.txt 2>/dev/null || true)
    [[ -n "$last" ]] && checkpoint="$last" || { log_error "No checkpoints found"; return 1; }
  fi

  local dir=".migration/rollback/checkpoint_$checkpoint"
  [[ -d "$dir" ]] || { log_error "Checkpoint not found: $checkpoint"; return 1; }

  rm -rf devpilot-new
  cp -r "$dir/devpilot-new" ./
  log_success "Rollback complete: $checkpoint"
}

emergency_rollback() {
  log_error "EMERGENCY ROLLBACK INITIATED"
  rm -rf devpilot-new devpilot
  git checkout -- *.sh 2>/dev/null || true
  log_success "Emergency rollback basic cleanup complete"
}

usage() {
  echo "Usage: $0 [checkpoint|latest] | --emergency"
}

main() {
  case "${1:-}" in
    --emergency) emergency_rollback ;;
    -h|--help|"") usage ;;
    *) rollback_to_checkpoint "$1" ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

