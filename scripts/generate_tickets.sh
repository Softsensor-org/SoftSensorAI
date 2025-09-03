#!/usr/bin/env bash
# Legacy wrapper: generate_tickets -> dp tickets
# Maintained for backward compatibility

echo "Note: generate_tickets.sh is deprecated. Use 'dp tickets' directly." >&2
exec "$(dirname "${BASH_SOURCE[0]}")/../bin/dp" tickets "$@"
