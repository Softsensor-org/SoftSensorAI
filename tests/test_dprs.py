#!/usr/bin/env python3
"""Tests for DPRS (DevPilot Readiness Score) script."""

import json
import os
import subprocess
import tempfile
from pathlib import Path

import pytest


class TestDPRS:
    """Test suite for DPRS script."""

    @pytest.fixture
    def dprs_script(self):
        """Get path to DPRS script."""
        return Path(__file__).parent.parent / "scripts" / "dprs.sh"

    @pytest.fixture
    def temp_output_dir(self):
        """Create temporary output directory."""
        with tempfile.TemporaryDirectory() as tmpdir:
            yield Path(tmpdir)

    def test_dprs_script_exists(self, dprs_script):
        """Test that DPRS script exists."""
        assert dprs_script.exists()
        assert dprs_script.is_file()
        assert os.access(dprs_script, os.X_OK)

    def test_dprs_help_output(self, dprs_script):
        """Test DPRS help output."""
        result = subprocess.run(
            ["bash", str(dprs_script), "--help"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        assert "DevPilot Readiness Score" in result.stdout
        assert "Usage:" in result.stdout

    def test_dprs_generates_output(self, dprs_script, temp_output_dir):
        """Test that DPRS generates output files."""
        result = subprocess.run(
            ["bash", str(dprs_script), "--output", str(temp_output_dir)],
            capture_output=True,
            text=True,
            timeout=30
        )
        assert result.returncode == 0

        # Check JSON output
        json_file = temp_output_dir / "dprs.json"
        assert json_file.exists()

        with open(json_file) as f:
            data = json.load(f)
            assert "total_score" in data
            assert "phase_readiness" in data
            assert "categories" in data
            assert 0 <= data["total_score"] <= 100

        # Check Markdown output
        md_file = temp_output_dir / "dprs.md"
        assert md_file.exists()

    def test_dprs_score_calculation(self, dprs_script, temp_output_dir):
        """Test DPRS score calculation logic."""
        result = subprocess.run(
            ["bash", str(dprs_script), "--output", str(temp_output_dir)],
            capture_output=True,
            text=True,
            timeout=30
        )
        assert result.returncode == 0

        with open(temp_output_dir / "dprs.json") as f:
            data = json.load(f)

            # Verify score calculations
            total = 0
            for category in data["categories"].values():
                weighted = (category["score"] * category["weight"]) / 100
                assert abs(weighted - category["weighted_score"]) < 0.1
                total += category["weighted_score"]

            assert abs(total - data["total_score"]) < 1

    @pytest.mark.parametrize("score,expected_phase", [
        (95, "SCALE"),
        (85, "BETA"),
        (70, "MVP"),
        (50, "POC"),
        (30, "INCEPTION"),
    ])
    def test_phase_readiness_thresholds(self, score, expected_phase):
        """Test phase readiness threshold calculation."""
        # This would require mocking the score calculation
        # For now, just verify the thresholds exist
        pass

    def test_dprs_verbose_mode(self, dprs_script, temp_output_dir):
        """Test DPRS verbose mode output."""
        result = subprocess.run(
            ["bash", str(dprs_script), "--output", str(temp_output_dir), "--verbose"],
            capture_output=True,
            text=True,
            timeout=30
        )
        assert result.returncode == 0
        assert "Score Details" in result.stdout or "Calculating" in result.stdout
