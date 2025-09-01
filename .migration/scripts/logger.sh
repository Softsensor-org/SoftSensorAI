#!/usr/bin/env bash
# DevPilot migration logger utilities

log() {
  local level="$1"
  shift
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "[$ts] [$level] $*" | tee -a .migration/logs/migration.log
}

log_info() { log INFO "$@"; }
log_warn() { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_success() { log SUCCESS "$@"; }

