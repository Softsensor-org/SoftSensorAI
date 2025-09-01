DevPilot Migration Working Directory

- scripts/logger.sh: logging helpers
- scripts/validate.sh: phase validation checks
- scripts/migrate-files.sh: copies per state/migration-map.json
- scripts/compat-layer.sh: generates wrappers (non-destructive by default)
- scripts/rollback.sh: rollback to checkpoint or emergency cleanup
- scripts/canary.sh: initializes flags and router stub
- scripts/test-migration.sh: basic migration tests
- state/config.json: migration state/config
- state/migration-map.json: mapping manifest
- logs/: logs and metrics
- rollback/: saved checkpoints

Typical flow:
1) make lint test
2) .migration/scripts/migrate-files.sh
3) .migration/scripts/test-migration.sh
4) .migration/scripts/compat-layer.sh   # review wrappers under .migration/wrappers/
5) .migration/scripts/canary.sh         # optional
6) .migration/scripts/rollback.sh latest  # if needed

