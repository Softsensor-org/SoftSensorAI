---
id: APC-AGENT
title: Agent wrapper with PLAN PATCH DIFF enforcement
status: achieved
owner: system
version: 1.0.0
allowed_globs:
  - scripts/**
  - .softsensor/**
  - package.json
forbidden_globs:
  - src/**
acceptance_criteria:
  - id: AC-1
    must: MUST load active task and contract
    text: Load .softsensor/active-task.json and referenced contract file
    tests:
      - scripts/agent_wrapper.mjs
  - id: AC-2
    must: MUST enforce output format
    text: Validate PLAN, PATCH, DIFF SUMMARY sections exist
    tests:
      - scripts/agent_wrapper.mjs
  - id: AC-3
    must: MUST validate file scope
    text: Check patch files against allowed and forbidden globs
    tests:
      - scripts/agent_wrapper.mjs
  - id: AC-4
    must: MUST integrate with npm
    text: Provide agent:task npm script
    tests:
      - package.json
checkpoints:
  - id: CP-1
    date: 2024-12-09
    status: completed
    notes: Initial implementation
---

# APC-AGENT: Contract-Bound Agent Wrapper

This contract implements an AI agent wrapper that enforces contract constraints and structured output format.

## Features

### Contract Enforcement
The agent is bound by the active contract's constraints:
- Loads `.softsensor/active-task.json` for contract reference
- Merges allowed/forbidden globs from task and contract
- Validates all file modifications against scope rules

### Output Format Protocol
Enforces strict three-section output:
1. **PLAN** - Strategic approach in bullet points
2. **PATCH** - Unified diff format for changes
3. **DIFF SUMMARY** - Structured change summary

### Validation Pipeline
1. Parse model output for required sections
2. Extract file paths from PATCH section
3. Validate against allowed/forbidden globs
4. Reject violations before execution

## Usage

### Setup Active Task
First, ensure you have an active task configured:
```json
// .softsensor/active-task.json
{
  "contract_id": "FEATURE-ABC",
  "allowed_globs": ["scripts/**"],
  "forbidden_globs": ["src/**"]
}
```

### Run Agent Task
```bash
npm run agent:task "implement the login validation feature"
```

### Output Example
```
## PLAN
- Load validation rules from config
- Create validation function
- Add error handling
- Write unit tests

## PATCH
--- a/scripts/validate.js
+++ b/scripts/validate.js
@@ -0,0 +1,10 @@
+function validateLogin(username, password) {
+  // validation logic
+}

## DIFF SUMMARY
- Added scripts/validate.js (10 lines)
- Core validation logic implemented
```

## Validation Rules

### Scope Validation
- Files in PATCH must match at least one allowed_glob
- Files must not match any forbidden_glob
- Violations cause immediate rejection

### Format Validation
- All three sections must be present
- Sections must use ## headers
- Missing sections trigger re-prompt

## Error Handling

### Invalid Format
If output lacks required sections:
- Error message specifies missing sections
- Output saved to `artifacts/agent_invalid_output.txt`
- Agent exits with error code

### Scope Violations
If files violate contract scope:
- Lists all violations with details
- Saves to `artifacts/agent_violations.txt`
- Prevents execution of changes

## Integration

### With AI Providers
Uses `tools/ai_shim.sh` to support multiple providers:
- Claude (preferred)
- Codex
- Gemini  
- Grok

### With Vibe Workflow
Works seamlessly with vibe-generated contracts:
1. `dp vibe promote` creates contract
2. Sets up active-task.json
3. Agent respects the contract scope

## Benefits

- **Safety**: Prevents out-of-scope modifications
- **Consistency**: Enforces structured output
- **Traceability**: All outputs logged to artifacts/
- **Flexibility**: Works with any contract