#!/bin/bash
# Example: Complete feature development workflow

echo "🚀 Feature Development Workflow Example"
echo "======================================="
echo ""
echo "This script demonstrates the complete workflow for developing"
echo "a new feature using the contract system."
echo ""

# Step 1: Start exploration
echo "Step 1: Starting exploration phase"
echo "$ dp vibe start 'add shopping cart'"
echo ""

# Step 2: Development work
echo "Step 2: Making changes and taking snapshots"
echo "$ vim src/cart/index.js"
echo "$ npm test"
echo "$ dp vibe snapshot 'basic cart operations working'"
echo ""
echo "$ vim src/cart/checkout.js" 
echo "$ dp vibe snapshot 'checkout flow implemented'"
echo ""

# Step 3: Review impact
echo "Step 3: Reviewing what was changed"
echo "$ dp vibe end"
echo ""
echo "Output:"
echo "  📊 Impact Report"
echo "     Total files changed: 7"
echo "     "
echo "  📁 Files by directory:"
echo "     src/cart/"
echo "       - index.js"
echo "       - checkout.js"
echo "       - items.js"
echo "     tests/"
echo "       - cart.test.js"
echo ""

# Step 4: Promote to contract
echo "Step 4: Promoting to formal contract"
echo "$ dp vibe promote"
echo ""
echo "Output:"
echo "  ✅ Created contract: contracts/F-M7K9-B4D2.contract.md"
echo "  ✅ Created test scaffold: tests/contract/F-M7K9-B4D2/core.spec.ts"
echo "  ✅ Updated active task"
echo "  ✅ Switched mode to BLOCK"
echo ""

# Step 5: Refine contract
echo "Step 5: Refining the generated contract"
echo "$ vim contracts/F-M7K9-B4D2.contract.md"
echo "(Add better descriptions, adjust criteria, etc.)"
echo ""

# Step 6: Implement tests
echo "Step 6: Implementing contract tests"
echo "$ vim tests/contract/F-M7K9-B4D2/core.spec.ts"
echo "$ npm test"
echo ""

# Step 7: Validate
echo "Step 7: Validating contract"
echo "$ npm run contracts:validate"
echo ""
echo "Output:"
echo "  ✅ F-M7K9-B4D2: Shopping cart feature [a8b9c0d1]"
echo ""

# Step 8: Commit
echo "Step 8: Committing with contract trailers"
echo "$ git add ."
echo "$ git commit -m \"feat: add shopping cart functionality"
echo ""
echo "Implements complete shopping cart with:"
echo "- Add/remove items"
echo "- Update quantities" 
echo "- Calculate totals"
echo "- Checkout flow"
echo ""
echo "Contract-Id: F-M7K9-B4D2"
echo "Contract-Hash: a8b9c0d1\""
echo ""

# Step 9: Push and create PR
echo "Step 9: Pushing and creating PR"
echo "$ git push origin feature/shopping-cart"
echo "$ gh pr create --title 'Add shopping cart' --body '...'"
echo ""

# Step 10: CI validation
echo "Step 10: CI automatically validates"
echo "- ✅ Contract format valid"
echo "- ✅ Commit trailers present"
echo "- ✅ All files within scope"
echo "- ✅ Touchpoint tests pass"
echo "- ✅ Performance budgets met"
echo ""

echo "🎉 Feature successfully developed with contract compliance!"