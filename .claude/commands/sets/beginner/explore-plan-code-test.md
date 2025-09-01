# Explore → Plan → Code → Test

A structured approach for implementing features step-by-step.

## Step 1: EXPLORE
I'll help you understand:
- What files are involved
- How the current code works
- What needs to change

Commands I'll run:
```bash
# Find relevant files
rg -l "feature_name"

# Understand structure
ls -la src/

# Check existing tests
ls -la tests/
```

## Step 2: PLAN
Together we'll create:
- Clear acceptance criteria (what defines "done")
- A list of exact commands to run
- The files we'll modify or create

Example plan:
```
1. Add new function to handle user input
2. Write test to verify it works
3. Update documentation
4. Run all checks
```

## Step 3: CODE
I'll write the minimal code needed:
- Show you the changes before and after
- Explain each modification
- Keep changes small and focused

Example:
```javascript
// Before
function processData(input) {
  return input;
}

// After
function processData(input) {
  // Validate input first
  if (!input) {
    throw new Error('Input required');
  }
  return input.trim();
}
```

## Step 4: TEST
We'll verify everything works:
```bash
# Run tests
pnpm test

# Check types
pnpm typecheck

# Verify no issues
scripts/run_checks.sh
```

## What You'll Learn
- How to break down problems
- Test-first development
- Reading error messages
- Making atomic commits

Ready? Let's start with: What feature do you want to implement?
