#!/usr/bin/env bash
# OS compatibility functions for cross-platform support

# Get OS codename (replacement for lsb_release -sc)
get_os_codename() {
  if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -sc
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "${VERSION_CODENAME:-${UBUNTU_CODENAME:-stable}}"
  elif [ "$(uname -s)" = "Darwin" ]; then
    echo "macos"
  elif [ "$(uname -s)" = "FreeBSD" ]; then
    echo "freebsd"
  elif [ "$(uname -s)" = "OpenBSD" ]; then
    echo "openbsd"
  elif [ "$(uname -s)" = "NetBSD" ]; then
    echo "netbsd"
  else
    echo "stable"
  fi
}

# Get architecture (replacement for dpkg --print-architecture)
get_arch() {
  local arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv7l|armhf) echo "armhf" ;;
    i386|i686) echo "i386" ;;
    *) echo "$arch" ;;
  esac
}

# Check if running in WSL
is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] || ([ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null)
}

# Get package manager
get_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v apk >/dev/null 2>&1; then
    echo "apk"
  elif command -v pkg >/dev/null 2>&1; then
    echo "pkg"
  elif command -v brew >/dev/null 2>&1; then
    echo "brew"
  else
    echo "unknown"
  fi
}

# Export functions if sourced
export -f get_os_codename
export -f get_arch
export -f is_wsl
export -f get_package_manager
