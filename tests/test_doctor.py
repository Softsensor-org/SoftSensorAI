#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Tests for doctor.sh script."""

import subprocess
from pathlib import Path

import pytest


class TestDoctor:
    """Test suite for doctor.sh script."""

    @pytest.fixture
    def doctor_script(self):
        """Get path to doctor script."""
        return Path(__file__).parent.parent / "scripts" / "doctor.sh"

    def test_doctor_script_exists(self, doctor_script):
        """Test that doctor script exists."""
        assert doctor_script.exists()
        assert doctor_script.is_file()

    def test_doctor_runs_without_error(self, doctor_script):
        """Test that doctor script runs without critical errors."""
        # Run in check mode without making changes
        result = subprocess.run(
            ["bash", str(doctor_script), "--check"],
            capture_output=True,
            text=True,
            timeout=60
        )
        # May have non-zero exit if issues found, but shouldn't crash
        assert "Checking system" in result.stdout or "SoftSensorAI" in result.stdout

    @pytest.mark.slow
    def test_doctor_verbose_mode(self, doctor_script):
        """Test doctor verbose mode."""
        result = subprocess.run(
            ["bash", str(doctor_script), "--verbose", "--check"],
            capture_output=True,
            text=True,
            timeout=60
        )
        # Should have more output in verbose mode
        assert len(result.stdout) > 100
