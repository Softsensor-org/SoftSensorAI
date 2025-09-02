# DevPilot Release Management

## Version Numbering

DevPilot follows [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH** (e.g., 2.0.0)
  - **MAJOR**: Breaking changes, architectural shifts
  - **MINOR**: New features, backward compatible
  - **PATCH**: Bug fixes, documentation updates

## Release Schedule

| Type      | Frequency | Description                 |
| --------- | --------- | --------------------------- |
| **Patch** | As needed | Bug fixes, urgent updates   |
| **Minor** | Monthly   | New features, improvements  |
| **Major** | Quarterly | Breaking changes, redesigns |

## Release Process

### 1. Pre-Release Checklist

```bash
# Run all tests
./validation/validate_agents.sh
./tools/audit_setup_scripts.sh

# Check for breaking changes
git diff main..develop --name-only | grep -E "\.sh$"

# Update version
echo "X.Y.Z" > VERSION

# Update documentation
vim CHANGELOG.md
vim RELEASE_NOTES.md
```

### 2. Version Tagging

```bash
# Create release branch
git checkout -b release/v2.0.0

# Commit version updates
git add VERSION CHANGELOG.md RELEASE_NOTES.md
git commit -m "chore: Prepare v2.0.0 release"

# Tag release
git tag -a v2.0.0 -m "Release v2.0.0: Major platform redesign"

# Push to remote
git push origin release/v2.0.0
git push origin v2.0.0
```

### 3. GitHub Release

1. Go to https://github.com/Softsensor-org/DevPilot/releases
2. Click "Draft a new release"
3. Choose tag: `v2.0.0`
4. Title: `DevPilot v2.0.0 - Platform Redesign`
5. Copy content from `RELEASE_NOTES.md`
6. Attach any binaries if applicable
7. Mark as pre-release if beta
8. Publish release

### 4. Post-Release

```bash
# Merge to main
git checkout main
git merge release/v2.0.0

# Update develop
git checkout develop
git merge main

# Clean up
git branch -d release/v2.0.0
```

## Version Files

### VERSION

- Single line with version number
- Used by scripts for version checks
- Example: `2.0.0`

### CHANGELOG.md

- Complete history of all changes
- Follows [Keep a Changelog](https://keepachangelog.com/) format
- Sections: Added, Changed, Removed, Fixed, Security

### RELEASE_NOTES.md

- User-friendly release announcement
- Highlights and key features
- Migration instructions
- Known issues

## Release Types

### Major Release (X.0.0)

- Breaking changes
- Architecture updates
- Migration required
- Full documentation update
- Announcement to all users

### Minor Release (x.Y.0)

- New features
- Backward compatible
- Documentation for new features
- Optional migration

### Patch Release (x.y.Z)

- Bug fixes only
- No documentation changes needed
- Silent update

## Testing Requirements

### Before Any Release

- [ ] All scripts pass shellcheck
- [ ] Validation runs clean
- [ ] Fresh install tested on WSL
- [ ] Fresh install tested on Linux
- [ ] Fresh install tested on macOS (if possible)
- [ ] Upgrade path tested
- [ ] Documentation reviewed

### Major Release Additional

- [ ] Migration guide written
- [ ] Breaking changes documented
- [ ] Compatibility matrix updated
- [ ] Performance benchmarked

## Communication

### Release Announcement Template

````markdown
# DevPilot vX.Y.Z Released!

We're excited to announce DevPilot vX.Y.Z with [key feature].

## What's New

- Feature 1
- Feature 2
- Bug fixes

## Upgrade

```bash
cd ~/devpilot
git pull origin main
./setup_all.sh
```
````

## Full Details

See [RELEASE_NOTES.md](RELEASE_NOTES.md)

````

### Channels
1. GitHub Release page
2. README.md update
3. Project documentation

## Rollback Procedure

If a release has critical issues:

```bash
# Revert to previous version
git checkout v1.5.0

# Or specific commit
git checkout abc123def

# Reinstall
./setup_all.sh --fresh
````

## Version Compatibility

| DevPilot | Claude CLI | Gemini | Grok | Minimum OS   |
| -------- | ---------- | ------ | ---- | ------------ |
| 2.0.x    | 0.5+       | 2.0+   | 1.0+ | Ubuntu 20.04 |
| 1.5.x    | 0.4+       | 1.5+   | 0.9+ | Ubuntu 18.04 |
| 1.0.x    | 0.3+       | 1.0+   | 0.5+ | Ubuntu 18.04 |

## Deprecation Policy

- Features marked deprecated in minor release
- Removed in next major release
- Minimum 3 months deprecation notice
- Migration path documented

## Emergency Hotfix

For critical security issues:

```bash
# Create hotfix from main
git checkout -b hotfix/v2.0.1 main

# Fix issue
vim affected_file.sh

# Fast track release
git commit -am "fix: Critical security issue"
git tag v2.0.1
git push origin v2.0.1

# Immediate merge to main and develop
git checkout main && git merge hotfix/v2.0.1
git checkout develop && git merge hotfix/v2.0.1
```

## Release Artifacts

Each release should include:

- Source code (automatic via Git)
- VERSION file updated
- CHANGELOG.md entry
- RELEASE_NOTES.md for major/minor
- GitHub Release created
- Tag in repository

## Metrics to Track

- Download/clone count
- Issue frequency post-release
- Time to first issue
- Adoption rate of new features
- Rollback frequency

---

**Remember**: Every release should make DevPilot better for users. Quality over quantity!
