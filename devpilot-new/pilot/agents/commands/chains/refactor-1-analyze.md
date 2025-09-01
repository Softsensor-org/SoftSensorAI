# Chain: Refactor - Step 1/3 - ANALYZE

You are executing step 1 of 3 for code refactoring.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, ast-grep, complexity analysis tools.
- Conventions: preserve functionality, improve maintainability, keep commits atomic.
</context>

<input>
Target: {FILE_OR_DIRECTORY}
Focus: {readability|performance|testability|modularity}
</input>

<goal>
Analyze code to identify refactoring opportunities ranked by impact.
</goal>

<plan>
- Measure complexity metrics
- Identify code smells
- Find duplication
- Analyze dependencies
- List refactoring candidates
</plan>

<work>
1. Complexity analysis:
   ```bash
   # Cyclomatic complexity
   find {TARGET} -name "*.js" -o -name "*.ts" | xargs -I {} sh -c 'echo "=== {} ==="; npx complexity-report {} 2>/dev/null | head -20'
   
   # Function length
   rg "^(async\s+)?function|^(export\s+)?(const|let|var)\s+\w+\s*=\s*(async\s*)?\(" {TARGET} -A 50 | awk '/function|const.*=/{name=$0} /^}/{print name, NR-start; start=0} /function|const.*=/{start=NR}'
   ```

2. Duplication detection:
   ```bash
   # Find similar code blocks
   rg -U "(.{30,})\n.*\n.*\1" {TARGET} || echo "No exact duplicates"
   ```

3. Code smells:
   ```bash
   # Long parameter lists
   rg "\([^)]{100,}\)" {TARGET}
   
   # Deeply nested code
   rg "^\s{16,}" {TARGET}
   
   # God objects/modules
   wc -l {TARGET}/* | sort -rn | head
   ```

4. Dependency analysis:
   ```bash
   # Circular dependencies
   rg "import.*from ['\"]\./" {TARGET} | sort | uniq -c | sort -rn
   ```
</work>

<review>
- [ ] Metrics objectively measured
- [ ] Worst offenders identified
- [ ] Impact assessment complete
- [ ] No breaking changes planned
</review>

<handoff>
<analysis>
## Code Quality Metrics

### Complexity Hotspots
1. **{FILE}:{FUNCTION}**
   - Cyclomatic: {N}
   - Lines: {N}
   - Dependencies: {N}
   - Recommendation: Split into {N} functions

2. **{FILE}:{FUNCTION}**
   - Issue: Deeply nested (6 levels)
   - Impact: Hard to test and understand

### Duplication
- **Pattern found {N} times**:
  - {FILE1}:{LINES}
  - {FILE2}:{LINES}
  - Extract to: shared utility function

### Code Smells
| Smell | Location | Impact | Priority |
|-------|----------|---------|----------|
| God class | {FILE} (800 lines) | High | 1 |
| Long method | {METHOD} (150 lines) | High | 2 |
| Feature envy | {CLASS} | Medium | 3 |

### Refactoring Opportunities (Ranked)
1. **Extract Method**: {FILE}:{LINES}
   - Benefit: -50% complexity
   - Risk: Low
   - Effort: 30 min

2. **Replace Conditional with Polymorphism**: {FILE}
   - Benefit: Extensibility
   - Risk: Medium
   - Effort: 2 hours

3. **Introduce Parameter Object**: {FUNCTION}
   - Benefit: Cleaner API
   - Risk: Low
   - Effort: 1 hour
</analysis>
</handoff>