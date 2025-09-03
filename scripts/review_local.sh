#!/usr/bin/env bash
# Legacy wrapper: review_local -> dp review
# Maintained for backward compatibility

echo "Note: review_local.sh is deprecated. Use 'dp review' directly." >&2
exec "$(dirname "${BASH_SOURCE[0]}")/../bin/dp" review "$@"
