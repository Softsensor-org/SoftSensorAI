# 🔒 Security Guide

Best practices and security features in DevPilot for safe AI development.

## Table of Contents

- [Overview](#overview)
- [Checksum Verification](#checksum-verification)
- [API Key Management](#api-key-management)
- [Sandboxed Execution](#sandboxed-execution)
- [Security Scanning](#security-scanning)
- [Best Practices](#best-practices)

## Overview

DevPilot implements multiple layers of security to protect your development environment:

1. **Download Verification** - Checksums for all downloaded tools
2. **Secret Management** - Secure API key handling
3. **Sandboxed Execution** - Isolated code execution for AI-generated code
4. **Security Scanning** - Automated vulnerability detection
5. **Access Control** - Persona-based permissions

## Checksum Verification

### Why Checksum Verification?

Checksum verification ensures downloaded files haven't been tampered with or corrupted during
transfer.

### Basic Usage

```bash
# Source the verification utilities
source utils/checksum_verify.sh

# Download and verify a file
download_and_verify \
  "https://example.com/tool.tar.gz" \
  "/tmp/tool.tar.gz" \
  "abc123def456..." \
  "sha256"
```

### Verification Functions

#### `download_and_verify()`

Downloads a file and verifies its checksum:

```bash
download_and_verify <url> <output_file> [checksum] [algorithm]
```

Parameters:

- `url`: Download URL
- `output_file`: Where to save the file
- `checksum`: Expected checksum (optional, warns if missing)
- `algorithm`: Hash algorithm (default: sha256)

Example:

```bash
# Download with SHA256 verification
download_and_verify \
  "https://github.com/tool/releases/tool.tar.gz" \
  "tool.tar.gz" \
  "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
```

#### `verify_checksum()`

Verifies an existing file's checksum:

```bash
verify_checksum <file> <expected_checksum> [algorithm]
```

Example:

```bash
# Verify a file you already have
if verify_checksum "installer.sh" "abc123..." "sha256"; then
  echo "File is valid"
  bash installer.sh
else
  echo "File verification failed!"
  exit 1
fi
```

#### `create_checksum()`

Generate a checksum for a file:

```bash
# Generate SHA256 checksum
checksum=$(create_checksum "myfile.tar.gz" "sha256")
echo "SHA256: $checksum"

# Generate MD5 (less secure, for compatibility)
md5sum=$(create_checksum "myfile.tar.gz" "md5")
echo "MD5: $md5sum"
```

### Manifest Files

Download multiple files with verification using a manifest:

```bash
# Create manifest file
cat > downloads.manifest << EOF
# URL                           FILENAME        CHECKSUM        ALGORITHM
https://example.com/tool1.tar.gz tool1.tar.gz   abc123...       sha256
https://example.com/tool2.zip    tool2.zip      def456...       sha256
EOF

# Download all files with verification
download_from_manifest "downloads.manifest" "/opt/tools"
```

### Finding Checksums

Where to find checksums for popular tools:

1. **GitHub Releases**: Look for `.sha256`, `.sha256sum`, or `checksums.txt` files
2. **Project Websites**: Usually on download pages
3. **Package Managers**: `apt-cache show <package>` shows MD5/SHA256
4. **GPG Signatures**: Some projects provide `.asc` files for GPG verification

Example for real tools:

```bash
# Node.js checksums
curl -O https://nodejs.org/dist/latest/SHASUMS256.txt

# Docker checksums
curl -O https://download.docker.com/linux/ubuntu/dists/jammy/stable/binary-amd64/Packages

# Terraform checksums
curl -O https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_SHA256SUMS
```

### Implementing in Your Scripts

Example integration in an installer script:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source verification utilities
source "$(dirname "$0")/../utils/checksum_verify.sh"

install_terraform() {
  local version="1.6.0"
  local os="linux"
  local arch="amd64"

  # Real checksums from HashiCorp
  local checksums_url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_SHA256SUMS"
  local terraform_url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip"

  # Download checksums file
  curl -sL "$checksums_url" -o /tmp/terraform_checksums.txt

  # Extract checksum for our file
  local expected_checksum
  expected_checksum=$(grep "${os}_${arch}.zip" /tmp/terraform_checksums.txt | cut -d' ' -f1)

  # Download and verify
  if download_and_verify "$terraform_url" "/tmp/terraform.zip" "$expected_checksum"; then
    unzip -q /tmp/terraform.zip -d /usr/local/bin/
    rm /tmp/terraform.zip
    echo "✅ Terraform installed successfully"
  else
    echo "❌ Terraform verification failed"
    exit 1
  fi
}
```

## API Key Management

### Environment Variables

Never hardcode API keys. Use environment variables:

```bash
# .env file (git ignored)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# Load in scripts
source .env
```

### Using direnv

Automatic environment loading with direnv:

```bash
# Install direnv
curl -sfL https://direnv.net/install.sh | bash

# Create .envrc
cat > .envrc << 'EOF'
# Load API keys
export OPENAI_API_KEY=$(pass openai/api-key)
export ANTHROPIC_API_KEY=$(pass anthropic/api-key)
EOF

# Allow direnv for this directory
direnv allow
```

### Secure Storage

#### Using pass (Password Store)

```bash
# Install pass
sudo apt install pass

# Initialize
gpg --gen-key
pass init your-email@example.com

# Store API keys
pass insert openai/api-key
pass insert anthropic/api-key

# Retrieve in scripts
export OPENAI_API_KEY=$(pass openai/api-key)
```

#### Using macOS Keychain

```bash
# Store
security add-generic-password -a "$USER" -s "openai-api-key" -w "sk-..."

# Retrieve
export OPENAI_API_KEY=$(security find-generic-password -a "$USER" -s "openai-api-key" -w)
```

### Key Rotation

Implement regular key rotation:

```python
import os
from datetime import datetime, timedelta

def check_key_age(key_created_date):
    """Alert if key is older than 90 days"""
    age = datetime.now() - key_created_date
    if age > timedelta(days=90):
        print("⚠️ API key is older than 90 days - consider rotating")
        return False
    return True

# Track key creation
KEY_CREATED = datetime(2024, 1, 1)  # Store in config
if not check_key_age(KEY_CREATED):
    print("Visit: https://platform.openai.com/api-keys")
```

## Sandboxed Execution

### Codex Sandbox

Run AI-generated code safely:

```bash
# Run in sandbox
./scripts/codex_sandbox.sh run generated_code.py

# Features:
# - Network isolation
# - Read-only filesystem
# - Memory limits
# - CPU limits
# - Timeout protection
```

### Docker Isolation

Create isolated environments for testing:

```bash
# Run with minimal privileges
docker run --rm \
  --network none \
  --read-only \
  --tmpfs /tmp \
  --memory="512m" \
  --cpus="1" \
  --security-opt no-new-privileges \
  --cap-drop ALL \
  python:3.12-slim \
  python -c "print('Safe execution')"
```

### Virtual Environments

Isolate Python dependencies:

```bash
# Create isolated environment
python3 -m venv ai_sandbox
source ai_sandbox/bin/activate

# Install only needed packages
pip install --no-deps package_name

# Run with restrictions
python -u -B -I script.py  # Unbuffered, no bytecode, isolated mode
```

## Security Scanning

DevPilot's automated security features:

- **Tool versions pinned** for reproducibility (Semgrep 1.45.0, Trivy 0.48.1, Gitleaks 8.18.1)
- **SARIF uploads** make findings visible in GitHub Security tab
- **Automated issue creation** tracks security debt
- **Non-blocking reviews** don't fail PRs, just inform

View all scan results in your repo's Security tab after each PR.

### Code Scanning

#### Gitleaks for Secrets

```bash
# Install gitleaks
./install/productivity_extras.sh  # Includes gitleaks

# Scan for secrets
gitleaks detect --source . --verbose

# Pre-commit hook
cat >> .pre-commit-config.yaml << EOF
- repo: https://github.com/gitleaks/gitleaks
  rev: v8.18.0
  hooks:
    - id: gitleaks
EOF
```

#### Semgrep for Vulnerabilities

```bash
# Install
pip install semgrep

# Scan
semgrep --config=auto .

# Custom rules for AI code
cat > .semgrep.yml << EOF
rules:
  - id: hardcoded-api-key
    pattern: |
      $KEY = "sk-..."
    message: "Hardcoded API key detected"
    severity: ERROR
EOF

semgrep --config=.semgrep.yml
```

### Dependency Scanning

#### Python Dependencies

```bash
# Install safety
pip install safety

# Check for known vulnerabilities
safety check

# Audit dependencies
pip-audit
```

#### Node.js Dependencies

```bash
# Built-in npm audit
npm audit

# Fix automatically
npm audit fix

# Check with snyk
npx snyk test
```

### Container Scanning

```bash
# Scan Docker images with Trivy
trivy image python:3.12

# Scan Dockerfiles
hadolint Dockerfile

# Runtime scanning
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image your-image:tag
```

## Best Practices

### 1. Principle of Least Privilege

Grant minimal permissions required:

```python
# Bad: Full file system access
with open("/etc/passwd", "r") as f:
    data = f.read()

# Good: Restricted to project directory
import os
ALLOWED_PATH = "/home/user/project"

def safe_read(filepath):
    abs_path = os.path.abspath(filepath)
    if not abs_path.startswith(ALLOWED_PATH):
        raise PermissionError(f"Access denied: {filepath}")
    with open(abs_path, "r") as f:
        return f.read()
```

### 2. Input Validation

Always validate user and AI inputs:

```python
import re
from typing import Optional

def validate_url(url: str) -> Optional[str]:
    """Validate and sanitize URLs"""
    # Only allow HTTPS
    if not url.startswith("https://"):
        return None

    # Check against allowlist
    ALLOWED_DOMAINS = ["github.com", "pypi.org", "npmjs.com"]
    domain = re.match(r"https://([^/]+)", url).group(1)
    if domain not in ALLOWED_DOMAINS:
        return None

    return url

def validate_command(cmd: str) -> bool:
    """Validate shell commands"""
    DANGEROUS_COMMANDS = ["rm -rf", "sudo", "chmod 777", "eval"]
    for danger in DANGEROUS_COMMANDS:
        if danger in cmd:
            return False
    return True
```

### 3. Rate Limiting

Protect against API abuse:

```python
from functools import wraps
from time import time, sleep

def rate_limit(calls: int, period: int):
    """Rate limit decorator"""
    min_interval = period / calls
    last_called = [0.0]

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time() - last_called[0]
            left_to_wait = min_interval - elapsed
            if left_to_wait > 0:
                sleep(left_to_wait)
            ret = func(*args, **kwargs)
            last_called[0] = time()
            return ret
        return wrapper
    return decorator

@rate_limit(calls=10, period=60)  # 10 calls per minute
def call_api():
    # API call here
    pass
```

### 4. Audit Logging

Log all security-relevant events:

```python
import logging
import json
from datetime import datetime

# Configure security logger
security_logger = logging.getLogger("security")
security_logger.setLevel(logging.INFO)
handler = logging.FileHandler("security.log")
handler.setFormatter(logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
))
security_logger.addHandler(handler)

def log_security_event(event_type: str, details: dict):
    """Log security events with structure"""
    event = {
        "timestamp": datetime.utcnow().isoformat(),
        "type": event_type,
        "details": details
    }
    security_logger.info(json.dumps(event))

# Usage
log_security_event("api_key_access", {
    "user": os.getenv("USER"),
    "key_type": "openai",
    "action": "read"
})
```

### 5. Secure Defaults

Always default to secure settings:

```python
class SecureConfig:
    # Secure defaults
    ALLOW_NETWORK = False
    MAX_MEMORY_MB = 512
    MAX_CPU_PERCENT = 50
    TIMEOUT_SECONDS = 30
    ALLOW_FILE_WRITE = False
    ALLOWED_MODULES = ["math", "json", "datetime"]

    @classmethod
    def validate(cls, user_config: dict) -> dict:
        """Merge user config with secure defaults"""
        config = {}
        for key, default_value in cls.__dict__.items():
            if not key.startswith("_"):
                config[key] = user_config.get(key, default_value)
                # Ensure user doesn't exceed limits
                if "MAX" in key and config[key] > default_value:
                    config[key] = default_value
        return config
```

## Security Checklist

Before deploying AI applications:

- [ ] All API keys in environment variables
- [ ] `.env` file in `.gitignore`
- [ ] Checksum verification for downloads
- [ ] Input validation on all user inputs
- [ ] Rate limiting on API calls
- [ ] Audit logging enabled
- [ ] Security scanning in CI/CD
- [ ] Sandboxed execution for untrusted code
- [ ] Regular dependency updates
- [ ] Key rotation schedule
- [ ] Backup of critical data
- [ ] Incident response plan

## Incident Response

### If API Key is Exposed

1. **Immediately revoke** the exposed key
2. **Generate new key** from provider dashboard
3. **Update** all systems using the key
4. **Audit logs** for unauthorized usage
5. **Review** how exposure occurred
6. **Implement** additional safeguards

### If System is Compromised

1. **Isolate** affected systems
2. **Preserve** logs and evidence
3. **Assess** scope of compromise
4. **Remove** malicious code/access
5. **Patch** vulnerabilities
6. **Restore** from clean backups
7. **Monitor** for recurring issues
8. **Document** lessons learned

## Resources

- [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [OpenAI Security Best Practices](https://platform.openai.com/docs/guides/safety-best-practices)
- [Anthropic Safety Guidelines](https://www.anthropic.com/safety)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

_Security is an ongoing process, not a destination. Stay vigilant and keep learning._
