# OS Compatibility Guide

## Supported Operating Systems

DevPilot has been tested and verified to work on the following platforms:

### Tier 1 - Full Support

These platforms are actively tested in CI and fully supported:

- **Linux**

  - Ubuntu (20.04, 22.04, latest)
  - Debian (stable, testing)
  - Fedora (latest)
  - RHEL/CentOS/Rocky Linux (8+)
  - Arch Linux
  - Alpine Linux

- **macOS**

  - macOS 12+ (Intel)
  - macOS 13+ (Apple Silicon M1/M2/M3)

- **Windows**
  - Windows 10/11 via WSL2 (recommended)
  - Limited support for Cygwin/MinGW/MSYS

### Tier 2 - Community Support

These platforms should work but are tested via containers/simulation:

- **BSD Systems**

  - FreeBSD 12+
  - OpenBSD 7+
  - NetBSD 9+

- **Other Unix**
  - Solaris 11
  - illumos distributions

### Cloud/Container Environments

Full support for:

- Docker containers
- GitHub Codespaces
- VS Code Remote Containers
- GitPod
- Cloud9
- Coder

## CI Testing Matrix

Our GitHub Actions workflow tests on:

### Native OS Tests

- Ubuntu: 20.04, 22.04, latest
- macOS: latest (ARM), 13 (Intel), 14 (ARM)
- Windows: latest (with WSL)

### Container Tests

- Debian: latest
- Ubuntu: latest
- Fedora: latest
- Alpine: latest
- Arch Linux: latest
- Rocky Linux: 9

### Test Coverage

Each platform is tested for:

1. OS detection and identification
2. Package manager detection
3. Architecture detection (x86_64, arm64, etc.)
4. Core script execution (doctor.sh, setup_all.sh)
5. DevPilot CLI functionality
6. Installation script compatibility
7. Shell script syntax validation

## Running OS Compatibility Tests

### Locally

```bash
# Run the full test suite
./tests/test_os_compatibility.sh

# Run doctor.sh to check your system
./scripts/doctor.sh
```

### In CI

The tests run automatically on:

- Every push to main/develop branches
- Every pull request
- Manual workflow dispatch

View results in the GitHub Actions tab under "OS Compatibility Tests" workflow.

## Platform-Specific Notes

### macOS

- Requires Homebrew for package installation
- Bash 4+ recommended (install via `brew install bash`)
- Some GNU tools may need installation (`brew install coreutils`)

### Windows (WSL)

- WSL2 recommended over WSL1
- Ubuntu or Debian WSL distributions work best
- Native Windows terminals have limited support

### BSD Systems

- Package managers: pkg (FreeBSD), pkg_add (OpenBSD/NetBSD)
- Some GNU tools may need installation
- Bash required (not default shell on some BSDs)

### Alpine Linux

- Uses musl libc instead of glibc
- Package manager: apk
- Bash needs explicit installation: `apk add bash`

## Troubleshooting

### Common Issues

**"Command not found" errors**

- Run `./scripts/doctor.sh` to identify missing tools
- Follow the installation suggestions provided

**"/proc/version: No such file or directory"**

- This is normal on macOS/BSD - the scripts handle this gracefully
- Update to the latest version if you see errors

**Package manager not detected**

- The scripts support: apt, dnf, yum, pacman, apk, pkg, brew
- For unsupported package managers, install tools manually

**Script syntax errors**

- Ensure you have bash 4+ installed
- Run: `bash --version` to check

### Getting Help

1. Run diagnostic: `./scripts/doctor.sh`
2. Check test results: `./tests/test_os_compatibility.sh`
3. View CI logs: Check GitHub Actions for detailed error messages
4. Report issues: https://github.com/Softsensor-org/DevPilot/issues

## Contributing

To add support for a new OS:

1. Update `utils/os_compat.sh` with detection logic
2. Add package manager support in `install/key_software_linux.sh`
3. Update `scripts/doctor.sh` with installation commands
4. Add to CI matrix in `.github/workflows/os-compatibility.yml`
5. Run tests: `./tests/test_os_compatibility.sh`
6. Submit a pull request

## Compatibility Matrix

| Feature      | Linux | macOS | Windows (WSL) | BSD | Alpine | Solaris |
| ------------ | ----- | ----- | ------------- | --- | ------ | ------- |
| doctor.sh    | ✅    | ✅    | ✅            | ✅  | ✅     | ✅      |
| setup_all.sh | ✅    | ✅    | ✅            | ✅  | ✅     | ⚠️      |
| devpilot CLI | ✅    | ✅    | ✅            | ✅  | ✅     | ✅      |
| Auto-install | ✅    | ✅    | ✅            | ⚠️  | ✅     | ⚠️      |
| Git hooks    | ✅    | ✅    | ✅            | ✅  | ✅     | ✅      |
| AI CLIs      | ✅    | ✅    | ✅            | ⚠️  | ⚠️     | ⚠️      |

Legend:

- ✅ Full support
- ⚠️ Partial support / manual installation may be required
- ❌ Not supported

Last updated: December 2024
