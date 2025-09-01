# Design Patterns Library

A comprehensive collection of battle-tested prompt patterns for common development tasks. Each pattern includes the universal preamble, clear success criteria, and exact commands to run.

## Quick Start

```bash
# List all patterns
scripts/pattern_selector.sh list

# Show a specific pattern
scripts/pattern_selector.sh backend-feature

# Copy pattern to clipboard
scripts/pattern_selector.sh bug-fix copy

# Search by tag
scripts/pattern_selector.sh search security

# Show command chain
scripts/pattern_selector.sh chain feature-full
```

## Pattern Categories

### 🔍 Discovery & Planning
- **discovery-scope** - Turn vague tickets into crisp specs
- **arch-spike** - Evaluate architecture options with trade-offs

### 🔧 Backend Development  
- **backend-feature** - Implement feature with minimal diff
- **bug-fix** - Test-first bug fixing
- **safe-refactor** - Restructure without behavior change
- **test-first** - TDD for new units/APIs

### 📊 Data & ML
- **data-pipeline** - ETL and exploratory data analysis
- **sql-migration** - Safe database schema changes
- **ml-experiment** - Reproducible model experiments
- **ml-error-analysis** - Actionable error buckets

### 🔒 Quality & Security
- **security-review** - Tool-assisted security audit
- **performance-pass** - Profile and optimize hot paths

### 🌐 API & Frontend
- **api-contract** - OpenAPI spec updates
- **frontend-feature** - Component-first UI development

### 📦 Release & Review
- **release-changelog** - Generate release notes
- **pr-self-review** - Pre-PR quality check
- **postmortem** - Incident documentation

## Core Principles

### Universal Loop
Every pattern follows this execution loop:
1. **PLAN** → List acceptance checks + exact commands
2. **CODE** → Produce smallest diff to satisfy PLAN
3. **VERIFY** → Run commands; fix if failures
4. **STOP** → Brief next-steps; clean temp files

### Success Criteria
Each pattern defines:
- **Use-when**: Clear trigger conditions
- **Inputs**: Required information
- **Success**: Objective completion criteria

### Tool Integration
Patterns work with your existing tools:
- `pnpm`, `pytest`, `docker`, `kubectl`, `helm`
- `rg`, `jq`, `semgrep`, `trivy`, `gitleaks`
- `scripts/run_checks.sh` (your custom validator)

## Pattern Chains

Common multi-step workflows:

### Feature Implementation
```bash
scripts/pattern_selector.sh chain feature-full
```
1. discovery-scope → 2. arch-spike → 3. backend-feature → 4. security-review → 5. pr-self-review

### Bug Investigation
```bash
scripts/pattern_selector.sh chain bug-to-fix
```
1. bug-fix → 2. test-first → 3. pr-self-review

### Quality Pass
```bash
scripts/pattern_selector.sh chain quality-pass
```
1. safe-refactor → 2. performance-pass → 3. security-review → 4. pr-self-review

## Usage Tips

### In Claude
```bash
# Use directly as commands
/patterns/backend-feature

# Or reference from filesystem
cat .claude/commands/patterns/bug-fix.md
```

### With Codex CLI
```bash
# Pipe pattern to Codex
scripts/pattern_selector.sh backend-feature | codex exec --approval-mode auto-edit
```

### In Scripts
```bash
# Embed in automation
PATTERN=$(scripts/pattern_selector.sh backend-feature show)
echo "$PATTERN" | sed "s/{JIRA_KEY}/ENG-123/g"
```

## Customization

### Adding New Patterns
1. Create `.claude/commands/patterns/my-pattern.md`
2. Add to `prompts/registry.yaml`
3. Follow the universal template structure

### Project-Specific Adjustments
Edit patterns to match your:
- Tool commands (replace `pnpm` with `npm`/`yarn`)
- Test runners (replace `pytest` with your framework)
- Conventions (adjust commit message format)

## Tool Recipe Quick Reference

| Task | Command |
|------|---------|
| Lint/Type/Test | `pnpm lint && pnpm typecheck && pnpm test -i` |
| Full check | `scripts/run_checks.sh` |
| Search | `rg -n "<pattern>"` |
| Diff size | `git diff --stat` |
| SQL lint | `sqlfluff lint .` |
| Security | `semgrep --config auto; trivy fs .; gitleaks detect` |
| Performance | `hyperfine "<cmd>" --warmup 3` |
| API spec | `redocly lint openapi.yaml; openapi-typescript` |

## Best Practices

1. **Always include VERIFY** - Actually run the commands
2. **Keep diffs minimal** - Smallest change that works
3. **Clean up** - Remove temp files after each pattern
4. **Chain wisely** - Use chains for multi-step workflows
5. **Customize** - Adapt patterns to your project needs

## Troubleshooting

**Pattern not working?**
- Check if required tools are installed
- Verify paths match your project structure
- Ensure commands are appropriate for your stack

**Need to modify a pattern?**
- Edit the `.md` file directly
- Update registry.yaml if adding new patterns
- Test with `pattern_selector.sh <name> show`

**Want to share patterns?**
- Export your patterns directory
- Share registry.yaml for easy discovery
- Document any project-specific requirements
