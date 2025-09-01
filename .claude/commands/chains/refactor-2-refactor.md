# Chain: Refactor - Step 2/3 - REFACTOR

You are executing step 2 of 3 for code refactoring.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, automated refactoring tools, tests.
- Conventions: preserve functionality, improve maintainability, keep commits atomic.
</context>

<input>
{PASTE_ANALYSIS_FROM_STEP_1}
</input>

<goal>
Apply top 3 refactorings while maintaining all existing functionality.
</goal>

<plan>
- Create comprehensive test baseline
- Apply one refactoring at a time
- Run tests after each change
- Commit atomically
- Document improvements
</plan>

<work>
For each refactoring:

1. **Baseline tests**:
   ```bash
   # Capture current behavior
   pnpm test {SCOPE} --coverage > /tmp/baseline-coverage.txt
   pnpm test {SCOPE} --json > /tmp/baseline-tests.json
   ```

2. **Refactoring patterns**:

   **Extract Method**:
   ```javascript
   // Before: Long function
   function process(data) {
     // 50 lines of validation
     // 50 lines of transformation
     // 50 lines of saving
   }
   
   // After: Composed functions
   function process(data) {
     const validated = validate(data);
     const transformed = transform(validated);
     return save(transformed);
   }
   ```

   **Replace Conditional with Polymorphism**:
   ```javascript
   // Before: Switch statement
   switch(type) {
     case 'A': return processA();
     case 'B': return processB();
   }
   
   // After: Strategy pattern
   const strategies = { A: processA, B: processB };
   return strategies[type]();
   ```

   **Introduce Parameter Object**:
   ```javascript
   // Before: Many parameters
   function create(name, age, email, phone, address) {}
   
   // After: Object parameter
   function create(userDetails) {}
   ```

3. **Test after each change**:
   ```bash
   pnpm test {SCOPE}
   diff /tmp/baseline-tests.json <(pnpm test {SCOPE} --json)
   ```

4. **Commit atomically**:
   ```bash
   git add -p  # Stage specific changes
   git commit -m "refactor: extract {method} from {function}
   
   - Reduces complexity from X to Y
   - Improves testability
   - No functional changes"
   ```
</work>

<self_check>
- Is behavior identical to baseline?
- Are names more descriptive?
- Is code more testable?
- Would a new developer understand this better?
</self_check>

<review>
- [ ] All tests still pass
- [ ] Coverage maintained or improved
- [ ] Each refactoring in separate commit
- [ ] Performance not degraded
- [ ] Code more maintainable
</review>

<handoff>
<refactoring>
## Applied Refactorings

### 1. Extract Method ✅
**File**: {FILE}
**Change**: Extracted validation logic
```diff
- function processUser(data) {
-   // 50 lines of validation
-   if (!data.email || !data.email.match(/@/)) {
-     throw new Error('Invalid email');
-   }
-   // ... more validation
+ function processUser(data) {
+   validateUser(data);
    // ... processing
  }
+ 
+ function validateUser(data) {
+   if (!data.email || !data.email.match(/@/)) {
+     throw new Error('Invalid email');
+   }
+ }
```
**Impact**: 
- Complexity: 15 → 8
- Testability: Can now unit test validation

### 2. Remove Duplication ✅
**Files**: {FILE1}, {FILE2}
**Change**: Extracted shared utility
```diff
# Created utils/formatter.js
+ export function formatCurrency(amount) {
+   return new Intl.NumberFormat('en-US', {
+     style: 'currency',
+     currency: 'USD'
+   }).format(amount);
+ }

# Updated both files to import
- const formatted = '$' + amount.toFixed(2);
+ const formatted = formatCurrency(amount);
```
**Impact**: 
- Removed 30 lines of duplication
- Centralized formatting logic

### 3. Simplify Conditionals ✅
**File**: {FILE}
**Change**: Early returns
```diff
- function validate(data) {
-   if (data) {
-     if (data.isValid) {
-       if (data.hasPermission) {
-         return true;
-       }
-     }
-   }
-   return false;
- }
+ function validate(data) {
+   if (!data) return false;
+   if (!data.isValid) return false;
+   if (!data.hasPermission) return false;
+   return true;
+ }
```
**Impact**:
- Nesting: 3 levels → 0 levels
- Readability: Much clearer

## Metrics Improvement
| Metric | Before | After | Change |
|--------|---------|--------|---------|
| Avg Complexity | 12.3 | 7.8 | -37% |
| Max Complexity | 24 | 12 | -50% |
| Duplication | 15% | 8% | -47% |
| Test Coverage | 75% | 78% | +3% |

## Commits
- {HASH1}: refactor: extract validation methods
- {HASH2}: refactor: consolidate formatters
- {HASH3}: refactor: simplify conditionals
</refactoring>
</handoff>
