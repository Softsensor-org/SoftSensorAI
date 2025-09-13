#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Integration tests for SoftSensorAI setup scripts."""

import json
import os
import subprocess
import tempfile
from pathlib import Path

import pytest


@pytest.mark.integration
class TestIntegration:
    """Integration tests for the complete system."""

    def test_scripts_directory_structure(self):
        """Test that all expected scripts directories exist."""
        base_path = Path(__file__).parent.parent

        expected_dirs = [
            "scripts",
            "utils",
            "tools",
            "config",
            "docs",
            ".github/workflows",
            "tests"
        ]

        for dir_name in expected_dirs:
            dir_path = base_path / dir_name
            assert dir_path.exists(), f"Directory {dir_name} does not exist"
            assert dir_path.is_dir(), f"{dir_name} is not a directory"

    def test_critical_scripts_exist(self):
        """Test that critical scripts exist."""
        base_path = Path(__file__).parent.parent

        critical_scripts = [
            "scripts/dprs.sh",
            "scripts/doctor.sh",
            "utils/helpers.sh",
            "utils/os_compat.sh"
        ]

        for script in critical_scripts:
            script_path = base_path / script
            assert script_path.exists(), f"Script {script} does not exist"
            assert script_path.is_file(), f"{script} is not a file"

    def test_github_workflows_valid(self):
        """Test that GitHub workflow files are valid YAML."""
        import yaml

        workflows_dir = Path(__file__).parent.parent / ".github" / "workflows"

        for workflow_file in workflows_dir.glob("*.yml"):
            with open(workflow_file) as f:
                try:
                    yaml.safe_load(f)
                except yaml.YAMLError as e:
                    pytest.fail(f"Invalid YAML in {workflow_file}: {e}")

    @pytest.mark.slow
    def test_dprs_json_schema(self):
        """Test DPRS output follows expected schema."""
        script = Path(__file__).parent.parent / "scripts" / "dprs.sh"

        with tempfile.TemporaryDirectory() as tmpdir:
            result = subprocess.run(
                ["bash", str(script), "--output", tmpdir],
                capture_output=True,
                text=True,
                timeout=30
            )

            json_file = Path(tmpdir) / "dprs.json"
            assert json_file.exists()

            with open(json_file) as f:
                data = json.load(f)

                # Check required fields
                assert "repository" in data
                assert "total_score" in data
                assert "phase_readiness" in data
                assert "categories" in data

                # Check categories structure
                for category in ["tests", "security", "documentation", "developer_experience"]:
                    assert category in data["categories"]
                    assert "score" in data["categories"][category]
                    assert "weight" in data["categories"][category]
                    assert "weighted_score" in data["categories"][category]
