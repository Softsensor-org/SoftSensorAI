#!/usr/bin/env bash
# Legacy wrapper: repo_review -> dp repo-review
# Maintained for backward compatibility

echo "Note: repo_review.sh is deprecated. Use 'dp repo-review' directly." >&2
exec "$(dirname "${BASH_SOURCE[0]}")/../bin/dp" repo-review "$@"
