# Security Policy

## 📋 Security Overview

SoftSensorAI takes security seriously. This document outlines our security practices and how to
report vulnerabilities.

## 🔒 Comprehensive Security Guide

For detailed security information, please see our complete security documentation:

**👉 [Full Security Guide](docs/SECURITY.md)**

The comprehensive guide covers:

- Checksum verification for secure downloads
- API key management best practices
- Sandboxed execution for AI-generated code
- Security scanning with gitleaks, semgrep, trivy
- Input validation and rate limiting
- Audit logging and monitoring
- Incident response procedures

## 🚨 Reporting Security Vulnerabilities

### Supported Versions

We provide security updates for:

| Version        | Supported |
| -------------- | --------- |
| main           | ✅ Yes    |
| Latest release | ✅ Yes    |

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, report security vulnerabilities via:

1. **GitHub Security Advisories** (Preferred)

   - Go to https://github.com/Softsensor-org/SoftSensorAI/security/advisories
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Private Contact**
   - Create a private issue mentioning security concerns
   - We'll respond with secure communication channels

### What to Include

When reporting vulnerabilities, please include:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if available)
- Your contact information for follow-up

## ⚡ Response Timeline

- **Initial Response**: Within 48 hours
- **Vulnerability Assessment**: Within 7 days
- **Fix Development**: Based on severity
  - Critical: 1-3 days
  - High: 1-2 weeks
  - Medium: 2-4 weeks
  - Low: Next release cycle

## 🛡️ Security Features

SoftSensorAI includes several built-in security features:

### Download Security

- SHA256/SHA1/MD5 checksum verification
- Secure HTTPS downloads only
- Package integrity validation

### API Key Protection

- Environment variable storage
- No hardcoded credentials
- Secure key rotation practices

### Code Execution Safety

- Sandboxed execution for AI-generated code
- Docker isolation for untrusted code
- Read-only filesystem mounts
- Network isolation options

### CI/CD Security Gates

- Automatic secret scanning (gitleaks)
- SAST analysis (semgrep)
- Container vulnerability scanning (trivy)
- Dependency auditing
- License compliance checking

## 🔍 Security Scanning

SoftSensorAI includes automated security scanning:

```bash
# Run security scans locally
gitleaks detect --source .
semgrep --config=auto .
trivy fs .

# Generate security report
claude --system-prompt .claude/commands/security-review.md "comprehensive security audit"
```

## 🏆 Security Best Practices

When using SoftSensorAI:

1. **Keep Updated**: Regularly update to the latest version
2. **Secure API Keys**: Never commit API keys to repositories
3. **Review Generated Code**: Always review AI-generated code before deploying
4. **Use Phases**: Apply appropriate security phases (beta/scale) for production
5. **Monitor Dependencies**: Keep dependencies updated and scanned

## 🤝 Security Community

We appreciate security researchers and welcome:

- Responsible disclosure of vulnerabilities
- Security improvement suggestions
- Code security reviews
- Documentation improvements

## 📚 Additional Resources

- [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [SoftSensorAI Security Guide](docs/SECURITY.md) - Complete security documentation

---

**Security is a shared responsibility. Thank you for helping keep SoftSensorAI secure!** 🛡️
