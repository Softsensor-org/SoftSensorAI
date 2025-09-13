#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Brand compatibility: SoftSensorAI ↔ SoftSensorAI
# Always source this early inside bin/dp and other entrypoints.
# Env mapping (new takes precedence; old kept for compat):
: "${SOFTSENSORAI_ROOT:=${SOFTSENSORAI_ROOT:-}}"
: "${SOFTSENSORAI_USER_DIR:=${SOFTSENSORAI_USER_DIR:-}}"
: "${SOFTSENSORAI_ARTIFACTS:=${SOFTSENSORAI_ARTIFACTS:-}}"

# Back-fill old envs if only new is set (for callers that still read SOFTSENSORAI_*):
export SOFTSENSORAI_ROOT="${SOFTSENSORAI_ROOT:-$SOFTSENSORAI_ROOT}"
export SOFTSENSORAI_USER_DIR="${SOFTSENSORAI_USER_DIR:-$SOFTSENSORAI_USER_DIR}"
export SOFTSENSORAI_ARTIFACTS="${SOFTSENSORAI_ARTIFACTS:-$SOFTSENSORAI_ARTIFACTS}"

# Resolve brand root (repo-local vs multi-user)
brand_resolve_root() {
  if [ -f "/opt/softsensorai/etc/softsensorai.conf" ] || [ -f "/opt/softsensorai/etc/softsensorai.conf" ]; then
    # Prefer SoftSensorAI conf if present
    if [ -f "/opt/softsensorai/etc/softsensorai.conf" ]; then
      # shellcheck disable=SC1091
      . /opt/softsensorai/etc/softsensorai.conf
      echo "${SOFTSENSORAI_ROOT:-/opt/softsensorai}"
    else
      # shellcheck disable=SC1091
      . /opt/softsensorai/etc/softsensorai.conf
      echo "${SOFTSENSORAI_ROOT:-/opt/softsensorai}"
    fi
  else
    git rev-parse --show-toplevel 2>/dev/null || pwd
  fi
}

brand_resolve_artifacts() {
  local root_user="${SOFTSENSORAI_USER_DIR:-$SOFTSENSORAI_USER_DIR}"
  if [ -n "$root_user" ]; then
    echo "${SOFTSENSORAI_ARTIFACTS:-$SOFTSENSORAI_ARTIFACTS:-$root_user/artifacts}"
  else
    echo "./artifacts"
  fi
}
