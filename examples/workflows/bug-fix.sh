#!/bin/bash
# Example: Bug fix workflow with contract

echo "🐛 Bug Fix Workflow Example"
echo "==========================="
echo ""
echo "This demonstrates fixing a bug using contracts for scope control."
echo ""

# Step 1: Create bug contract
echo "Step 1: Creating targeted bug fix contract"
echo ""
cat << 'EOF'
$ cat > contracts/BUG-AUTH-001.contract.md << 'CONTRACT'
---
id: BUG-AUTH-001
title: Fix session timeout not working
status: in_progress
owner: alice
version: 1.0.0
allowed_globs:
  - src/auth/session.js
  - tests/auth/session-timeout.test.js
forbidden_globs:
  - src/auth/login.js  # Don't touch login logic
  - src/database/**    # No DB changes
acceptance_criteria:
  - id: AC-1
    must: MUST expire sessions after 24 hours
    text: Sessions automatically expire after 24 hours of creation
    tests:
      - tests/auth/session-timeout.test.js
---
# Bug: Session Timeout Not Working

Sessions are not expiring after 24 hours as configured.
Root cause: Timeout check using wrong timestamp field.
CONTRACT
EOF
echo ""

# Step 2: Activate contract
echo "Step 2: Activating the bug contract"
echo "$ echo '{\"contract_id\":\"BUG-AUTH-001\"}' > .softsensor/active-task.json"
echo ""

# Step 3: Write failing test first
echo "Step 3: Writing test that reproduces the bug"
echo "$ vim tests/auth/session-timeout.test.js"
echo ""
cat << 'EOF'
it('should expire session after 24 hours', () => {
  const session = createSession();
  session.createdAt = Date.now() - (25 * 60 * 60 * 1000); // 25 hours ago
  
  expect(isSessionValid(session)).toBe(false); // This fails! Bug confirmed
});
EOF
echo ""

# Step 4: Fix the bug
echo "Step 4: Fixing the bug"
echo "$ vim src/auth/session.js"
echo ""
echo "Changed:"
echo "- if (Date.now() - session.lastActive > TIMEOUT)"
echo "+ if (Date.now() - session.createdAt > TIMEOUT)"
echo ""

# Step 5: Verify fix
echo "Step 5: Verifying the fix"
echo "$ npm test tests/auth/session-timeout.test.js"
echo "✅ All tests passing"
echo ""

# Step 6: Check scope
echo "Step 6: Checking we stayed in scope"
echo "$ git status"
echo "  modified: src/auth/session.js ✅ (allowed)"
echo "  modified: tests/auth/session-timeout.test.js ✅ (allowed)"
echo ""

# Step 7: Commit with trailers
echo "Step 7: Committing the fix"
echo "$ git commit -m \"fix: session timeout using wrong timestamp"
echo ""
echo "Sessions were checking lastActive instead of createdAt,"
echo "causing them to never expire if user remained active."
echo ""
echo "Contract-Id: BUG-AUTH-001"
echo "Contract-Hash: def45678\""
echo ""

# Step 8: Update contract status
echo "Step 8: Marking contract as achieved"
echo "$ vim contracts/BUG-AUTH-001.contract.md"
echo "(Change status: in_progress → status: achieved)"
echo ""

echo "✅ Bug fixed with minimal, scoped changes!"