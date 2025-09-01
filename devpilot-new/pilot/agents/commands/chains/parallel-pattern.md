# Parallelization Pattern for Chains

Execute independent steps concurrently for faster results.

## Core Pattern

When steps don't depend on each other, run them in parallel:

```markdown
# Step A1, A2, A3 run in parallel
<parallel>
  <task id="doc1">Analyze document 1</task>
  <task id="doc2">Analyze document 2</task>
  <task id="doc3">Analyze document 3</task>
</parallel>

# Step B merges results
<input>
  <result id="doc1">...</result>
  <result id="doc2">...</result>
  <result id="doc3">...</result>
</input>
Goal: de-duplicate, rank by severity, then proceed.
```

## Implementation Strategies

### 1. Tool-Level Parallelization (Claude)
Use multiple tool calls in a single message:

```markdown
I'll analyze these three documents in parallel for efficiency.

[Calls Read tool for doc1.md]
[Calls Read tool for doc2.md]  
[Calls Read tool for doc3.md]
[All execute simultaneously]
```

### 2. Script-Level Parallelization (Bash)
```bash
# Run analyses in background
./analyze.sh doc1.md > results1.json &
./analyze.sh doc2.md > results2.json &
./analyze.sh doc3.md > results3.json &

# Wait for all to complete
wait

# Merge results
jq -s '.' results*.json > merged.json
```

### 3. Chain Runner Parallelization
```bash
# Launch parallel chains
scripts/chain_runner.sh analyze task-doc1 &
scripts/chain_runner.sh analyze task-doc2 &
scripts/chain_runner.sh analyze task-doc3 &
wait

# Merge step
scripts/chain_runner.sh merge-analysis task-combined
```

## Common Parallel Patterns

### Document Analysis
```markdown
<parallel>
  <scan id="security">Run security scanners</scan>
  <scan id="performance">Run performance profiler</scan>
  <scan id="quality">Run quality checks</scan>
</parallel>

<merge>
Combine all scan results into priority matrix
</merge>
```

### Multi-Service Testing
```markdown
<parallel>
  <test service="api">Test API endpoints</test>
  <test service="web">Test web interface</test>
  <test service="mobile">Test mobile app</test>
</parallel>

<report>
Consolidated test report with cross-service issues highlighted
</report>
```

### Data Processing
```markdown
<parallel>
  <process partition="2024-Q1">Process Q1 data</process>
  <process partition="2024-Q2">Process Q2 data</process>
  <process partition="2024-Q3">Process Q3 data</process>
  <process partition="2024-Q4">Process Q4 data</process>
</parallel>

<aggregate>
Combine quarterly results into annual summary
</aggregate>
```

## Merge Strategies

### 1. Union (Combine All)
```python
results = []
for partial in parallel_results:
    results.extend(partial)
return deduplicate(results)
```

### 2. Intersection (Common Only)
```python
common = set(parallel_results[0])
for partial in parallel_results[1:]:
    common &= set(partial)
return list(common)
```

### 3. Priority (Ranked Merge)
```python
all_items = []
for partial in parallel_results:
    all_items.extend(partial)
return sorted(all_items, key=lambda x: (x.severity, x.confidence))[:top_n]
```

### 4. Voting (Consensus)
```python
votes = defaultdict(int)
for partial in parallel_results:
    for item in partial:
        votes[item] += 1
return [item for item, count in votes.items() if count >= min_votes]
```

## Handoff Template for Parallel Results

```markdown
<handoff>
<parallel_results>
  <result id="task1" status="complete" duration="2.3s">
    <summary>Found 3 critical issues</summary>
    <data>...</data>
  </result>
  <result id="task2" status="complete" duration="1.8s">
    <summary>Found 1 critical issue</summary>
    <data>...</data>
  </result>
  <result id="task3" status="failed" error="timeout">
    <summary>Analysis incomplete</summary>
  </result>
</parallel_results>

<merged>
  Total issues: 4 critical (3 unique after dedup)
  Failed tasks: 1 (task3 - timeout)
  Recommendation: Address critical issues first, retry task3
</merged>
</handoff>
```

## Best Practices

1. **Independence Check**: Ensure tasks truly don't depend on each other
2. **Resource Limits**: Don't overwhelm system (limit concurrent tasks)
3. **Failure Handling**: Design for partial failures
4. **Result Validation**: Verify all parallel tasks completed
5. **Deterministic Merge**: Ensure merge produces consistent results

## Anti-Patterns to Avoid

❌ **Race Conditions**: Writing to same file from parallel tasks
❌ **Hidden Dependencies**: Tasks that seem independent but aren't
❌ **Unbounded Parallelism**: Launching too many concurrent tasks
❌ **Silent Failures**: Not checking if parallel tasks succeeded
❌ **Order Dependence**: Merge logic that assumes specific completion order