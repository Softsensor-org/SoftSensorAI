---
id: F-PALETTE
title: dp palette requires fzf
status: maintained
owner: system
version: 1.0.0
allowed_globs:
  - bin/dp
  - tests/contract/F-PALETTE/**
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST check for fzf availability
    text: Detects if fzf is installed before running
    tests:
      - tests/contract/F-PALETTE/fzf-check.test.sh
  - id: AC-2
    must: MUST print actionable install hint
    text: Shows platform-specific installation commands when fzf missing
    tests:
      - tests/contract/F-PALETTE/error-message.test.sh
  - id: AC-3
    must: MUST exit with non-zero code
    text: Returns exit code 1 when fzf is not available
    tests:
      - tests/contract/F-PALETTE/exit-code.test.sh
  - id: AC-4
    must: MUST have no side effects
    text: Does not create or modify any files when fzf is missing
    tests:
      - tests/contract/F-PALETTE/no-side-effects.test.sh
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: maintained
    notes: Dependency check preserved
---

# F-PALETTE: Command Palette with fzf

This contract ensures the `dp palette` command properly handles the fzf dependency requirement.

## Features

### Dependency Check
The command verifies fzf is installed before attempting to use it.

### Actionable Error Messages
When fzf is missing, provides platform-specific installation instructions:
- macOS: `brew install fzf`
- Ubuntu/Debian: `apt install fzf`
- Alternative: suggests `just commands` for non-interactive listing

### Clean Failure
- Exits with code 1 when fzf unavailable
- No file operations performed
- No partial state left behind

## How to Test

### Manual Testing
```bash
# Test with fzf missing (rename temporarily)
sudo mv $(which fzf) $(which fzf).bak 2>/dev/null || true
dp palette
# Should show error message and installation instructions

# Restore fzf
sudo mv $(which fzf).bak $(which fzf) 2>/dev/null || true

# Test with fzf present
dp palette
# Should launch interactive selector
```

### Automated Tests
```bash
# Run all touchpoint tests
bash tests/contract/F-PALETTE/fzf-check.test.sh
bash tests/contract/F-PALETTE/error-message.test.sh
bash tests/contract/F-PALETTE/exit-code.test.sh
bash tests/contract/F-PALETTE/no-side-effects.test.sh
```

## Expected Behavior

### When fzf Missing
```
⚠️  fzf not found. Install with:
  brew install fzf    # macOS
  apt install fzf     # Ubuntu/Debian

Or use: just commands  # to view command list
```
Exit code: 1

### When fzf Available
Launches interactive command palette with:
- Search/filter capability
- Command descriptions
- Category grouping
- Preview window (if configured)

## Implementation Notes

### Check Logic
```bash
if ! have fzf; then
    say "⚠️  fzf not found. Install with:"
    say "  brew install fzf    # macOS"
    say "  apt install fzf     # Ubuntu/Debian"
    say ""
    say "Or use: just commands  # to view command list"
    exit 1
fi
```

### No Side Effects
The command:
- Does not create `artifacts/palette_commands.txt` when fzf missing
- Does not generate command registry
- Does not modify any configuration files
- Simply exits cleanly with helpful message

## Platform Support

### macOS
- Homebrew: `brew install fzf`
- MacPorts: `port install fzf`

### Linux
- Debian/Ubuntu: `apt install fzf`
- Fedora: `dnf install fzf`
- Arch: `pacman -S fzf`

### Windows (WSL)
- Use Linux package manager in WSL
- Native Windows: `choco install fzf` or `scoop install fzf`

## Alternative Workflows

When fzf is not available or desired:
1. Use `just commands` for static list
2. Use `dp help --full` for all commands
3. Access commands directly: `dp <command>`

The palette is a convenience feature - all functionality remains accessible without it.