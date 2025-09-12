#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Legacy wrapper: after_clone -> dp init
# Maintained for backward compatibility

echo "Note: after_clone.sh is deprecated. Use 'dp init' directly." >&2
exec "$(dirname "${BASH_SOURCE[0]}")/../bin/dp" init "$@"
