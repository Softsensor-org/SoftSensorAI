#!/usr/bin/env bash

# ============================================================================
# DevPilot Logging Utilities
# Provides consistent logging across all DevPilot scripts
# ============================================================================

# Color codes for terminal output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Timestamp function
_ts() { 
    date -u +%Y-%m-%dT%H:%M:%SZ
}

# Basic logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*" >&2
    fi
}

# Progress indicators
log_step() {
    echo -e "${BLUE}==>${NC} $*"
}

log_header() {
    echo -e "${BOLD}${MAGENTA}━━━ $* ━━━${NC}"
}

log_subheader() {
    echo -e "${BOLD}--- $* ---${NC}"
}

# Status indicators
log_start() {
    echo -en "${BLUE}⏳${NC} $*..."
}

log_done() {
    echo -e " ${GREEN}done${NC}"
}

log_failed() {
    echo -e " ${RED}failed${NC}"
}

# Pretty printing
log_list_item() {
    echo -e "  ${GREEN}•${NC} $*"
}

log_code() {
    echo -e "${CYAN}$*${NC}"
}

# File logging (if LOG_FILE is set)
log_to_file() {
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[$(_ts)] $*" >> "${LOG_FILE}"
    fi
}

# Combined logging (console + file)
log() {
    local level="${1:-INFO}"
    shift
    case "$level" in
        INFO)    log_info "$@" ;;
        WARN)    log_warn "$@" ;;
        ERROR)   log_error "$@" ;;
        SUCCESS) log_success "$@" ;;
        DEBUG)   log_debug "$@" ;;
        *)       echo "$@" ;;
    esac
    log_to_file "$level" "$@"
}

# Export functions for use in subshells
export -f _ts log_info log_warn log_error log_success log_debug
export -f log_step log_header log_subheader
export -f log_start log_done log_failed
export -f log_list_item log_code
export -f log_to_file log