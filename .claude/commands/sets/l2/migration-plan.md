# Database Migration Plan

Execute safe, reversible database schema changes.

## Pre-Migration Checklist
- [ ] Current schema backed up
- [ ] Migration is idempotent
- [ ] Rollback script prepared
- [ ] Tested on staging
- [ ] Maintenance window scheduled

## Migration Structure

```sql
-- Forward Migration
BEGIN TRANSACTION;

-- 1. Schema changes
ALTER TABLE users ADD COLUMN last_login TIMESTAMP;
CREATE INDEX idx_users_last_login ON users(last_login);

-- 2. Data migration (if needed)
UPDATE users SET last_login = updated_at WHERE last_login IS NULL;

-- 3. Constraints
ALTER TABLE users ALTER COLUMN last_login SET NOT NULL;

COMMIT;

-- Rollback Plan
-- BEGIN TRANSACTION;
-- ALTER TABLE users DROP COLUMN last_login;
-- COMMIT;
```

## Verification Commands
```bash
# Pre-migration state
pg_dump -s dbname > schema_before.sql

# Run migration
psql dbname < migration_001.sql

# Verify
psql dbname -c "\\d+ users"

# Performance check
EXPLAIN ANALYZE SELECT * FROM users WHERE last_login > NOW() - INTERVAL '7 days';
```

## Risk Assessment
- **Data Loss Risk**: Low (additive change)
- **Downtime**: <1 minute
- **Rollback Time**: <30 seconds
- **Impact**: Read queries unaffected, writes need update

## Deployment Steps
1. Enable maintenance mode
2. Backup production database
3. Run migration
4. Verify schema
5. Update application code
6. Disable maintenance mode
7. Monitor for errors

## Post-Migration
- Monitor slow query log
- Check application error rates
- Verify data integrity
- Document in changelog
