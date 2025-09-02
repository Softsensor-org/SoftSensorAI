#!/usr/bin/env python3
"""Tests for utility scripts."""

import os
import subprocess
from pathlib import Path

import pytest


class TestOSCompatibility:
    """Test OS compatibility utilities."""

    @pytest.fixture
    def os_compat_script(self):
        """Get path to os_compat.sh script."""
        return Path(__file__).parent.parent / "utils" / "os_compat.sh"

    def test_os_compat_script_exists(self, os_compat_script):
        """Test that OS compatibility script exists."""
        assert os_compat_script.exists()
        assert os_compat_script.is_file()

    def test_get_os_function(self, os_compat_script):
        """Test get_os function returns valid OS."""
        result = subprocess.run(
            ["bash", "-c", f"source {os_compat_script} && get_os"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() in ["macos", "linux", "windows", "bsd", "solaris", "alpine", "unknown"]

    def test_get_arch_function(self, os_compat_script):
        """Test get_arch function returns valid architecture."""
        result = subprocess.run(
            ["bash", "-c", f"source {os_compat_script} && get_arch"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert result.stdout.strip() in ["x86_64", "aarch64", "arm64", "x86", "unknown"]

    def test_get_package_manager(self, os_compat_script):
        """Test get_package_manager returns a package manager."""
        result = subprocess.run(
            ["bash", "-c", f"source {os_compat_script} && get_package_manager"],
            capture_output=True,
            text=True
        )
        # Should return something even if unknown
        assert result.returncode == 0
        assert len(result.stdout.strip()) > 0


class TestHelpers:
    """Test helper utilities."""

    @pytest.fixture
    def helpers_script(self):
        """Get path to helpers script."""
        return Path(__file__).parent.parent / "utils" / "helpers.sh"

    def test_helpers_script_exists(self, helpers_script):
        """Test that helpers script exists."""
        assert helpers_script.exists()
        assert helpers_script.is_file()

    def test_colors_defined(self, helpers_script):
        """Test that color variables are defined."""
        result = subprocess.run(
            ["bash", "-c", f"source {helpers_script} && echo $RED$GREEN$YELLOW$BLUE$NC"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0

    def test_ok_function(self, helpers_script):
        """Test ok function output."""
        result = subprocess.run(
            ["bash", "-c", f"source {helpers_script} && ok 'Test message'"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert "Test message" in result.stdout

    def test_error_function(self, helpers_script):
        """Test error function output."""
        result = subprocess.run(
            ["bash", "-c", f"source {helpers_script} && error 'Error message'"],
            capture_output=True,
            text=True
        )
        # error function might exit with non-zero
        assert "Error message" in result.stderr or "Error message" in result.stdout
