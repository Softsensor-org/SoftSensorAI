# DevPilot Release Management Plan

**Document Version:** 1.0.0  
**Date:** 2024-08-31  
**Owner:** DevPilot Release Team  
**Status:** Active

---

## 1. Release Strategy

### 1.1 Versioning Scheme
DevPilot follows **Semantic Versioning 2.0.0** (SemVer):

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

- **MAJOR**: Breaking changes to APIs or CLI commands
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, security patches
- **PRERELEASE**: alpha, beta, rc (release candidate)
- **BUILD**: Build metadata (optional)

### 1.2 Release Cadence

| Release Type | Frequency | Examples | Stability |
|-------------|-----------|----------|------------|
| Patch | As needed | v1.0.1, v1.0.2 | Stable |
| Minor | Monthly | v1.1.0, v1.2.0 | Stable |
| Major | Quarterly | v2.0.0, v3.0.0 | Stable |
| Pre-release | Weekly | v1.2.0-beta.1 | Testing |
| Nightly | Daily | v1.2.0-nightly.20240831 | Unstable |

### 1.3 Release Channels

- **Stable**: Production-ready releases
- **Beta**: Feature-complete, testing phase
- **Alpha**: Early development, may have bugs
- **Nightly**: Latest development build
- **LTS**: Long-term support (every 4th major release)

## 2. Historical Release Identification

Based on git history analysis, here are the logical release points:

### Version 0.1.0 (Foundation)
**Date:** Initial Release  
**Commit:** 6f75d9f  
**Type:** Alpha
- Initial WSL & AI Agent setup scripts
- Basic repository structure
- Core installation functionality

### Version 0.2.0 (CI/CD Integration)
**Commits:** 1f976d6 - 6898d39  
**Type:** Alpha
- CI workflow with GitHub Actions
- Pre-commit hooks integration
- Audit scripts and Makefile
- Documentation improvements

### Version 0.3.0 (Production Readiness)
**Commits:** 6ba7c8c - 9bfef7b  
**Type:** Beta
- Major production enhancements
- Productivity extras installer
- Devcontainer support
- MCP (Model Context Protocol) integration
- Justfile template

### Version 0.4.0 (AI Enhancement Suite)
**Commits:** 14030c4 - 1283564  
**Type:** Beta
- Prompt engineering suite
- Anthropic best practices
- OpenAI Codex CLI integration
- Security enhancements

### Version 0.5.0 (Chain Commands)
**Commits:** bc788fb - c4a300f  
**Type:** Beta
- Structured chain commands
- Design patterns library
- Self-correction patterns
- Parallelization support

### Version 0.6.0 (Learning Platform)
**Commits:** 0beddce - dea9c76  
**Type:** Release Candidate
- Learning-aware platform
- Progressive skill levels (vibe → expert)
- System prompt layering
- Extended thinking controls
- Comprehensive documentation

### Version 0.7.0 (Advanced Features)
**Commits:** caa5d66 - 71c1465  
**Type:** Release Candidate
- Cross-platform installers
- macOS compatibility
- Prompt auditing
- Security JSON generation
- Syntax fixes

### Version 1.0.0 (DevPilot Launch)
**Commits:** 169f652 - b4fa7ea  
**Type:** Stable
- Official DevPilot rebranding
- Proprietary license
- Production-ready platform

### Version 1.1.0 (Enhanced Validation)
**Commits:** 864a952 - ddd9803  
**Type:** Stable
- mise runtime management
- Enhanced validation
- Cross-platform improvements
- Doctor script
- Commands catalog

### Version 1.2.0 (Organization & UX)
**Commits:** 1b7c6ce - 55097ae  
**Type:** Stable (Current)
- Script reorganization
- Planning/preview functionality
- Backward compatibility wrappers
- Improved user experience

### Version 1.3.0 (Documentation & Planning)
**Commit:** da0b31f  
**Type:** Stable (Latest)
- Architecture analysis
- Migration planning
- Rollback procedures
- Comprehensive documentation

## 3. Release Process

### 3.1 Pre-Release Checklist

```bash
# 1. Ensure clean working directory
git status --porcelain

# 2. Run all tests
make test
make test-bats

# 3. Run audit
make audit

# 4. Update version numbers
./scripts/bump-version.sh <major|minor|patch>

# 5. Update CHANGELOG.md
./scripts/generate-changelog.sh

# 6. Review documentation
./scripts/check-docs.sh
```

### 3.2 Release Steps

1. **Create Release Branch**
   ```bash
   git checkout -b release/v1.3.0
   ```

2. **Update Version Files**
   - `VERSION` file
   - `package.json` (if applicable)
   - README.md badges

3. **Generate Release Notes**
   ```bash
   ./scripts/generate-release-notes.sh v1.2.0..HEAD
   ```

4. **Create Tag**
   ```bash
   git tag -a v1.3.0 -m "Release v1.3.0: Documentation & Planning"
   ```

5. **Push to Repository**
   ```bash
   git push origin release/v1.3.0
   git push origin v1.3.0
   ```

6. **Create GitHub Release**
   ```bash
   gh release create v1.3.0 \
     --title "DevPilot v1.3.0: Documentation & Planning" \
     --notes-file RELEASE_NOTES.md \
     --target main
   ```

### 3.3 Post-Release Tasks

- [ ] Merge release branch to main
- [ ] Update documentation site
- [ ] Announce on communication channels
- [ ] Monitor for issues
- [ ] Plan next release items

## 4. Change Tracking

### 4.1 Commit Message Convention

Follow **Conventional Commits** specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Testing
- `chore`: Maintenance
- `ci`: CI/CD changes

### 4.2 Changelog Generation

Automatic changelog generation based on commit types:

```bash
#!/bin/bash
# scripts/generate-changelog.sh

git log --format="%s|%h|%an|%ad" --date=short v1.2.0..HEAD | \
while IFS='|' read subject hash author date; do
    type=$(echo "$subject" | cut -d':' -f1)
    desc=$(echo "$subject" | cut -d':' -f2-)
    
    case "$type" in
        feat) echo "### ✨ Features"
              echo "- $desc ($hash) by $author"
              ;;
        fix)  echo "### 🐛 Bug Fixes"
              echo "- $desc ($hash) by $author"
              ;;
        docs) echo "### 📚 Documentation"
              echo "- $desc ($hash) by $author"
              ;;
    esac
done
```

## 5. Release Artifacts

### 5.1 Distribution Packages

| Platform | Format | Location |
|----------|--------|----------|
| Linux/WSL | tar.gz | `releases/devpilot-linux-<version>.tar.gz` |
| macOS | tar.gz | `releases/devpilot-macos-<version>.tar.gz` |
| Docker | Image | `ghcr.io/softsensor-org/devpilot:<version>` |
| Script Bundle | zip | `releases/devpilot-scripts-<version>.zip` |

### 5.2 Release Notes Template

```markdown
# DevPilot v1.3.0 Release Notes

## 🎉 Highlights
- Major feature or improvement
- Key bug fixes
- Performance enhancements

## ✨ New Features
- Feature 1: Description
- Feature 2: Description

## 🐛 Bug Fixes
- Fixed issue with...
- Resolved problem in...

## 📚 Documentation
- Added guide for...
- Updated references for...

## 🔄 Changes
- Refactored component X
- Improved performance of Y

## ⚠️ Breaking Changes
- API change: Old → New
- Command change: Old → New

## 🔮 Coming Next
- Preview of next release features

## 📦 Installation
```bash
# Quick install
curl -sSL https://devpilot.ai/install | bash

# Or manual
git clone https://github.com/Softsensor-org/DevPilot.git
cd DevPilot
./setup_all.sh
```

## 🙏 Contributors
Thanks to all contributors!

## 📝 Full Changelog
See [CHANGELOG.md](CHANGELOG.md) for detailed changes.
```

## 6. Version Support Matrix

| Version | Status | Support Until | Notes |
|---------|--------|--------------|--------|
| 1.3.x | Current | Active development | Latest features |
| 1.2.x | Supported | 2024-11-30 | Security fixes only |
| 1.1.x | Supported | 2024-10-31 | Critical fixes only |
| 1.0.x | LTS | 2025-08-31 | Long-term support |
| 0.x | EOL | - | No longer supported |

## 7. Automation Scripts

### 7.1 Version Bumping
```bash
#!/bin/bash
# scripts/bump-version.sh

set -euo pipefail

TYPE="${1:-patch}"
CURRENT=$(cat VERSION)

case "$TYPE" in
    major) NEW=$(echo "$CURRENT" | awk -F. '{print $1+1".0.0"}') ;;
    minor) NEW=$(echo "$CURRENT" | awk -F. '{print $1"."$2+1".0"}') ;;
    patch) NEW=$(echo "$CURRENT" | awk -F. '{print $1"."$2"."$3+1}') ;;
    *) echo "Usage: $0 [major|minor|patch]"; exit 1 ;;
esac

echo "$NEW" > VERSION
echo "Bumped version from $CURRENT to $NEW"
```

### 7.2 Release Automation
```bash
#!/bin/bash
# scripts/release.sh

set -euo pipefail

VERSION="$(cat VERSION)"
RELEASE_BRANCH="release/v$VERSION"

# Pre-flight checks
if [[ -n $(git status --porcelain) ]]; then
    echo "Error: Working directory not clean"
    exit 1
fi

# Run tests
make test || exit 1

# Create release branch
git checkout -b "$RELEASE_BRANCH"

# Update changelog
./scripts/generate-changelog.sh > CHANGELOG_NEW.md
cat CHANGELOG.md >> CHANGELOG_NEW.md
mv CHANGELOG_NEW.md CHANGELOG.md

# Commit changes
git add -A
git commit -m "chore: prepare release v$VERSION"

# Create tag
git tag -a "v$VERSION" -m "Release v$VERSION"

# Push
git push origin "$RELEASE_BRANCH"
git push origin "v$VERSION"

# Create GitHub release
gh release create "v$VERSION" \
    --title "DevPilot v$VERSION" \
    --generate-notes \
    --target "$RELEASE_BRANCH"

echo "✅ Release v$VERSION created successfully!"
```

## 8. Release Metrics

### 8.1 Key Performance Indicators

- **Release Frequency**: Target 1 minor release/month
- **Bug Escape Rate**: < 5 bugs per release
- **Hotfix Rate**: < 1 per release
- **Adoption Rate**: > 80% within 30 days
- **Rollback Rate**: < 1%

### 8.2 Quality Gates

| Gate | Requirement | Tool |
|------|-------------|------|
| Test Coverage | > 80% | pytest-cov |
| Code Quality | A rating | SonarQube |
| Security | No high/critical | Trivy |
| Performance | < 5% degradation | Benchmark |
| Documentation | 100% coverage | Doc linter |

## 9. Communication Plan

### 9.1 Release Announcement Channels

- GitHub Releases page
- DevPilot website/blog
- Email newsletter
- Slack #announcements
- Twitter/LinkedIn

### 9.2 Stakeholder Notification

| Stakeholder | Method | Timing |
|-------------|--------|--------|
| Development Team | Slack | 1 week before |
| Beta Users | Email | 3 days before |
| All Users | Website | Release day |
| Partners | Email | Release day |

## 10. Rollback Plan

If a release needs to be rolled back:

1. **Revert Tag**
   ```bash
   git tag -d v1.3.0
   git push origin :refs/tags/v1.3.0
   ```

2. **Create Hotfix**
   ```bash
   git checkout -b hotfix/v1.2.1 v1.2.0
   # Apply fixes
   git tag -a v1.2.1 -m "Hotfix v1.2.1"
   ```

3. **Update Communications**
   - Post incident report
   - Notify affected users
   - Document lessons learned

---

**Document Control:**
- Review: Before each release
- Update: As process changes
- Owner: Release Manager