# Contributing to SoftSensorAI

Thank you for your interest in contributing to SoftSensorAI! This guide will help you get started.

## 📖 Documentation First

Before contributing, please review our comprehensive documentation:

- **[Architecture Overview](docs/ARCHITECTURE_OVERVIEW.md)** - Understanding SoftSensorAI's design
- **[Quickstart Guide](docs/quickstart.md)** - Getting SoftSensorAI running
- **[Week with SoftSensorAI](docs/WEEK_WITH_DEVPILOT.md)** - Daily workflow examples

## 🚀 Quick Start for Contributors

1. **Fork and clone the repository**

   ```bash
   git clone https://github.com/your-username/SoftSensorAI.git
   cd SoftSensorAI
   ```

2. **Set up SoftSensorAI on itself** (dogfooding!)

   ```bash
   # Install SoftSensorAI globally
   ./setup_all.sh

   # Setup this repo with SoftSensorAI
   ./setup/existing_repo_setup.sh --skill expert --phase beta

   # Add development personas
   ./scripts/persona_manager.sh add software-architect
   ./scripts/persona_manager.sh add devops-engineer
   ```

3. **Run the validation suite**
   ```bash
   ./validation/validate_agents.sh
   scripts/run_checks.sh --all
   ```

## 🎯 Contribution Areas

### High-Impact Areas

1. **New AI Assistant Integrations**

   - Add support for new CLI tools
   - Extend persona system
   - Improve command catalog

2. **Platform Support**

   - Windows native support
   - Additional Linux distributions
   - Cloud IDE integrations

3. **Security & Reliability**
   - Security scanning improvements
   - Checksum verification enhancements
   - Error handling and recovery

### Current Priorities

Check our [GitHub Issues](https://github.com/Softsensor-org/SoftSensorAI/issues) for:

- Issues labeled `good first issue` for newcomers
- Issues labeled `help wanted` for experienced contributors
- Issues labeled `enhancement` for new features

## 📝 Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- **Follow existing patterns**: Study similar files before making changes
- **Maintain compatibility**: Ensure changes work across Linux/macOS/WSL
- **Update documentation**: Add/update docs for user-facing changes
- **Add tests**: Include validation for new functionality

### 3. Test Your Changes

```bash
# Run validation suite
./validation/validate_agents.sh

# Test setup scripts (use a clean environment)
./scripts/repo_plan.sh /tmp/test work backend test-project https://github.com/octocat/Hello-World.git

# Test specific components
shellcheck setup/*.sh scripts/*.sh
```

### 4. Use SoftSensorAI for Development

```bash
# Generate implementation plan
claude --system-prompt system/active.md "/explore-plan-code-test implement [your feature]"

# Security review before commit
claude --system-prompt .claude/commands/security-review.md "review my changes"

# Generate tests
claude --system-prompt .claude/commands/patterns/test-first.md "create tests for [feature]"
```

### 5. Submit Pull Request

- Write clear commit messages following [Conventional Commits](https://www.conventionalcommits.org/)
- Reference relevant issues
- Include testing instructions
- Update documentation as needed

## 🔧 Code Standards

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use BSD-compatible commands (e.g., `sed -i''` not `sed -i`)
- Follow existing error handling patterns

### Documentation

- Use clear, actionable headings
- Include working code examples
- Provide both interactive and command-line usage
- Link between related documentation

### Python Scripts

- Follow PEP 8 style guidelines
- Include type hints where helpful
- Write docstrings for functions
- Handle errors gracefully

## 🧪 Testing Guidelines

### Manual Testing Checklist

- [ ] Works on Linux (Ubuntu/Debian)
- [ ] Works on macOS (Intel and Apple Silicon)
- [ ] Works in WSL2
- [ ] Handles missing dependencies gracefully
- [ ] Provides helpful error messages
- [ ] Follows existing UX patterns

### Automated Testing

- Add validation scripts to `validation/`
- Include example usage in documentation
- Test error conditions and edge cases

## 📋 Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add support for Grok CLI integration
fix: handle missing .git directory gracefully
docs: update persona selection tutorial
chore: clean up legacy scripts
refactor: simplify profile application logic
test: add validation for GPU detection
```

### Types

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `refactor`: Code restructuring
- `test`: Adding tests
- `ci`: CI/CD changes

## 🏷️ Pull Request Labels

We use these labels to categorize PRs:

- `enhancement`: New features
- `bug`: Bug fixes
- `documentation`: Documentation improvements
- `good first issue`: Good for newcomers
- `help wanted`: Seeking contributors
- `breaking change`: Breaking changes

## 🔍 Code Review Process

1. **Automated Checks**: CI must pass (shellcheck, tests, etc.)
2. **Functionality Review**: Does it work as intended?
3. **Code Quality**: Is it maintainable and follows patterns?
4. **Documentation**: Are docs updated appropriately?
5. **Testing**: Is it adequately tested?

## 🚫 What Not to Contribute

- Changes that break backward compatibility without discussion
- Platform-specific code without cross-platform considerations
- Large refactoring without prior issue discussion
- API keys or sensitive credentials (even in examples)
- Duplicate functionality that already exists

## 🆘 Getting Help

- **Questions**: Open a [Discussion](https://github.com/Softsensor-org/SoftSensorAI/discussions)
- **Bugs**: Open an [Issue](https://github.com/Softsensor-org/SoftSensorAI/issues)
- **Chat**: Join our community discussions
- **Documentation**: Check [docs/](docs/) directory first

## 📜 License

By contributing to SoftSensorAI, you agree that your contributions will be licensed under the same
license as the project.

## 🙏 Recognition

Contributors are recognized in our README and release notes. Thank you for helping make SoftSensorAI
better for everyone!

---

**Happy Contributing!** 🚀
