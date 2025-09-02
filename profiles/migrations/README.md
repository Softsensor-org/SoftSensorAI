# Profile Migrations System

## Overview

The profile migration system ensures smooth upgrades and rollbacks when profile schemas or
configurations change. Each migration is versioned and can be applied forward or rolled back.

## Migration Structure

```
profiles/
├── migrations/
│   ├── README.md (this file)
│   ├── .version (current version)
│   ├── 001_initial_schema.sh
│   ├── 002_add_teach_mode.sh
│   ├── 003_split_personas.sh
│   └── ...
├── schemas/
│   ├── v1.0.0.json
│   ├── v1.1.0.json
│   └── current.json -> v1.1.0.json
```

## Migration File Format

Each migration must export:

- `VERSION`: Target version after migration
- `DESCRIPTION`: What this migration does
- `migrate_up()`: Forward migration function
- `migrate_down()`: Rollback function
- `validate()`: Validation function

## Usage

```bash
# Check current version
./scripts/profile_migrate.sh status

# Migrate to latest
./scripts/profile_migrate.sh up

# Migrate to specific version
./scripts/profile_migrate.sh up 1.2.0

# Rollback one version
./scripts/profile_migrate.sh down

# Rollback to specific version
./scripts/profile_migrate.sh down 1.0.0

# Dry run (no changes)
./scripts/profile_migrate.sh up --dry-run
```

## Writing Migrations

1. Create new migration file: `XXX_description.sh`
2. Follow the template in `template.migration.sh`
3. Test both up and down migrations
4. Update schema files if needed
5. Document breaking changes

## Version History

| Version | Date    | Description                        |
| ------- | ------- | ---------------------------------- |
| 1.0.0   | 2024-01 | Initial profile system             |
| 1.1.0   | 2024-02 | Added teach_mode                   |
| 1.2.0   | 2024-03 | Split personas into separate files |
