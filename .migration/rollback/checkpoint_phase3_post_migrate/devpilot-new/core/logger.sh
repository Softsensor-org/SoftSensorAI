#!/usr/bin/env bash

_ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
log_info()    { echo "[$(_ts)] [INFO] $*"; }
log_warn()    { echo "[$(_ts)] [WARN] $*" >&2; }
log_error()   { echo "[$(_ts)] [ERROR] $*" >&2; }
log_success() { echo "[$(_ts)] [SUCCESS] $*"; }

