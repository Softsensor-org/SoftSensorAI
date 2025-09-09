# dp sandbox

Sandboxed code execution environment for safely running AI-generated code.

## Usage

```bash
dp sandbox [code-file]
```

## Description

The sandbox command provides a secure execution environment for testing code, particularly useful when working with AI-generated scripts that need validation before production use.

## Features

- Isolated execution environment
- Resource limits
- Timeout controls
- Safe testing of generated code

## Examples

```bash
# Run a script in sandbox
dp sandbox test_script.py

# Execute code with timeout
dp sandbox --timeout 30 compute.py
```

## Security

The sandbox uses various isolation techniques to prevent:
- File system access outside designated areas
- Network access (configurable)
- Resource exhaustion
- System modifications

## Notes

This command uses `codex_sandbox.sh` for the sandboxing implementation.