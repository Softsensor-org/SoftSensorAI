# Task Locking Mechanism

## Overview

The task locking mechanism is implemented in the `ssai-agent` script to prevent concurrent operations
on the same task. It uses file-based locking with the `noclobber` option for atomic file creation to
ensure exclusive access to a task.

## Implementation

The locking mechanism is implemented in the `cmd_run` function of the `bin/ssai-agent` script:

```bash
# Add locking to prevent concurrent operations
local LOCK_DIR="$ART/agent/.locks"
mkdir -p "$LOCK_DIR"
local LOCK_FILE="$LOCK_DIR/${TASK_ID}.lock"

# Clean up lock on exit
trap 'rm -f "$LOCK_FILE"' EXIT

# Try to acquire lock (using noclobber for atomicity)
if ! (set -o noclobber; echo $$ > "$LOCK_FILE") 2>/dev/null; then
  local existing_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
  echo "error: Task $TASK_ID is already being processed (PID: $existing_pid)"
  echo "If this is stale, remove: $LOCK_FILE"
  exit 1
fi
```

## Key Components

1. **Lock Directory**: A dedicated directory `.locks` is created under the artifacts/agent directory
   to store lock files.
2. **Lock File**: Each task has a unique lock file named `<TASK_ID>.lock` containing the PID of the
   process that acquired the lock.
3. **Acquisition Mechanism**: The `noclobber` shell option is used to ensure atomic file creation.
   This ensures that only one process can create the lock file at a time.
4. **Lock Cleanup**: A trap is set to remove the lock file when the process exits, ensuring locks
   don't become stale if the process terminates normally.
5. **Contention Handling**: If a lock can't be acquired, the script reports which process (PID) is
   currently holding the lock.

## Test Cases

The following test cases were implemented to validate the locking mechanism:

1. **Normal Lock Acquisition**: Verifies that a lock can be successfully acquired when no other
   process holds it.
2. **Lock Contention**: Verifies that a lock cannot be acquired when another process already holds
   it.
3. **Lock Cleanup**: Verifies that locks are properly cleaned up when a process exits.
4. **Stale Locks**: Tests the behavior when encountering a stale lock file.
5. **Missing Lock Directory**: Verifies the behavior when the lock directory doesn't exist.

## Testing Approach

Testing the locking mechanism involves:

1. Simulating the lock acquisition and release process
2. Testing concurrent access scenarios
3. Verifying proper cleanup of lock files
4. Testing edge cases like stale locks and missing directories

## Future Improvements

1. **PID Validation**: Add a check to verify if the PID in a lock file is still active. If not, the
   lock could be considered stale and removed.
2. **Timeout Mechanism**: Implement a timeout for lock acquisition to prevent indefinite waiting.
3. **Distributed Locking**: For multi-server setups, consider a distributed locking mechanism (e.g.,
   Redis, etcd).
4. **Lock Metrics**: Track and log lock acquisition, contention, and release for monitoring.

## Conclusion

The current implementation provides a robust mechanism for preventing concurrent operations on the
same task. The use of file-based locking with the `noclobber` option ensures atomicity and
reliability within a single system.
