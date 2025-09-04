# DevPilot → SoftSensorAI Migration

## Goals

- Preserve backward compatibility (env, paths, CLI)
- Zero downtime for single-user & multi-user installs

## What changes

- New envs: `SOFTSENSORAI_ROOT`, `SOFTSENSORAI_USER_DIR`, `SOFTSENSORAI_ARTIFACTS`
- New CLIs: `ss`, `ss-agent`, `ss-apiize`, `ss-testgen`
- Docs: brand references updated (DevPilot → SoftSensorAI)

## What remains compatible

- Old envs (`DEVPILOT_*`) still work (mapped in `lib/sh/brand_compat.sh`)
- Old CLIs `dp`, `dp-agent`, `dp-apiize`, `dp-testgen` still work
- Multi-user conf at `/opt/devpilot/etc/devpilot.conf` still honored

## Install steps

```bash
# 1) Dry-run
bash scripts/migrate_devpilot_to_softsensorai.sh --dry-run

# 2) Apply
bash scripts/migrate_devpilot_to_softsensorai.sh --execute
```

## Multi-user notes

- If `/opt/devpilot` exists, a compatibility symlink for `/opt/softsensorai` is created
  (best-effort).
- Prefer `/opt/softsensorai/etc/softsensorai.conf` going forward. Old `/opt/devpilot/...` remains
  valid.

## Rollback

- Remove new `ss*` wrappers and `lib/sh/brand_compat.sh`
- Remove `/opt/softsensorai` symlink if created
- Revert docs changes (git revert commit)

## Test checklist

- `./bin/dp init` and `./bin/ss init` both print mode & artifacts paths
- `dp testgen` and `ss testgen` generate tests & run within 120s
- `dp review` risk tags print correctly
- `apiize` builds and exposes `/healthz` + `/readyz`

## Environment Variables

### New (Preferred)

- `SOFTSENSORAI_ROOT`: Installation root directory
- `SOFTSENSORAI_USER_DIR`: User-specific directory for artifacts
- `SOFTSENSORAI_ARTIFACTS`: Artifacts storage location

### Legacy (Still Supported)

- `DEVPILOT_ROOT`: Maps to SOFTSENSORAI_ROOT
- `DEVPILOT_USER_DIR`: Maps to SOFTSENSORAI_USER_DIR
- `DEVPILOT_ARTIFACTS`: Maps to SOFTSENSORAI_ARTIFACTS

## Command Mapping

| Old Command  | New Command  | Status    |
| ------------ | ------------ | --------- |
| `dp`         | `ss`         | Both work |
| `dp-agent`   | `ss-agent`   | Both work |
| `dp-apiize`  | `ss-apiize`  | Both work |
| `dp-testgen` | `ss-testgen` | Both work |

## Grace Period

We recommend maintaining both command sets for at least one minor version (e.g., through v1.1.0)
before deprecating the old `dp*` commands.

## Support

For migration issues, please open a GitHub issue with the `migration` label.
