---
id: REFACTOR-DB
title: Migrate to repository pattern
status: planned
owner: backend-team
version: 1.0.0
allowed_globs:
  - src/repositories/**
  - src/models/**
  - tests/repositories/**
  - docs/architecture/**
forbidden_globs:
  - src/api/endpoints/**  # Don't change API contracts
  - src/ui/**             # UI remains unchanged
acceptance_criteria:
  - id: AC-1
    must: MUST maintain backward compatibility
    text: All existing API endpoints continue to work unchanged
    tests:
      - tests/api/compatibility.test.js
  - id: AC-2
    must: MUST implement repository pattern
    text: Data access goes through repository interfaces
    tests:
      - tests/repositories/pattern.test.js
  - id: AC-3
    must: MUST improve testability
    text: Repositories can be easily mocked for testing
    tests:
      - tests/repositories/mocking.test.js
---

# Database Layer Refactoring

## Goal
Migrate from direct database access to repository pattern for better testability and maintainability.

## Current State
```javascript
// Direct DB access (BAD)
async function getUser(id) {
  return await db.query('SELECT * FROM users WHERE id = ?', [id]);
}
```

## Target State
```javascript
// Repository pattern (GOOD)
class UserRepository {
  async findById(id) {
    const data = await this.db.query('SELECT * FROM users WHERE id = ?', [id]);
    return new User(data);
  }
}
```

## Migration Strategy
1. Create repository interfaces
2. Implement repositories alongside existing code
3. Gradually migrate endpoints to use repositories
4. Remove old direct DB access code

## Benefits
- Testable without database
- Consistent data access patterns
- Easier to swap database engines
- Better separation of concerns