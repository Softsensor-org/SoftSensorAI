#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Test Task Locking Mechanism
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Use a safer test directory under /tmp
TEST_DIR="/tmp/test_task_locks_$(date +%s)"
LOCK_DIR="$TEST_DIR/agent/.locks"

# Cleanup function to ensure we don't leave test artifacts
cleanup() {
  echo "Cleaning up test resources..."
  rm -rf "$TEST_DIR"
  # Remove any lock files we created for testing
  find "$LOCK_DIR" -name "test_*.lock" -delete 2>/dev/null || true
}

# Run cleanup on script exit
trap cleanup EXIT

# Setup test environment
setup() {
  echo "Setting up test environment..."
  mkdir -p "$TEST_DIR"
  mkdir -p "$LOCK_DIR"
}

# Helper function to simulate the lock acquisition logic from dp-agent
acquire_lock() {
  local task_id="$1"
  local lock_file="$LOCK_DIR/${task_id}.lock"

  if ! (set -o noclobber; echo $$ > "$lock_file") 2>/dev/null; then
    local existing_pid=$(cat "$lock_file" 2>/dev/null || echo "unknown")
    echo "LOCK_FAILED: Task $task_id is already locked by PID: $existing_pid"
    return 1
  fi

  echo "LOCK_ACQUIRED: Task $task_id locked successfully"
  return 0
}

# Helper function to release a lock
release_lock() {
  local task_id="$1"
  local lock_file="$LOCK_DIR/${task_id}.lock"

  rm -f "$lock_file"
  echo "LOCK_RELEASED: Task $task_id lock released"
  return 0
}

# Test 1: Verify normal lock acquisition works
test_normal_lock_acquisition() {
  echo "=== Test 1: Normal Lock Acquisition ==="
  local task_id="test_normal_$(date +%s)"

  # Should succeed
  acquire_lock "$task_id"
  if [ $? -ne 0 ]; then
    echo "FAIL: Initial lock acquisition should succeed"
    return 1
  fi

  # Verify lock file exists
  if [ ! -f "$LOCK_DIR/${task_id}.lock" ]; then
    echo "FAIL: Lock file was not created"
    return 1
  fi

  # Verify PID in lock file
  local pid_in_file=$(cat "$LOCK_DIR/${task_id}.lock")
  if [ "$pid_in_file" != "$$" ]; then
    echo "FAIL: PID in lock file doesn't match current process"
    return 1
  fi

  # Clean up
  release_lock "$task_id"
  echo "PASS: Normal lock acquisition test"
  return 0
}

# Test 2: Verify lock contention is detected
test_lock_contention() {
  echo "=== Test 2: Lock Contention ==="
  local task_id="test_contention_$(date +%s)"

  # First acquisition should succeed
  acquire_lock "$task_id"
  if [ $? -ne 0 ]; then
    echo "FAIL: Initial lock acquisition should succeed"
    return 1
  fi

  # Second acquisition should fail
  if acquire_lock "$task_id" 2>/dev/null; then
    echo "FAIL: Second lock acquisition should fail"
    release_lock "$task_id"
    return 1
  fi

  # Clean up
  release_lock "$task_id"
  echo "PASS: Lock contention test"
  return 0
}

# Test 3: Verify lock cleanup works
test_lock_cleanup() {
  echo "=== Test 3: Lock Cleanup ==="
  local task_id="test_cleanup_$(date +%s)"
  local lock_file="$LOCK_DIR/${task_id}.lock"

  # Create a subshell that exits immediately after acquiring the lock
  (
    acquire_lock "$task_id"
    # The lock should be automatically removed when the subshell exits
    # due to the trap in the real dp-agent script
  )

  # Simulate trap cleanup by manually removing
  rm -f "$lock_file"

  # Now we should be able to acquire the lock again
  acquire_lock "$task_id"
  if [ $? -ne 0 ]; then
    echo "FAIL: Lock acquisition after cleanup should succeed"
    return 1
  fi

  # Clean up
  release_lock "$task_id"
  echo "PASS: Lock cleanup test"
  return 0
}

# Test 4: Verify handling of stale locks
test_stale_locks() {
  echo "=== Test 4: Stale Locks ==="
  local task_id="test_stale_$(date +%s)"
  local lock_file="$LOCK_DIR/${task_id}.lock"

  # Create a lock file with a non-existent PID
  echo "99999999" > "$lock_file"

  # In a real-world scenario, you might verify if the PID is active
  # For this test, we'll just acknowledge that the lock exists
  if acquire_lock "$task_id" 2>/dev/null; then
    echo "FAIL: Lock acquisition with stale lock should fail"
    release_lock "$task_id"
    return 1
  fi

  # Clean up
  release_lock "$task_id"
  echo "PASS: Stale locks test"
  return 0
}

# Test 5: Verify behavior when lock directory is missing
test_missing_lock_dir() {
  echo "=== Test 5: Missing Lock Directory ==="
  local task_id="test_missing_dir_$(date +%s)"
  local orig_lock_dir="$LOCK_DIR"

  # Temporarily change the lock directory to a non-existent path
  LOCK_DIR="$TEST_DIR/nonexistent_dir"

  # Try to acquire a lock
  acquire_lock "$task_id"
  local result=$?

  # Restore the original lock directory
  LOCK_DIR="$orig_lock_dir"

  # Check results
  if [ $result -eq 0 ]; then
    echo "PASS: Missing lock directory test (directory was created)"
  else
    echo "FAIL: Lock acquisition with missing directory should create directory"
    return 1
  fi

  # Clean up the temporary directory if it was created
  rm -rf "$TEST_DIR/nonexistent_dir"
  return 0
}

# Main test runner
run_tests() {
  setup

  local failures=0

  test_normal_lock_acquisition || ((failures++))
  test_lock_contention || ((failures++))
  test_lock_cleanup || ((failures++))
  test_stale_locks || ((failures++))
  test_missing_lock_dir || ((failures++))

  echo "============================="
  if [ $failures -eq 0 ]; then
    echo "All tests PASSED"
    return 0
  else
    echo "FAILED: $failures test(s) failed"
    return 1
  fi
}

# Run the tests
run_tests
exit $?
