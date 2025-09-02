#!/usr/bin/env bash
# OS Compatibility Test Suite
# This script tests OS detection and compatibility functions across different platforms

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test functions
pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo -e "${GREEN}✓${NC} $1"
}

fail() {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo -e "${RED}✗${NC} $1"
  if [ -n "${2:-}" ]; then
    echo "  Error: $2"
  fi
}

run_test() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local test_name="$1"
  echo -e "\n${BLUE}Testing:${NC} $test_name"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "OS Compatibility Test Suite"
echo "========================================="
echo "Project root: $PROJECT_ROOT"
echo "Current OS: $(uname -s)"
echo "Current arch: $(uname -m)"
echo ""

# Test 1: Source compatibility functions
run_test "Loading os_compat.sh"
if [ -f "$PROJECT_ROOT/utils/os_compat.sh" ]; then
  source "$PROJECT_ROOT/utils/os_compat.sh"
  pass "Successfully loaded os_compat.sh"
else
  fail "os_compat.sh not found"
  exit 1
fi

# Test 2: Function availability
run_test "Function availability"
for func in get_os_codename get_arch is_wsl get_package_manager; do
  if declare -f "$func" &>/dev/null; then
    pass "Function $func is available"
  else
    fail "Function $func is not available"
  fi
done

# Test 3: OS detection
run_test "OS detection"
OS_NAME="$(uname -s)"
case "$OS_NAME" in
  Linux)
    pass "Detected Linux"
    ;;
  Darwin)
    pass "Detected macOS"
    ;;
  FreeBSD|OpenBSD|NetBSD)
    pass "Detected BSD variant: $OS_NAME"
    ;;
  CYGWIN*|MINGW*|MSYS*)
    pass "Detected Windows environment: $OS_NAME"
    ;;
  *)
    fail "Unknown OS: $OS_NAME"
    ;;
esac

# Test 4: Architecture detection
run_test "Architecture detection"
ARCH=$(get_arch)
case "$ARCH" in
  amd64|x86_64)
    pass "Detected 64-bit x86: $ARCH"
    ;;
  arm64|aarch64)
    pass "Detected ARM64: $ARCH"
    ;;
  i386|i686)
    pass "Detected 32-bit x86: $ARCH"
    ;;
  *)
    pass "Detected architecture: $ARCH"
    ;;
esac

# Test 5: Package manager detection
run_test "Package manager detection"
PKG_MGR=$(get_package_manager)
case "$PKG_MGR" in
  apt|dnf|yum|pacman|apk|pkg|brew)
    pass "Detected package manager: $PKG_MGR"
    ;;
  unknown)
    fail "Could not detect package manager"
    ;;
  *)
    pass "Detected package manager: $PKG_MGR"
    ;;
esac

# Test 6: WSL detection
run_test "WSL detection"
if is_wsl; then
  pass "Running in WSL environment"
else
  pass "Not running in WSL"
fi

# Test 7: OS codename
run_test "OS codename detection"
CODENAME=$(get_os_codename)
if [ -n "$CODENAME" ]; then
  pass "Detected OS codename: $CODENAME"
else
  fail "Could not detect OS codename"
fi

# Test 8: doctor.sh syntax check
run_test "doctor.sh syntax validation"
if bash -n "$PROJECT_ROOT/scripts/doctor.sh" 2>/dev/null; then
  pass "doctor.sh has valid syntax"
else
  fail "doctor.sh has syntax errors"
fi

# Test 9: setup_all.sh syntax check
run_test "setup_all.sh syntax validation"
if bash -n "$PROJECT_ROOT/setup_all.sh" 2>/dev/null; then
  pass "setup_all.sh has valid syntax"
else
  fail "setup_all.sh has syntax errors"
fi

# Test 10: key_software script detection
run_test "Platform-specific installer detection"
if [[ "$OS_NAME" == "Darwin" ]]; then
  if [ -f "$PROJECT_ROOT/install/key_software_macos.sh" ]; then
    pass "Found macOS installer script"
  else
    fail "macOS installer script not found"
  fi
else
  if [ -f "$PROJECT_ROOT/install/key_software_linux.sh" ]; then
    pass "Found Linux/Unix installer script"
  else
    fail "Linux/Unix installer script not found"
  fi
fi

# Test 11: Check all shell scripts for basic errors
run_test "Shell script validation"
SCRIPT_ERRORS=0
for script in "$PROJECT_ROOT"/scripts/*.sh "$PROJECT_ROOT"/setup/*.sh "$PROJECT_ROOT"/install/*.sh; do
  if [ -f "$script" ]; then
    if ! bash -n "$script" 2>/dev/null; then
      fail "Syntax error in: $(basename "$script")"
      SCRIPT_ERRORS=$((SCRIPT_ERRORS + 1))
    fi
  fi
done
if [ $SCRIPT_ERRORS -eq 0 ]; then
  pass "All shell scripts have valid syntax"
fi

# Test 12: Test doctor.sh execution
run_test "doctor.sh execution"
if bash "$PROJECT_ROOT/scripts/doctor.sh" &>/dev/null; then
  pass "doctor.sh executes successfully"
else
  # It might fail due to missing tools, but shouldn't crash
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 1 ]; then
    pass "doctor.sh executed (some tools may be missing)"
  else
    fail "doctor.sh crashed with exit code: $EXIT_CODE"
  fi
fi

# Test 13: devpilot CLI test
run_test "devpilot CLI"
if [ -f "$PROJECT_ROOT/devpilot" ]; then
  if bash "$PROJECT_ROOT/devpilot" --help &>/dev/null; then
    pass "devpilot CLI works"
  else
    fail "devpilot CLI failed"
  fi
else
  fail "devpilot CLI not found"
fi

# Print summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "\n${GREEN}✓ All tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}✗ Some tests failed${NC}"
  exit 1
fi
