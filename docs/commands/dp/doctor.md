# dp doctor

## Overview

Comprehensive system health check that verifies your development environment is properly configured
for SoftSensorAI.

## Usage

```bash
dp doctor [OPTIONS]
```

## What It Does

Performs 15+ checks across:

- Operating system compatibility
- Required tools installation
- Optional tool availability
- Development environment setup
- Git configuration
- System resources

## Example Output

```bash
dp doctor

🏥 SoftSensorAI Health Check
========================

System Information:
✓ OS: Linux (Ubuntu 22.04)
✓ Shell: bash 5.1.16
✓ Architecture: x86_64

Required Tools:
✓ Git: 2.34.1
✓ Curl: 7.81.0
✓ Bash: 5.1.16

Development Tools:
✓ Node.js: 20.11.0
✓ Python: 3.10.12
✓ Docker: 24.0.5 (running)
⚠ Go: Not installed
⚠ Rust: Not installed

AI CLIs:
✓ Claude: 1.2.0
⚠ Gemini: Not installed
⚠ Grok: Not installed
✓ Codex: 0.9.1

Package Managers:
✓ npm: 10.2.4
✓ pnpm: 8.15.1
✓ pip: 23.3.1
⚠ cargo: Not installed

Search Tools:
✓ ripgrep: 14.1.0
✓ fd: 9.0.0
✓ fzf: 0.45.0

System Resources:
✓ Disk space: 42G available
✓ Memory: 16G total, 8G available
✓ CPU: 8 cores

GPU Detection:
✓ NVIDIA RTX 4090 (CUDA 12.2)

Summary:
✅ 18 passed | ⚠️ 5 warnings | ❌ 0 errors

All critical checks passed! Optional tools can be installed with:
  dp doctor --install-missing
```

## Options

- `--verbose` - Show detailed information for each check
- `--json` - Output results as JSON for automation
- `--install-missing` - Attempt to install missing tools
- `--required-only` - Only check required tools
- `--quick` - Skip slow checks (Docker, GPU detection)

## Check Categories

### Critical (Must Pass)

- Git installed and configured
- Bash 4.0+ available
- Curl/wget for downloads
- 2GB+ free disk space

### Recommended (Should Have)

- Node.js for JavaScript projects
- Python for Python projects
- Docker for containerization
- Package managers (npm, pip)

### Optional (Nice to Have)

- AI CLIs (claude, gemini, grok, codex)
- Search tools (ripgrep, fd, fzf)
- Language-specific tools (go, rust, ruby)
- GPU for ML workloads

## Platform-Specific Checks

### macOS

```bash
✓ Homebrew: 4.2.0
✓ Xcode CLT: Installed
✓ macOS: 14.2 (Sonoma)
```

### Windows (WSL)

```bash
✓ WSL: Version 2
✓ Distribution: Ubuntu-22.04
✓ Windows Build: 22631
```

### Linux

```bash
✓ Distribution: Ubuntu 22.04
✓ Kernel: 5.15.0
✓ Package Manager: apt
```

## Exit Codes

- `0` - All checks passed
- `1` - Critical failures
- `2` - Only warnings

## When to Use

- **Before installing SoftSensorAI** - Verify system compatibility
- **Troubleshooting issues** - Identify missing dependencies
- **CI/CD pipelines** - Validate environment
- **Team onboarding** - Ensure consistent setup
- **After system updates** - Verify nothing broke

## Automated Fixes

### Install Missing Tools

```bash
dp doctor --install-missing
# Attempts to install:
# - ripgrep, fd, fzf via package manager
# - Node.js via fnm
# - Python via system package manager
# - Docker via official script
```

### Fix Common Issues

```bash
# Git not configured
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Node.js missing
curl -fsSL https://fnm.vercel.app/install | bash
fnm use --install-if-missing 20

# Python missing
sudo apt update && sudo apt install python3 python3-pip
```

## Integration with dp init

`dp doctor` is automatically run as step 1 of `dp init`:

```bash
dp init
# Step 1/3: Running system health check... (this is dp doctor)
# Step 2/3: Configuring profile...
# Step 3/3: Building project...
```

## JSON Output Format

```bash
dp doctor --json
```

```json
{
  "status": "passed",
  "summary": {
    "passed": 18,
    "warnings": 5,
    "errors": 0
  },
  "checks": {
    "os": { "status": "passed", "value": "Linux" },
    "git": { "status": "passed", "version": "2.34.1" },
    "nodejs": { "status": "passed", "version": "20.11.0" },
    "python": { "status": "passed", "version": "3.10.12" },
    "go": { "status": "warning", "message": "Not installed" }
  }
}
```

## Troubleshooting

### "Permission denied"

```bash
# Some checks require sudo
sudo dp doctor
# Or skip those checks
dp doctor --quick
```

### "Package manager not found"

```bash
# The script will suggest the right package manager:
# Ubuntu/Debian: apt
# Fedora/RHEL: dnf
# Arch: pacman
# macOS: brew
```

### "WSL not detected on Windows"

```bash
# Ensure running in WSL terminal, not PowerShell
wsl --version
# Then run doctor inside WSL
```

## Related Commands

- [`dp init`](init.md) - Runs doctor as first step
- [`dp setup`](setup.md) - Add SoftSensorAI to project
- [`scripts/dprs.sh`](../../scripts/dprs.md) - Repository readiness score

## Implementation

- **Script**: `scripts/doctor.sh`
- **Called by**: `dp doctor` command
- **OS Detection**: `utils/os_compat.sh`
- **Platform Support**: Linux, macOS, WSL, BSD, Solaris
